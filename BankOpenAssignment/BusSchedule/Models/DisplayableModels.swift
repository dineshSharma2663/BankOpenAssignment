//
//  DisplayableModels.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 07/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//

import Foundation

protocol RouteDisplayable {
    /// Route Id unique to each route
    var routeId: String { get }
    /// Route info display text string comprising of source, destination
    var routePath: String? { get }
    /// trip duration
    var tripDuration: String? { get }
    /// Bus name
    var transportName: String? { get }
    /// Trip timings array
    var tripInfo: [TripTimingDisplayable]? { get }
}

protocol TripTimingDisplayable {
    /// Start time display text
    var startTime: String? { get }
    /// Available & total seats display text
    var availability: String? { get }
}

/// Struct displayable model used by Routes View to set data on UI
struct RouteInfoDisplayModel: RouteDisplayable {
    /// Route Id unique to each route
    var routeId: String
    /// Route info display text string comprising of source, destination
    var routePath: String?
    /// Trip timings array
    var tripInfo: [TripTimingDisplayable]?
    /// Trip duration
    var tripDuration: String?
    /// Bus name
    var transportName: String?
    
    /// Route display model initialiser
    /// - Parameters:
    ///   - data: database object fo route
    ///   - tripTimingDisplay: triptiming array for this route
    init(data: RoutesInfoEntity, tripTimingDisplay: [TripTimingDisplayable]?) {
        let busName = data.name ?? Constants.kEmptyString
        let route = (data.source ?? Constants.kEmptyString) + " - " + (data.destination ?? Constants.kEmptyString)
        let duration = data.tripDuration ?? Constants.kEmptyString
        self.tripDuration = duration
        transportName = busName
        routePath = route
        routeId = data.id ?? Constants.kEmptyString
        tripInfo = tripTimingDisplay
    }
}

/// Struct displayable model used by Trip Timing view to set data on UI
struct TripTimingDisplayModel: TripTimingDisplayable {
    /// start time display text
    var startTime: String?
    /// availability & total seats display text
    var availability: String?
  
    /// Intialiser of TimingDisplayModel
    /// - Parameter data: TripTimingEntity
    init(data: TripTimingEntity) {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: data.tripStartTime!)
        startTime = "\(BusScheduleStrings.tripStartTime): " + dateString
        let totalSeats = data.totalSeats
        let availableSeats =  data.avaiable
        availability = "\(BusScheduleStrings.availability): \(availableSeats)/\(totalSeats)"
    }
}
