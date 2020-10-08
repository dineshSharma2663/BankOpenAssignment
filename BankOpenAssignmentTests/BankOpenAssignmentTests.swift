//
//  BankOpenAssignmentTests.swift
//  BankOpenAssignmentTests
//
//  Created by Dinesh Kumar on 08/10/20.
//

import XCTest
@testable import BankOpenAssignment

class BankOpenAssignmentTests: XCTestCase {
    
    var viewModel: BusScheduleViewModelProtocol = BusScheduleViewModel()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        setUpData()
    }
    
    func setUpData() {
        viewModel.fetchBusSchedule { (result) in }
    }
    
    func testBusScheduleViewModel() {
        let selectedIndex = viewModel.getSelectedIndex()
        /// First time selected index should be zero
        XCTAssert(selectedIndex == 0)
    }
    
    func testUpdateSelectedIndex() {
        viewModel.updateSelectedRouteIndex(index: 2)
        let selectedIndex = viewModel.getSelectedIndex()
        XCTAssert(selectedIndex == 2)
    }
    
    func testGetRoutesCount() {
        let routesCount = viewModel.getNumberofRoutes()
        XCTAssert(routesCount == 5)
    }
    
    func testGetsRouteInf() {
        let routeInfo = viewModel.getRouteModelForIndex(index: 1)
        XCTAssertNotNil(routeInfo)
    }
    
    func testGetsTripTimingCount() {
        let tripTimingCount = viewModel.getTripCountForSelectedRoute()
        XCTAssert(tripTimingCount > 0)
    }
    
    func testGetTripTimingModel() {
        let tripTimingModel = viewModel.getTripTimingInfo(index: 0)
         XCTAssertNotNil(tripTimingModel)
    }
    
    func testRefreshBusSchedule() {
        viewModel.refreshBusSchedule()
        let selectedIndex = viewModel.getSelectedIndex()
        XCTAssert(selectedIndex == 0)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
