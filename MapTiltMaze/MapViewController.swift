//
//  MapViewController.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/9/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import MapKit
import CoreMotion

class MapViewController: UIViewController, MKMapViewDelegate, overlayDelegate {

    var mapView:MKMapView!
    var annotations = [MKPointAnnotation]()
    var trailGraph: TrailGraph!
    var prevNode:TrailNode!
    var fullRoute = [CLLocationCoordinate2D]()
    var userLocation:UserAnnotation!
    var testLocation:UserAnnotation!
    var testpolyLine:MKPolyline!
    var motionManager:CMMotionManager!

    var overlay:OverlayView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = MKMapView(frame: self.view.bounds)
        mapView.delegate = self
        self.view.addSubview(mapView)
        
        let longPressRec:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "pinLocation:")
        longPressRec.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPressRec)

        overlay = OverlayView(frame: CGRectMake(0,self.view.frame.height - 50, self.view.frame.width, 50))
        overlay.delegate = self
        self.view.addSubview(overlay)
        overlay.initGameCenter()
        overlay.loadMainGameMenu()

    }

    func pinLocation(sender:UILongPressGestureRecognizer){
        if annotations.count < 3{
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
        print("startPoint \(startPoint)")
        print("endPoint \(endPoint)")
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
                    self.userLocation.node = self.trailGraph.nodes.first!
                    
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

        if self.userLocation.node.neighbors.first == nil {
            print("you won")
            motionManager.stopAccelerometerUpdates()
            return
        }
        
        let dY = acceleration.y
        let dX = acceleration.x
        
        //create a line between current position and next position and save the slope
        let firstLoc:CLLocationCoordinate2D = self.userLocation.node.location
        let secondLoc:CLLocationCoordinate2D = self.userLocation.node.neighbors.first!.location

        
        let testLoc:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (((firstLoc.latitude) as Double) + dY) as CLLocationDegrees, longitude: (((firstLoc.longitude) as Double) + dX) as CLLocationDegrees)

        updateTestLocationTo(testLoc)
        drawTestLine(a: firstLoc, b: testLoc)
        
        let trailNodeOffsetX = secondLoc.latitude - firstLoc.latitude
        let trailNodeOffsetY = secondLoc.longitude - firstLoc.longitude
        
        var trailAngle = convertCoordToDegrees(a: trailNodeOffsetY as Double, b: trailNodeOffsetX as Double)
        var testAngle = convertCoordToDegrees(a: dX, b: dY)
        
        if trailAngle == 0 {
            trailAngle = 0.1
        }
        
        if testAngle == 0 {
            testAngle = -0.1
        }
        
        if isCloseEnough(10, trailAngle: trailAngle, testAngle: testAngle){
            print(true)
            if let neighbor = userLocation.node.neighbors.first {
                updateUserLocationTo(neighbor.location)
            }
            
        }else {
            print(false)
        }
    }
    
    func isCloseEnough(allowedErrorMargin: Double, trailAngle:Double, testAngle:Double) -> Bool {
        let error = fabs(( trailAngle - testAngle ) / trailAngle)
        
        print(error)
        
        if error < allowedErrorMargin {
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
        
        if annotations.count > 2 {
            annotations.removeLast()
            userLocation.coordinate = location
            if let nodeIndex = trailGraph.nodes.indexOf(userLocation.node.neighbors.first!) {
                userLocation.node = trailGraph.nodes[nodeIndex]
                annotations.append(userLocation)
                mapView.showAnnotations(annotations, animated: true)
                print("new Loc: \(userLocation.node.location)")
            }
        }
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
    
    func updateTrailGraph(coordinates: [CLLocationCoordinate2D]){
        if trailGraph == nil {
            trailGraph = TrailGraph()
        }
        
        for coord in coordinates {
            let trailNode = TrailNode()
            trailNode.location = coord
            if prevNode != nil {
                prevNode.neighbors.append(trailNode)
//                trailNode.neighbors.append(prevNode)
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

            if trailGraph.nodes.count == 2 {
                trailGraph.nodes.first!.neighbors.append(trailNode)
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

    func clearMap(sender: UIButton){
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(annotations)
        annotations.removeAll()
    }
    
    func showGameCenterLogin(sender: UIViewController) {
        self.presentViewController(sender, animated: true) { () -> Void in
            print("presented view controller")
        }
    }
    
}



