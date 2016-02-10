//
//  ViewController.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/9/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    var mapView:MKMapView!
    var annotations = [MKPointAnnotation]()
    var fullRoute = [CLLocationCoordinate2D]()
    
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
        
//        if annotations.count > 1 {
//            let first = annotations.first!.coordinate
//            let second = annotations.last!.coordinate
//            drawDirection(first, endPoint: second)
//        }
        
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
            let routeCoordinates:[CLLocationCoordinate2D] = self.getRouteCoordinates(route)
            self.fullRoute += routeCoordinates
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.AboveRoads)
        }
    }
    
    func getRouteCoordinates(route:MKRoute) -> [CLLocationCoordinate2D]{
        let pointCount = route.polyline.pointCount
        var routeCoordinates: [CLLocationCoordinate2D] = Array(count: pointCount, repeatedValue: CLLocationCoordinate2D())
        route.polyline.getCoordinates(&routeCoordinates, range: NSMakeRange(0,pointCount))
        return routeCoordinates
    }

}

