//
//  MapView.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/12/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import MapKit

protocol mapDelegate {
//    func updateTrailGraph()
    func getFirstNodeForGivenLevel() -> TrailNode
    func getCurrentUserLocationNode() -> TrailNode
    func getNextNode() -> TrailNode
    func stopMotion()
}

class MapView: MKMapView {
    
    var motionManager:MotionManager!
    var mapdelegate: mapDelegate!
    var userAnnotation:UserAnnotation!
    
    var testLocation:UserAnnotation!
    var testpolyLine:MKPolyline!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pinLocation(sender sender:UILongPressGestureRecognizer){
        let tappedPoint:CGPoint = sender.locationInView(self)
        let tappedCoordinate:CLLocationCoordinate2D = self.convertPoint(tappedPoint, toCoordinateFromView: self)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = tappedCoordinate
        self.addAnnotation(annotation)
        self.showAnnotations(annotations, animated: true)
    }
    
    func pinLocation(coordinate coordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.addAnnotation(annotation)
        self.showAnnotations(annotations, animated: true)
    }
    
    func drawRoute(){
        self.removeOverlays(self.overlays)

        var coordinates = [CLLocationCoordinate2D]()
        for annotation in annotations {
            coordinates.append(annotation.coordinate)
        }

        let polyLine:MKPolyline = MKPolyline(coordinates: &coordinates, count: coordinates.count)

        let padding:CGFloat = 50.0
        let visibleMapRect = self.mapRectThatFits(polyLine.boundingMapRect, edgePadding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        self.setRegion(MKCoordinateRegionForMapRect(visibleMapRect), animated: true)
        
        var index = 0
        while index < annotations.count - 1 {
            drawDirection(annotations[index].coordinate, endPoint: annotations[index + 1].coordinate)
            index += 1
        }
    }
    
    func drawRoute(var routeCoordinates: [CLLocationCoordinate2D]){
        self.removeOverlays(self.overlays)
        
        let padding:CGFloat = 50.0
        let polyline:MKPolyline = MKPolyline(coordinates: &routeCoordinates, count: routeCoordinates.count)
        let visibleMapRect = mapRectThatFits(polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        setRegion(MKCoordinateRegionForMapRect(visibleMapRect), animated: true)
        addOverlay(polyline, level: MKOverlayLevel.AboveRoads)
        
        adduserPin()
//        var index = 0
//        let endpoints = annotations.count
//        while index < endpoints - 1 {
//            drawDirection(polyline)
//            index += 1
//        }
    }
    
    func adduserPin(){
        
        userAnnotation = UserAnnotation()
        let startNode = mapdelegate.getCurrentUserLocationNode()
        userAnnotation.node = startNode
        userAnnotation.updateUserLocationTo(location: startNode.location)
        self.addAnnotation(self.userAnnotation)
        self.showAnnotations(self.annotations, animated: true)
        
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
//                self.updateTrailGraph(routeCoordinates)
                self.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
                
                if self.annotations.count > 1 {
                    self.userAnnotation = UserAnnotation()
                    self.userAnnotation.updateUserLocationTo(location: self.annotations.first!.coordinate)
                    self.addAnnotation(self.userAnnotation)
                    self.showAnnotations(self.annotations, animated: true)
                    
                    self.processMotion()
                }
            }
        }
    }
    
    func processMotion(){
        self.motionManager = MotionManager()
        self.motionManager.accelerometerUpdateInterval = 0.1

        self.motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: { (accelerometerData, error) -> Void in
            if error == nil {
                self.processAccelerationData(dX: accelerometerData!.acceleration.x, dY: accelerometerData!.acceleration.y)
            } else {
                print(error!)
            }
        })
    }
    
    func stopMotion(){
        motionManager.stopAccelerometerUpdates()
    }
    
    func getRouteCoordinates(route:MKRoute) -> [CLLocationCoordinate2D]{
        let pointCount = route.polyline.pointCount
        var routeCoordinates: [CLLocationCoordinate2D] = Array(count: pointCount, repeatedValue: CLLocationCoordinate2D())
        route.polyline.getCoordinates(&routeCoordinates, range: NSMakeRange(0,pointCount))
        return routeCoordinates
    }
    
    func processAccelerationData(dX dX:Double, dY: Double){
        
        if userAnnotation.node.neighbors.first == nil {
            print("you won")
            mapdelegate.stopMotion()
            return
        }

        let currentNode = userAnnotation.node
        let nextNode = currentNode.neighbors.first!
        
        let firstLoc:CLLocationCoordinate2D = currentNode.location
        let secondLoc:CLLocationCoordinate2D = nextNode.location
    
//        let testLoc:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: (((firstLoc.latitude) as Double) + dY) as CLLocationDegrees, longitude: (((firstLoc.longitude) as Double) + dX) as CLLocationDegrees)
//        updateTestLocationTo(testLoc)
//        drawTestLine(a: firstLoc, b: testLoc)
        
        let trailNodeOffsetX = secondLoc.latitude - firstLoc.latitude
        let trailNodeOffsetY = secondLoc.longitude - firstLoc.longitude
        
        var trailAngle = motionManager.convertCoordToDegrees(a: trailNodeOffsetY as Double, b: trailNodeOffsetX as Double)
        var testAngle = motionManager.convertCoordToDegrees(a: dX, b: dY)
        
        //This ensures we don't get a divide by zero error
        if trailAngle == 0 {trailAngle = 0.1}
        if testAngle == 0 {testAngle = -0.1}
        
        if motionManager.isCloseEnough(0.25, trailAngle: trailAngle, testAngle: testAngle){
            print(true)
            userAnnotation.updateUserLocationTo(node: nextNode)
        } else {
            print(false)
        }
    }

    func updateTestLocationTo(location:CLLocationCoordinate2D){
        if testLocation == nil {
            testLocation = UserAnnotation()
            testLocation.imageName = "loc"
        }

        testLocation.coordinate = location
        self.addAnnotation(testLocation)
        self.showAnnotations(annotations, animated: true)
        
    }
    
    func drawTestLine(a a:CLLocationCoordinate2D, b:CLLocationCoordinate2D){
        var coordinates = [CLLocationCoordinate2D]()
        coordinates.append(a)
        coordinates.append(b)
        if testpolyLine != nil {
            self.removeOverlay(testpolyLine)
        }
        testpolyLine = MKPolyline(coordinates: &coordinates, count: coordinates.count)
        
        self.addOverlay(testpolyLine)
    }
    
    func clearMap(){
        removeOverlays(overlays)
        removeAnnotations(annotations)
    }
}
