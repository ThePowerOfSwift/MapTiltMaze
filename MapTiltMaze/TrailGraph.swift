//
//  TrailGraph.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/11/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import UIKit

class TrailGraph:NSObject {
    var nodes:[TrailNode]!
    
    override init() {
        super.init()
        nodes = [TrailNode]()
    }
}