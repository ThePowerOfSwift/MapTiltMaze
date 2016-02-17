//
//  Timer.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/16/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import Foundation

class Timer {
    var startTime:NSDate?
    
    func showCurrentElapsedTime() -> NSTimeInterval{
        if let startTime = startTime {
            return -startTime.timeIntervalSinceNow
        }
        return 0
    }
    
    func convertElapsedTimeToString(elapsedTime:NSTimeInterval) -> String {
        return "\(Int(elapsedTime / 60)) : \(Int(elapsedTime % 60)) : \(Int(elapsedTime * 10 % 10))"
    }
    
    func start(){
        startTime = NSDate()
    }
    
    func stop(){
        startTime = nil
    }
    
    func reset(){
        stop()
        start()
    }
}