//
//  Level+CoreDataProperties.swift
//  MapTiltMaze
//
//  Created by Stanley Chiang on 2/21/16.
//  Copyright © 2016 Stanley Chiang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Level {

    @NSManaged var bestTime: Double
    @NSManaged var canPlay: Bool
    @NSManaged var startLatitude: Double
    @NSManaged var levelNumber: Int16
    @NSManaged var startLongitude: Double
    @NSManaged var endLatitude: Double
    @NSManaged var endLongitude: Double

}
