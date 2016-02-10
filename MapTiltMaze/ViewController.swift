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
        drawPolyline()
        
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
}

