//
//  BusSchedulesViewController.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 06/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//

import UIKit

class BusSchedulesViewController: UIViewController {

    /// BusScheduleViewModelProtocol instance used to fetch schedule of transport & view model for ui update
    private var viewModel: BusScheduleViewModelProtocol = BusScheduleViewModel()
    /// Bus schedule view instance
    private var viewable: BusScheduleViewable?
    /// Schedule refresh timer
    private var refreshTimer: Timer?
    /// Bus Schedule Refresh Time interval
    private let refreshTimeInterval: TimeInterval = 60

    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = BusScheduleStrings.busscheduleTitle
        viewModel.delegate = self
        configureScheduleView()
        viewable?.showLoading()
        viewModel.fetchBusSchedule { [weak self] (result) in
            self?.viewable?.hideLoading()
            switch result {
            case .success( _):
                break
            case .failure( _):
                self?.showError(message: "An Error occurred. Please try again later.")
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
        stopTimer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
        startRefreshSchedule()
    }
    
    private func addObservers(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(applicationDidBecomeActive),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didEnterBackgroundNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
    }
    
    @objc func applicationDidBecomeActive() {
        /// applicationDidBecomeActive
        viewModel.refreshBusSchedule()
        startRefreshSchedule()
    }
    
    @objc func didEnterBackground() {
        /// didEnterBackground
        stopTimer()
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    /// Configure Bus Schedule View
    private func configureScheduleView() {
        if let selfView = self.view as? BusScheduleViewable {
            selfView.setViewModel(viewModel: viewModel)
            viewable = selfView
            selfView.refreshUI()
        }
    }
    
    /// Start Repetive refresh of Schedule
    private func startRefreshSchedule() {
        if refreshTimer == nil {
            refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshTimeInterval, repeats: true) { [weak self] (timer) in
                self?.viewModel.refreshBusSchedule()
            }
        }
    }
    
    private func stopTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

}

extension BusSchedulesViewController : BusScheduleViewModelDelegate {
    
    func refreshUI() {
        viewable?.refreshUI()
    }
}
