//
//  TrailGraph.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/11/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import MapKit

protocol trailGraphDelegate {
    func didGetCoordinates(routeCoordinates: [CLLocationCoordinate2D])
}

class TrailGraph:NSObject {
    var nodes:[TrailNode]!
    var prevNode:TrailNode!
    var delegate:trailGraphDelegate!
    
    override init() {
        super.init()
        nodes = [TrailNode]()
    }
    
    func convertArrayOfEndPointsIntoArrayOfCoordinates(endPoints: [CLLocationCoordinate2D]){
        var index = 0
        while index < endPoints.count - 1 {
            generateCoordinates(endPoints[index], endPoint: endPoints[index + 1])
            index += 1
        }
    }
    
    func generateCoordinates(startPoint:CLLocationCoordinate2D, endPoint:CLLocationCoordinate2D) {
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
            self.getRouteCoordinates(route)
        }
    }

    func getRouteCoordinates(route:MKRoute) {
        let pointCount = route.polyline.pointCount
        var routeCoordinates: [CLLocationCoordinate2D] = Array(count: pointCount, repeatedValue: CLLocationCoordinate2D())
        route.polyline.getCoordinates(&routeCoordinates, range: NSMakeRange(0,pointCount))
        delegate.didGetCoordinates(routeCoordinates)
    }
    
    func convertArrayOfCoordinatesIntoArrayOfTrailNodes(coordinates: [CLLocationCoordinate2D]) -> [TrailNode]{
        for coord in coordinates {
            let trailNode = TrailNode()
            trailNode.location = coord
            if prevNode != nil {
                prevNode.neighbors.append(trailNode)
            }
            
            if !nodes.contains(trailNode) {
                nodes.append(trailNode)
            } else {
                if let index = nodes.indexOf(trailNode) {
                    if !nodes[index].neighbors.contains(prevNode) {
                        nodes[index].neighbors.append(prevNode)
                    }
                }
            }
            
            if nodes.count == 2 {
                nodes.first!.neighbors.append(trailNode)
            }
            
            prevNode = trailNode
        }
        return nodes
    }
}