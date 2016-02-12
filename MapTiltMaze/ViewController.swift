//
//  ViewController.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/9/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import MapKit
import CoreMotion

class ViewController: UIViewController, MKMapViewDelegate {

    var mapView:MKMapView!
    var annotations = [MKPointAnnotation]()
    var trailGraph: TrailGraph!
    var prevNode:TrailNode!
    var fullRoute = [CLLocationCoordinate2D]()
    var userLocation:UserAnnotation!
    var testLocation:UserAnnotation!
    var testpolyLine:MKPolyline!
    var motionManager:CMMotionManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mapView = MKMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        let longPressRec:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "pinLocation:")
        longPressRec.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRec)
    }

    func pinLocation(sender:UILongPressGestureRecognizer){
        if sender.state != .Began {
            return
        }
        let tappedPoint:CGPoint = sender.locationInView(mapView)
        let tappedCoordinate:CLLocationCoordinate2D = mapView.convertPoint(tappedPoint, toCoordinateFromView: mapView)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = tappedCoordinate
        annotations.append(annotation)
        mapView.showAnnotations(annotations, animated: true)
        
        drawRoute()
        
    }
    
    func drawPolyline() {
        mapView.removeOverlays(mapView.overlays)
        var coordinates:[CLLocationCoordinate2D] = [CLLocationCoordinate2D]()
        for annotation in annotations {
            coordinates.append(annotation.coordinate)
        }
        
        let polyLine:MKPolyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)

        let padding:CGFloat = 50.0
        let visibleMapRect = mapView.mapRectThatFits(polyLine.boundingMapRect, edgePadding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        mapView.setRegion(MKCoordinateRegionForMapRect(visibleMapRect), animated: true)

        mapView.addOverlay(polyLine)
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3.0
        renderer.strokeColor = UIColor.blueColor()
        renderer.alpha = 0.5
        
        return renderer
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        let annotationView = views[0]
        let endFrame = annotationView.frame
        annotationView.frame = CGRectOffset(endFrame, 0, -600)
        
        UIView.animateWithDuration(0.3) { () -> Void in
            annotationView.frame = endFrame
        }
    }
    
    func drawRoute(){
        mapView.removeOverlays(mapView.overlays)
        
        var coordinates = [CLLocationCoordinate2D]()
        for annotation in annotations {
            coordinates.append(annotation.coordinate)
        }
        
        let polyLine:MKPolyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        
        let padding:CGFloat = 50.0
        let visibleMapRect = mapView.mapRectThatFits(polyLine.boundingMapRect, edgePadding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        mapView.setRegion(MKCoordinateRegionForMapRect(visibleMapRect), animated: true)
        
        var index = 0
        while index < annotations.count - 1 {
            drawDirection(annotations[index].coordinate, endPoint: annotations[index + 1].coordinate)
            index += 1
        }
    }
    
    func drawDirection(startPoint:CLLocationCoordinate2D, endPoint:CLLocationCoordinate2D){
        let startPlacemark:MKPlacemark = MKPlacemark(coordinate: startPoint, addressDictionary: nil)
        let endPlacemark:MKPlacemark = MKPlacemark(coordinate: endPoint, addressDictionary: nil)
        
        let startMapItem = MKMapItem(placemark: startPlacemark)
        let endMapItem = MKMapItem(placemark: endPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = startMapItem
        directionRequest.destination = endMapItem
        directionRequest.transportType = .Any
        
        let directions = MKDirections(request: directionRequest)
        directions.calculateDirectionsWithCompletionHandler { (routeResponse, routeError) -> Void in
            guard let routeResponse = routeResponse else {
                if let routeError = routeError {
                    print("Error:\(routeError)")
                }
                return
            }
            
            let route:MKRoute = routeResponse.routes[0]
            
            if let routeCoordinates:[CLLocationCoordinate2D] = self.getRouteCoordinates(route) {
                self.updateTrailGraph(routeCoordinates)
                self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
                if self.trailGraph.nodes.count > 1 {
//                    self.updateUserLocationTo(self.fullRoute.first!)
                    self.updateUserLocationTo(self.trailGraph.nodes.first!.location)
                    self.motionManager = CMMotionManager()
                    self.motionManager.accelerometerUpdateInterval = 0.1
                    
                    self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (accelerometerData, error) -> Void in
                        if error == nil {
                            self.processAccelerationData(accelerometerData!.acceleration)
                        } else {
                            print(error!)
                        }
                    })
                }
            }
        }
    }

    func processAccelerationData(acceleration: CMAcceleration){
        let dY = acceleration.y
        let dX = acceleration.x

        
        //create a line between current position and next position and save the slope
        let firstLoc:CLLocationCoordinate2D = self.trailGraph.nodes[0].location
        let secondLoc:CLLocationCoordinate2D = self.trailGraph.nodes[1].location
        let testLoc:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (((firstLoc.latitude) as Double) + dY) as CLLocationDegrees, longitude: (((firstLoc.longitude) as Double) + dX) as CLLocationDegrees)

        updateTestLocationTo(testLoc)
        drawTestLine(a: firstLoc, b: testLoc)
        
        let trailNodeOffsetX = secondLoc.latitude - firstLoc.latitude
        let trailNodeOffsetY = secondLoc.longitude - firstLoc.longitude
        
        let trailAngle = convertCoordToDegrees(a: trailNodeOffsetY as Double, b: trailNodeOffsetX as Double)
        let testAngle = convertCoordToDegrees(a: dX, b: dY)

