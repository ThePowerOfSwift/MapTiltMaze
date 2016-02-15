//
//  UserAnnotation.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/11/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import MapKit

class UserAnnotation: MKPointAnnotation {
    var imageName: String!
    var node:TrailNode!
    override init() {
        super.init()
        self.imageName = "loc"
    }
    
    func updateUserLocationTo(location:CLLocationCoordinate2D){
//        if let index = annotations.indexOf(userLocation) {
//            annotations.removeAtIndex(index)
            coordinate = location
//            if let nodeIndex = trailGraph.nodes.indexOf(node.neighbors.first!) {
//                node = trailGraph.nodes[nodeIndex]
//                annotations[index] = userLocation
//                mapView.showAnnotations(annotations, animated: true)
//            }
//        }
    }
}