//
//  TripTimingInfoTableCell.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 06/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//

import UIKit

class TripTimingInfoTableCell: UITableViewCell, NibLoadableView, ReusableView {
    
    @IBOutlet private weak var timingLabel: UILabel!
    @IBOutlet private weak var availabilityLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    
    /// Configure cell with timing displayable protocol
    /// - Parameter timingModel: timing displayable
    func configureCell(timingModel: TripTimingDisplayable?) {
        timingLabel.text = timingModel?.startTime
        availabilityLabel.text = timingModel?.availability
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