//        print(trailAngle)
//        print(testAngle)
//        print("====================")

        if isCloseEnough(0.25, trailAngle: trailAngle, testAngle: testAngle){
            print(true)
        }else {
            print(false)
        }
        
    }
    
    func isCloseEnough(allowedErrorMargin: Double, trailAngle:Double, testAngle:Double) -> Bool {
        let error = ( trailAngle - testAngle ) / trailAngle
        
        print(error)
        
        if abs(error) < allowedErrorMargin {
            return true
        }
        
        return false
    }
    
    func convertCoordToDegrees(a a:Double, b:Double) -> Double{
        let rad = atan2(a, b)
        let deg = rad * 180 / M_PI
        
        return deg
    }

    func getRouteCoordinates(route:MKRoute) -> [CLLocationCoordinate2D]{
        let pointCount = route.polyline.pointCount
        var routeCoordinates: [CLLocationCoordinate2D] = Array(count: pointCount, repeatedValue: CLLocationCoordinate2D())
        route.polyline.getCoordinates(&routeCoordinates, range: NSMakeRange(0,pointCount))
        return routeCoordinates
    }
    
    func updateUserLocationTo(location:CLLocationCoordinate2D){
        if userLocation == nil {
            userLocation = UserAnnotation()
            userLocation.imageName = "loc"
        }
        if let index = annotations.indexOf(userLocation) {
            annotations.removeAtIndex(index)
        }

        userLocation.coordinate = location
        annotations.append(userLocation)
        mapView.showAnnotations(annotations, animated: true)

    }
    
    func updateTestLocationTo(location:CLLocationCoordinate2D){
        if testLocation == nil {
            testLocation = UserAnnotation()
            testLocation.imageName = "loc"
        }
        if let index = annotations.indexOf(testLocation) {
            annotations.removeAtIndex(index)
        }
        
        testLocation.coordinate = location
        annotations.append(testLocation)
        mapView.showAnnotations(annotations, animated: true)
        
    }
    
    func drawTestLine(a a:CLLocationCoordinate2D, b:CLLocationCoordinate2D){
        var coordinates = [CLLocationCoordinate2D]()
        coordinates.append(a)
        coordinates.append(b)
        if testpolyLine != nil {
            mapView.removeOverlay(testpolyLine)
        }
        testpolyLine = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        
        let padding:CGFloat = 50.0
        let visibleMapRect = mapView.mapRectThatFits(testpolyLine.boundingMapRect, edgePadding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        mapView.setRegion(MKCoordinateRegionForMapRect(visibleMapRect), animated: true)
        
        mapView.addOverlay(testpolyLine)
    }
    
    func moveUserLocationTo(node: TrailNode){
        updateUserLocationTo(node.location)
    }
    
    func updateTrailGraph(coordinates: [CLLocationCoordinate2D]){
        if trailGraph == nil {
            trailGraph = TrailGraph()
        }
        
        for coord in coordinates {
            let trailNode = TrailNode()
            trailNode.location = coord
            if prevNode != nil {
                trailNode.neighbors.append(prevNode)
            }

            if trailGraph.nodes.count == 1 {
                trailGraph.nodes.first!.neighbors.append(prevNode)
            }
            
            if !trailGraph.nodes.contains(trailNode) {
                trailGraph.nodes.append(trailNode)
            } else {
                if let index = trailGraph.nodes.indexOf(trailNode) {
                    if !trailGraph.nodes[index].neighbors.contains(prevNode) {
                        trailGraph.nodes[index].neighbors.append(prevNode)
                    }
                }
            }
            
            prevNode = trailNode
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
//        http://stackoverflow.com/questions/25631410/swift-different-images-for-annotation?rq=1
        print("delegate called")
        
        if !(annotation is UserAnnotation) {
            return nil
        }
        
        let reuseId = "test"

        var anView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            anView!.canShowCallout = true
        }
        else {
            anView!.annotation = annotation
        }
        
        //Set annotation-specific properties **AFTER**
        //the view is dequeued or created...
        
        let cpa = annotation as! UserAnnotation
        anView!.image = UIImage(named: cpa.imageName)
        anView!.alpha = 0.8
        return anView
    }

    func clearMap(){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
    }
}

class UserAnnotation: MKPointAnnotation {
    var imageName: String!
    var node: TrailNode!
    
    override init() {
        super.init()
    }
}

class TrailGraph:NSObject {
    var nodes:[TrailNode]!
    
    override init() {
        super.init()
        nodes = [TrailNode]()
    }
}

class TrailNode:NSObject {
    var location:CLLocationCoordinate2D!
    var neighbors:[TrailNode]!
    
    override init() {
        super.init()
        neighbors = [TrailNode]()
    }
}

