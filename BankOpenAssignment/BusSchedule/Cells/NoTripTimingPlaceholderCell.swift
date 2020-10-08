//
//  NoTripTimingPlaceholderCell.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 07/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//

import UIKit

class NoTripTimingPlaceholderCell: UITableViewCell, ReusableView, NibLoadableView {
    
    @IBOutlet private weak var placeHolderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        placeHolderLabel.text = BusScheduleStrings.noTimingsText
        
    }
}
