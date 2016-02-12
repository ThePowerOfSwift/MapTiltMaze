//
//  TrailNode.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/11/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import MapKit

class TrailNode:NSObject {
    var location:CLLocationCoordinate2D!
    var neighbors:[TrailNode]!
    
    override init() {
        super.init()
        neighbors = [TrailNode]()
    }
}