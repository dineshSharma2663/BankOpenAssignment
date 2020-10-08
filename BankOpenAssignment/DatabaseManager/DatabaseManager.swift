//
//  DatabaseManager.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 06/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//

import Foundation
import CoreData

fileprivate enum EntityTypes: String {
    case RouteInfo = "RoutesInfoEntity"
    case TrimTiming = "TripTimingEntity"
}

struct ScheduleReponseKeys {
    static let routeTimings = "routeTimings"
    static let routesInfo = "routeInfo"
}

fileprivate enum EntityAttibutes: String {
    case rank = "rank"
    case routeId = "routeId"
    case tripStartTime = "tripStartTime"
}

protocol DatabaseRequestProtocol: class {
    /// Get All Routes of Transport
    func getAllRoutes() -> Array<RoutesInfoEntity>
    /// Get All Trip Timings
    func getAllTripTimings() -> Array<TripTimingEntity>
    /// Get Trip Timings for Route id
    func getTripTimings(for routeId: String) ->  Array<TripTimingEntity>
    /// Sync Transport schedule
    func saveTransportSchedule(scheduleResponse: [String:AnyObject])
    /// Clear All Schedule Data
    func clearAllScheduleData()
}

class DatabaseManager {
    
    /// Share Instance of Database manager
    static let sharedInstance = DatabaseManager()
    /// Persistence manager
    fileprivate let persistenceManager: PersistenceManager!
    /// Main context instance
    fileprivate var mainContextInstance: NSManagedObjectContext!
    
    /// Initialiser
    init() {
        self.persistenceManager = PersistenceManager.sharedInstance
        self.mainContextInstance = persistenceManager.getMainContextInstance()
    }
}

extension DatabaseManager: DatabaseRequestProtocol {
    
