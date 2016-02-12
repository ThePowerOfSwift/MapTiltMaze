//
//  UserAnnotation.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/11/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit
import MapKit

class UserAnnotation: MKPointAnnotation {
    var imageName: String!
    var node: TrailNode!
    
    override init() {
        super.init()
    }
}