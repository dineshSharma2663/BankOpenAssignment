//
//  TripTimingEntity+CoreDataProperties.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 07/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//
//

import Foundation
import CoreData


extension TripTimingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TripTimingEntity> {
        return NSFetchRequest<TripTimingEntity>(entityName: "TripTimingEntity")
    }

    @NSManaged public var avaiable: Int32
    @NSManaged public var rank: Int32
    @NSManaged public var routeId: String?
    @NSManaged public var totalSeats: Int32
    @NSManaged public var tripStartTime: Date?

}