    /// Save Transport schedule data
    /// - Parameter scheduleResponse: schedule response
    func saveTransportSchedule(scheduleResponse: [String:AnyObject]) {
        let minionManagedObjectContextWorker: NSManagedObjectContext =
            NSManagedObjectContext.init(concurrencyType: NSManagedObjectContextConcurrencyType.privateQueueConcurrencyType)
        minionManagedObjectContextWorker.parent = self.mainContextInstance
        /// Batch delete routes
        var matchingEpisodeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityTypes.RouteInfo.rawValue)
        var batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingEpisodeRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        /// Execute the request to de batch delete
        do {
            try minionManagedObjectContextWorker.execute(batchDeleteRequest)
        } catch {
            print("Error batch delete routes: \(error)\nCould not batch delete existing records.")
            return
        }
        /// Delete trip timings
        matchingEpisodeRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityTypes.TrimTiming.rawValue)
        batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: matchingEpisodeRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        /// Execute the request to de batch delete
        do {
            try minionManagedObjectContextWorker.execute(batchDeleteRequest)
        } catch {
            print("Error batch delete timings: \(error)\nCould not batch delete existing records.")
            return
        }
        
        let routingInfo = scheduleResponse[ScheduleReponseKeys.routesInfo] as? [[String:AnyObject]] ?? [[String:AnyObject]]()
        for (index, item) in routingInfo.enumerated() {
            let eventItem = NSEntityDescription.insertNewObject(forEntityName: EntityTypes.RouteInfo.rawValue,
                                                                into: minionManagedObjectContextWorker) as! RoutesInfoEntity
            /// Setting rank for each route so that we retrieve in same order from data base as from server
            eventItem.setValue(index, forKey: EntityAttibutes.rank.rawValue)
            var key = #keyPath(RoutesInfoEntity.id)
            eventItem.setValue(item[key], forKey: key)
            key = #keyPath(RoutesInfoEntity.tripDuration)
            eventItem.setValue(item[key], forKey: key)
            key = #keyPath(RoutesInfoEntity.destination)
            eventItem.setValue(item[key], forKey: key)
            key = #keyPath(RoutesInfoEntity.source)
            eventItem.setValue(item[key], forKey: key)
            key = #keyPath(RoutesInfoEntity.name)
            eventItem.setValue(item[key], forKey: key)
        }
        let routeTimings = scheduleResponse[ScheduleReponseKeys.routeTimings] as? [String:[[String:AnyObject]]] ?? [String:[[String:AnyObject]]]()
        
        /// traversing through all timings
        for (key, value) in routeTimings {
            /// traversing through all timings for a route
            for (index, item) in value.enumerated() {
                let eventItem = NSEntityDescription.insertNewObject(forEntityName: EntityTypes.TrimTiming.rawValue,
                                                                    into: minionManagedObjectContextWorker) as! TripTimingEntity
                eventItem.setValue(key, forKey: EntityAttibutes.routeId.rawValue)
                /// Setting rank for each route so that we retrieve in same order from data base as from server
                eventItem.setValue(index, forKey: EntityAttibutes.rank.rawValue)
                /// Traversing through all properties of route timing model
                    var key = #keyPath(TripTimingEntity.avaiable)
                    eventItem.setValue(item[key], forKey: key)
                    key = #keyPath(TripTimingEntity.totalSeats)
                    eventItem.setValue(item[key], forKey: key)
                    key = #keyPath(TripTimingEntity.tripStartTime)
                    let dateString = item[key] as? String ?? ""
                    let dateFormatter = Foundation.DateFormatter()
                    dateFormatter.dateFormat = BusScheduleDateFormatter.tripStartTime
                    let date = dateFormatter.date(from: dateString)
                    let calender = Calendar.current
                    let dateComponents = calender.dateComponents([.hour, .minute], from: date ?? Date())
                    let datefrom = calender.date(from: dateComponents)
                    eventItem.setValue(datefrom, forKey: key)
                
            }
        }
        /// Save current work on Minion workers
        self.persistenceManager.saveWorkerContext(minionManagedObjectContextWorker)
        
        /// Save and merge changes from Minion workers with Main context
        self.persistenceManager.mergeWithMainContext()
    }
    
    /// Clear All Schedule Data
    func clearAllScheduleData() {
        /// Delete all event items from persistance layer
        let routesItems = getAllRoutes()
        for item in routesItems {
            self.mainContextInstance.delete(item)
        }
        let timingsItems = getAllTripTimings()
        for item in timingsItems {
            self.mainContextInstance.delete(item)
        }
        /// Save and merge changes from Minion workers with Main context
        self.persistenceManager.mergeWithMainContext()
    }
    
    /// Get All Trip Timings
    /// - Returns: array of TripTimingEntity
    func getAllTripTimings() -> Array<TripTimingEntity> {
        return self.getTripTimings(for: Constants.kEmptyString)
    }
    
    /// Fetch Route specific transport timings
    /// - Parameter routeId: routeId
    /// - Returns: array of objects of TripTimingEntity
    func getTripTimings(for routeId: String) -> Array<TripTimingEntity> {
        var fetchedResults: Array<TripTimingEntity> = Array<TripTimingEntity>()
        /// Create request on Event entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityTypes.TrimTiming.rawValue)
        /// Create sort descriptor to sort retrieved Events after current Date & routeID
        if routeId != Constants.kEmptyString {
            let sortDescriptor = NSSortDescriptor(key: EntityAttibutes.rank.rawValue, ascending: true)
            let sortDescriptors = [sortDescriptor]
            let calender = Calendar.current
            let currentDateComponents = calender.dateComponents([.hour, .minute], from: Date())
            var datePredicate: NSPredicate
            if let today = calender.date(from: currentDateComponents) {
                datePredicate = NSPredicate(format: "%K >= %@ && \(EntityAttibutes.routeId.rawValue) = %@", #keyPath(TripTimingEntity.tripStartTime), today as CVarArg, routeId)
            } else {
                datePredicate = NSPredicate(format: "\(EntityAttibutes.routeId.rawValue) = %@", routeId)
            }
            fetchRequest.predicate = datePredicate
            fetchRequest.sortDescriptors = sortDescriptors
        }
        /// Execute Fetch request
        do {
            fetchedResults = try  self.mainContextInstance.fetch(fetchRequest) as! [TripTimingEntity]
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<TripTimingEntity>()
        }
        print("Timings retrieved: \(fetchedResults.count)")
        return fetchedResults
    }
    
    func getAllRoutes() -> Array<RoutesInfoEntity> {
        var fetchedResults: Array<RoutesInfoEntity> = Array<RoutesInfoEntity>()
        /// Create request on Event entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: EntityTypes.RouteInfo.rawValue)
        /// Create sort descriptor to sort retrieved Events by Date, ascending
        let sortDescriptor = NSSortDescriptor(key: EntityAttibutes.rank.rawValue,
                                              ascending: true)
        let sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        /// Execute Fetch request
        do {
            fetchedResults = try  self.mainContextInstance.fetch(fetchRequest) as! [RoutesInfoEntity]
        } catch let fetchError as NSError {
            print("retrieveById error: \(fetchError.localizedDescription)")
            fetchedResults = Array<RoutesInfoEntity>()
        }
        print("Routes retrieved: \(fetchedResults.count)")
        return fetchedResults
    }
}
