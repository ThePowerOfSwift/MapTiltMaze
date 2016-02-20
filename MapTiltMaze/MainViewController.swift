//
//  MainViewController.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/12/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import MapKit

class MainViewController: UIViewController, MKMapViewDelegate, mapDelegate, overlayDelegate, trailGraphDelegate {

    var map:MapView!
    var overlay:OverlayView!
    var game:GameLevels!
    
    var currentTrailGraph:TrailGraph!
    var currentNode:TrailNode!
    var currentLevel:Int = 1

    var timer:Timer!
    
    let GameModel = [
        [CLLocationCoordinate2D(latitude: 42.5240461369687, longitude: -112.207552427192), CLLocationCoordinate2D(latitude: 42.5001962490471, longitude: -112.166066045599)],
        [CLLocationCoordinate2D(latitude: 43.5240461369687, longitude: -113.207552427192), CLLocationCoordinate2D(latitude: 43.5001962490471, longitude: -113.166066045599)],
        [CLLocationCoordinate2D(latitude: 44.5240461369687, longitude: -114.207552427192), CLLocationCoordinate2D(latitude: 44.5001962490471, longitude: -114.166066045599)],
        [CLLocationCoordinate2D(latitude: 46.5240461369687, longitude: -116.207552427192), CLLocationCoordinate2D(latitude: 46.5001962490471, longitude: -116.166066045599)],
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //load map
        map = MapView(frame: self.view.bounds)
        map.delegate = self
        map.mapdelegate = self
        self.view.addSubview(map)
        
        //add login and main menu
        overlay = OverlayView(frame: self.view.frame)
        overlay.delegate = self
        self.view.addSubview(overlay)
        overlay.initGameCenter()
        overlay.loadMainGameMenu()
        
        //init game
        game = GameLevels()
        currentTrailGraph = TrailGraph()
        currentTrailGraph.delegate = self
        currentLevel = 0
        currentNode = nil
        setLevel(level: GameModel.first!)
    }
    
    func setLevel(level level: [CLLocationCoordinate2D]){
        currentTrailGraph.convertArrayOfEndPointsIntoArrayOfCoordinates(level)
        for endpoint in level {
            map.pinLocation(coordinate: endpoint)
        }
    }
    
    func getLevel() -> Int {
        print(currentLevel)
        return currentLevel
    }
    
    func updateLevel(direction: Int) {
        let levelIndex = currentLevel + direction
        if GameModel.isInBounds(levelIndex) {
            map.clearMap()
            setLevel(level: GameModel[levelIndex])
            currentLevel = levelIndex
            overlay.levelValueLabel.text = "\(currentLevel+1)"
        } else {
            print("out of bounds")
        }
    }
    
    func play(sender: UIButton) {
        if timer == nil { timer = Timer() }
        
        if timer.startTime == nil {
            //switch to in game menu
            overlay.hideMainMenu()
            overlay.loadInGameMenu()
            map.processMotion()
            startTimer(sender)
            sender.setTitle("Stop", forState: UIControlState.Normal)
        }
    }

    func recordWin() {
        let timerReadOut:NSTimeInterval = timer.showCurrentElapsedTime()
        overlay.recordTime(level: currentLevel + 1, record: Int64(timerReadOut * 100))
    }
    
    func stopMotion() {
        timer.stop()
        map.stopMotion()
        overlay.startButton.setTitle("Start", forState: UIControlState.Normal)
    }
    
    func resetGame() {
        map.processMotion()
        timer.reset()
    }
    
    func startTimer(sender: UIButton){
        NSTimer.scheduledTimerWithTimeInterval(0.01, target: self,
            selector: "updateTimerReadOutLabel:", userInfo: sender, repeats: true)
        timer.start()
    }
    
    func updateTimerReadOutLabel(time: NSTimer){
        if let _ = timer.startTime {
            let timerReadOut = timer.convertElapsedTimeToString(timer.showCurrentElapsedTime())
            overlay.recordValueLabel.text = timerReadOut
        }else {
            time.invalidate()
        }
    }
    
    func didGetCoordinates(routeCoordinates: [CLLocationCoordinate2D]) {
        if !game.levels.isInBounds(currentLevel) {
            let trailGraph = TrailGraph()
            game.levels.append(trailGraph)
            let trailNodes = game.levels[currentLevel].convertArrayOfCoordinatesIntoArrayOfTrailNodes(routeCoordinates)
            game.levels[currentLevel].nodes = trailNodes
        }
        
        currentNode = game.levels[currentLevel].nodes.first!
        map.drawRoute(routeCoordinates)
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
        
        map.pinLocation(sender: sender)
    
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
        return currentNode
    }
    
    func getFirstNodeForGivenLevel() -> TrailNode {
        return currentNode
    }
    
    func getNextNode() -> TrailNode {
        print(currentNode.neighbors)
        return currentNode.neighbors.first!
    }
    
}

extension Array {
    func isInBounds(index: Int) -> Bool {
        if index < 0 || index > self.count - 1 {
            return false
        }
        return true
    }
}