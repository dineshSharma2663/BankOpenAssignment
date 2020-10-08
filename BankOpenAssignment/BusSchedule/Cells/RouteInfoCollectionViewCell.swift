//
//  RouteInfoCollectionViewCell.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 06/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//

import UIKit

class RouteInfoCollectionViewCell: UICollectionViewCell, NibLoadableView, ReusableView {

    @IBOutlet private weak var busNameLabel: UILabel!
    @IBOutlet private weak var routePathLabel: UILabel!
    @IBOutlet private weak var tripDurationLabel: UILabel!
    @IBOutlet private weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backView.layer.cornerRadius = 5
        backView.clipsToBounds = true
    }
    
    /// configure cell layout with displayable protocol
    /// - Parameter routeInfo: route displayable
    func configureCell(routeInfo: RouteDisplayable?) {
        busNameLabel.text = routeInfo?.transportName
        routePathLabel.text = routeInfo?.routePath
        tripDurationLabel.text = routeInfo?.tripDuration
    }
    
    /// set layout for selected & unselected mode
    /// - Parameter isSelected: bool
    func setSelectedlayout(isSelected: Bool) {
        if isSelected {
            backView.backgroundColor = UIColor.systemBlue
            busNameLabel.textColor = UIColor.white
            routePathLabel.textColor = UIColor.white
            tripDurationLabel.textColor = UIColor.white
        } else {
            if #available(iOS 13.0, *) {
                backView.backgroundColor = UIColor.secondarySystemBackground
                busNameLabel.textColor = UIColor.label
                routePathLabel.textColor = UIColor.label
                tripDurationLabel.textColor = UIColor.label
            } else {
                // Fallback on earlier versions
                busNameLabel.textColor = UIColor.black
                routePathLabel.textColor = UIColor.black
                tripDurationLabel.textColor = UIColor.black
                backView.backgroundColor = UIColor.groupTableViewBackground
            }
        }
    }
}
