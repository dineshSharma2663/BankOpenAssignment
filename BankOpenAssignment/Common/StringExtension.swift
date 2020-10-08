//
//  StringExtension.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 07/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//

import Foundation

extension String {
    
    var localised: String {
        return NSLocalizedString(self, comment: "")
    }
}
