//
//  MainViewController.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/12/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController, MKMapViewDelegate, mapDelegate, overlayDelegate {

    var map:MapView!
    var overlay:OverlayView!
    var game:GameLevels!
    
//    var annotations = [MKPointAnnotation]()
//    var trailGraph: TrailGraph!
//    var prevNode:TrailNode!
//    var fullRoute = [CLLocationCoordinate2D]()
//    var userLocation:UserAnnotation!
//    var testLocation:UserAnnotation!
//    var testpolyLine:MKPolyline!
//    var motionManager:CMMotionManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load map
        map = MapView(frame: self.view.bounds)
        map.delegate = self
        self.view.addSubview(map)
        
        //drop pin on long press
//        let longPressRec:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: "pinLocation:")
//        longPressRec.minimumPressDuration = 0.5
//        map.addGestureRecognizer(longPressRec)
        
        //add login and main menu
        overlay = OverlayView(frame: CGRectMake(0,self.view.frame.height - 50, self.view.frame.width, 50))
        overlay.delegate = self
        self.view.addSubview(overlay)
        overlay.initGameCenter()
        overlay.loadMainGameMenu()

        //init game
        game = GameLevels()
        let trailGraph = TrailGraph()
        let test = trailGraph.convertArrayOfEndPointsIntoArrayOfCoordinates(
            [CLLocationCoordinate2D(latitude: 42.5240461369687, longitude: -112.207552427192),
            CLLocationCoordinate2D(latitude: 42.5001962490471, longitude: -112.166066045599)])
        
        print(test)
        
        

    }
    
    func showGameCenterLogin(sender: UIViewController) {
        self.presentViewController(sender, animated: true) { () -> Void in
            print("presented view controller")
        }
    }
    
    func pinLocation(sender:UILongPressGestureRecognizer){
        if sender.state != .Began {
            return
        }
        
        map.pinLocation(sender)
    
        if map.annotations.count > 1 {
            map.drawRoute()
        }
    }
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.lineWidth = 3.0
        renderer.strokeColor = UIColor.blueColor()
        renderer.alpha = 0.5
        
        return renderer
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
    
    func getCurrentUserLocationNode() -> TrailNode {
        let trailNode = TrailNode()
//        trailNode.location =
//        trailNode.neighbors =
        return trailNode
    }
}
