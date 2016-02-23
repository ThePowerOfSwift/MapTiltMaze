//
//  UserDefaultsManager.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/22/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import Foundation

class UserDefaultsManager: NSObject {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    func createLevel(levelName levelName:String, level:[String:AnyObject]) {
        //should guard against levels that don't have required keys such as level number or maybe insert those
        
        defaults.setObject(level, forKey: levelName)
    }
    
    func readLevel(levelNumber levelNumber: Int) -> [String:AnyObject]? {
        let levelString = convertLevelNumberToLevelName(levelNumber)
        return defaults.objectForKey(levelString) as? [String:AnyObject]
    }

    func updateLevel(levelNumber levelNumber: Int, toUpdate:[String:AnyObject]){
        let levelString = convertLevelNumberToLevelName(levelNumber)
        
        if var levelOne: [String:AnyObject] = defaults.objectForKey(levelString) as? [String:AnyObject] {
            print(levelOne)
            levelOne.updateValue(500, forKey: "bestTime")
            
            if let levelWon = defaults.objectForKey(levelString) {
                print(levelWon)
            }
        }
    }

    func deleteLevel(levelNumber levelNumber: Int){
        let levelString = convertLevelNumberToLevelName(levelNumber)
        defaults.removeObjectForKey(levelString)
    }
    
    func convertLevelNumberToLevelName(levelNumber:Int) -> String{
        return "level\(levelNumber)"
    }
    
}

/*


let defaults = NSUserDefaults.standardUserDefaults()
let level1: [String:AnyObject] = ["levelNumber":1, "canPlay": true, "bestTime": 1000, "startLatitude": -40.0, "startLongitude": -110.0, "endLatitude": -41.0, "endLongitude": -111.0]
defaults.setObject(level1, forKey: "level1")

if var levelOne: [String:AnyObject] = defaults.objectForKey("level1") as? [String:AnyObject] {
print(levelOne)
levelOne.updateValue(500, forKey: "bestTime")
defaults.setObject(levelOne, forKey: "level1")

if let levelWon = defaults.objectForKey("level1") {
print(levelWon)
}

}

print("testing user defaults")

*/