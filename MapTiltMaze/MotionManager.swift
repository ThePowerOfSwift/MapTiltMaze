//
//  MotionManager.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/12/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import CoreMotion

class MotionManager: CMMotionManager {
    
    override init() {
        super.init()
    }
    
    func isCloseEnough(allowedErrorMargin: Double, trailAngle:Double, testAngle:Double) -> Bool {
        let error = fabs(( trailAngle - testAngle ) / trailAngle)
        
        print(error)
        
        if error < allowedErrorMargin {
            return true
        }
        
        return false
    }
    
    func convertCoordToDegrees(a a:Double, b:Double) -> Double{
        let rad = atan2(a, b)
        let deg = rad * 180 / M_PI
        
        return deg
    }

}
