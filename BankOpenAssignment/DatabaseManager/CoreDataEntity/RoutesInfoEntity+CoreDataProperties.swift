//
//  RoutesInfoEntity+CoreDataProperties.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 07/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//
//

import Foundation
import CoreData


extension RoutesInfoEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<RoutesInfoEntity> {
        return NSFetchRequest<RoutesInfoEntity>(entityName: "RoutesInfoEntity")
    }

    @NSManaged public var destination: String?
    @NSManaged public var icon: String?
    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var rank: Int32
    @NSManaged public var source: String?
    @NSManaged public var tripDuration: String?

}
