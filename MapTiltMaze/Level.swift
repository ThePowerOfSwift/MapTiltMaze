//
//  Level.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/21/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//

import Foundation
import CoreData


class Level: NSManagedObject {

    var context: NSManagedObjectContext?
    
// Insert code here to add functionality to your managed object subclass
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        self.context = context
    }

    func loadLevels() -> [AnyObject] {
        var result = [AnyObject]()
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        do {
            result = try context!.executeFetchRequest(fetchRequest)
            let levelNumber = result.last?.valueForKey("levelNumber")
            print(levelNumber)
            print("result.count: \(result.count)")
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        return result
    }
    
    func addLevel(level level:Int16){
        let newLevel = NSManagedObject(entity: entity, insertIntoManagedObjectContext: context)
        newLevel.setValue(level as? AnyObject, forKey: "levelNumber")
        newLevel.setValue(true, forKey: "canPlay")
        newLevel.setValue(1000, forKey: "bestTime")
        
        newLevel.setValue(42.5240461369687, forKey: "startLatitude")
        newLevel.setValue(-112.207552427192, forKey: "startLongitude")
        newLevel.setValue(42.5001962490471, forKey: "endLatitude")
        newLevel.setValue(-112.166066045599, forKey: "endLongitude")
        
        do {
            try newLevel.managedObjectContext?.save()
            print("loadLevels().count: \(loadLevels().count)")
        } catch {
            print(error)
        }
    }
    
    func updateLevel(level level:Int16){

    }
    
    func readLevel(level level:Int16){
        
    }
    
    func removeLevel(){
        let fetchRequest = NSFetchRequest()
        fetchRequest.entity = entity
        do {
            let result:[AnyObject] = try context!.executeFetchRequest(fetchRequest)
            print("result.count: \(result.count)")
            if result.count > 0 {
                let levelNumber = result.first!.valueForKey("levelNumber")!
                print(levelNumber)
                print("=======")
            }else {
                print("empty")
                print("=======")
            }
            
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
    }
    
    func deleteAllObjects(result:[AnyObject]){
        for row in result {
            context?.deleteObject(row as! NSManagedObject)
            do {
                try context!.save()
            } catch {
                let saveError = error as NSError
                print(saveError)
            }
        }
    }
}
