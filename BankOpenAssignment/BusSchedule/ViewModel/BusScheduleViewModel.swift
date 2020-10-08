//
//  BusScheduleViewModel.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 06/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//

import Foundation

enum AppRequestError: Error {
    case parseError
    case fileNotFound
}

protocol BusScheduleViewModelDelegate: class {
    /// refresh UI in controller class
    func refreshUI()
}

protocol BusScheduleViewModelProtocol {
    /// delegate to refresh UI
    var delegate: BusScheduleViewModelDelegate? { get set }
    /// Update Selected Route Index called from view class
    func updateSelectedRouteIndex(index: Int)
    /// Getting selected route index
    func getSelectedIndex() -> Int
    /// fetch bus schedule from local json file or remote
    func fetchBusSchedule(completion: @escaping (Result<Bool, Error>) -> Void)
    /// refresh bus schedule every one minute
    func refreshBusSchedule()
    /// Returns number of routes of a schedule
    func getNumberofRoutes() -> Int
    /// Get Route displayable model for index
    func getRouteModelForIndex(index: Int) -> RouteDisplayable?
    /// return trip timings count for a selected route
    func getTripCountForSelectedRoute() -> Int
    /// get array of trip timing displayable model
    func getRouteTimings() -> [TripTimingDisplayable]?
    /// Returns trip timing displaybale model for an inda
    func getTripTimingInfo(index: Int)-> TripTimingDisplayable?
}

class BusScheduleViewModel {
    
    /// BusScheduleViewModelDelegate to update UI
    weak var delegate: BusScheduleViewModelDelegate?
    /// Selected route index
    private var selectedRouteIndex: Int = -1
    /// DatabaseRequestProtocol instance
    private var databaseManager: DatabaseRequestProtocol = DatabaseManager.sharedInstance
    
    /// Routes displayable array
    private var routesDisplayable: [RouteDisplayable]? {
        didSet {
            selectedRouteIndex = selectedRouteIndex == -1 ? 0 : selectedRouteIndex
            self.delegate?.refreshUI()
        }
    }
    
    /// Refresh Displaybale routes from Data base
    private func refreshRoutesFromDatabase() {
        let routes = DatabaseManager.sharedInstance.getAllRoutes()
        var routesDisplayableArray = [RouteDisplayable]()
        for data in routes {
            if let routeId = data.id {
                let tripTiming = databaseManager.getTripTimings(for: routeId)
                var tripDisplayTimings = [TripTimingDisplayable]()
                for timings in tripTiming {
                    let tripTimingDisplayModel = TripTimingDisplayModel(data: timings)
                    tripDisplayTimings.append(tripTimingDisplayModel)
                }
                let routeDisplaymodel = RouteInfoDisplayModel(data: data, tripTimingDisplay: tripDisplayTimings)
                routesDisplayableArray.append(routeDisplaymodel)
            }
        }
        self.routesDisplayable = routesDisplayableArray
    }
    
}

extension BusScheduleViewModel: BusScheduleViewModelProtocol {
    
    /// Fetch bus schedule from json or from network here
    /// - Parameter completion: completion block
    func fetchBusSchedule(completion: @escaping (Result<Bool, Error>) -> Void) {
        if let url = Bundle.main.url(forResource: Constants.BusSchedule.fileName, withExtension: Constants.BusSchedule.fileExtension) {
            do {
                let data = try Data(contentsOf: url)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? [String: AnyObject] {
                    databaseManager.saveTransportSchedule(scheduleResponse: jsonResult)
                    refreshRoutesFromDatabase()
                }
                completion(.success(true))
            } catch {
                print("error: \(error)")
                completion(.failure(error))
            }
        } else {
            completion(.failure(AppRequestError.fileNotFound))
        }
    }
    
    /// Update Selected route indes
    /// - Parameter index: index
    func updateSelectedRouteIndex(index: Int) {
        selectedRouteIndex = index
        self.delegate?.refreshUI()
    }
    
    /// Get Selected route index
    /// - Returns: int
    func getSelectedIndex() -> Int {
        return self.selectedRouteIndex
    }
    
    /// Refresh Bus Schedule every minute
    func refreshBusSchedule() {
        fetchBusSchedule { (result) in
            
        }
    }
    
    /// Get number of routes
    func getNumberofRoutes() -> Int {
        return self.routesDisplayable?.count ?? 0
    }
    
    /// Get route model for index
    func getRouteModelForIndex(index: Int) -> RouteDisplayable? {
        return self.routesDisplayable?[index]
    }
    
    /// Get selected route timing
    func getRouteTimings() -> [TripTimingDisplayable]? {
        let routeInfo = self.getRouteModelForIndex(index: selectedRouteIndex)
        return routeInfo?.tripInfo
    }
    
    /// Get Trip timings count for selected route
    func getTripCountForSelectedRoute() -> Int {
        let totalCount = self.getRouteTimings()?.count ?? 0
        return totalCount
    }
    
    /// Get trip timing display model for index
    func getTripTimingInfo(index: Int)-> TripTimingDisplayable? {
        return self.getRouteTimings()?[index]
    }
}
