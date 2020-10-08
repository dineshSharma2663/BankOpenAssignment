//
//  BusScheduleView.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 06/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//

import UIKit

/// BusScheduleViewable protocol
protocol BusScheduleViewable: class {
    /// show loading
    func showLoading()
    /// hide loading
    func hideLoading()
    /// Refresh UI method  to refresh UI
    func refreshUI()
    /// to set View Model for BusScheduleView
    func setViewModel(viewModel: BusScheduleViewModelProtocol)
}

class BusScheduleView: UIView {
    
    /// BusScheduleViewModelProtocol instance to get data to display on UI
    private var viewModel: BusScheduleViewModelProtocol!
    
    struct Constants {
        static let collectionCellWidth: CGFloat = 250
        static let interItemSpacing:CGFloat = 14
    }

    // MARK: - Referencing Outlets
    @IBOutlet private var activityLoader: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 60
            tableView.rowHeight = UITableView.automaticDimension
            tableView.tableFooterView = UIView(frame: CGRect.zero)
            tableView.register(TripTimingInfoTableCell.self)
            tableView.register(NoTripTimingPlaceholderCell.self)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    @IBOutlet private weak var collectionView: UICollectionView! {
        didSet {
            collectionView.register(RouteInfoCollectionViewCell.self)
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.delegate = self
            collectionView.dataSource = self
        }
    }
    
}

//MARK: - BusScheduleViewable
extension BusScheduleView: BusScheduleViewable {
    
    func showLoading() {
        activityLoader.startAnimating()
    }
    
    func hideLoading() {
        activityLoader.stopAnimating()
    }
    
    func refreshUI() {
        hideLoading()
        UIView.transition(with: tableView, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }, completion: nil)
    }
    
    func setViewModel(viewModel: BusScheduleViewModelProtocol) {
        self.viewModel = viewModel
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension BusScheduleView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getTripCountForSelectedRoute() == 0 ? 1 : self.viewModel.getTripCountForSelectedRoute()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard self.viewModel.getTripCountForSelectedRoute() != 0 else {
            let cell: NoTripTimingPlaceholderCell = tableView.dequeueReusableCell(for: indexPath)
            return cell
        }
        let cell: TripTimingInfoTableCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configureCell(timingModel: self.viewModel.getTripTimingInfo(index: indexPath.row) )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard self.viewModel.getTripCountForSelectedRoute() != 0 else {
            return tableView.frame.size.height
        }
        return UITableView.automaticDimension
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDataSource
extension BusScheduleView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return Constants.interItemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: Constants.collectionCellWidth, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.getNumberofRoutes()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: RouteInfoCollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        cell.setSelectedlayout(isSelected: indexPath.row == viewModel.getSelectedIndex())
        cell.configureCell(routeInfo: viewModel.getRouteModelForIndex(index: indexPath.row))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.viewModel.updateSelectedRouteIndex(index: indexPath.row)
        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
    }
    
}

