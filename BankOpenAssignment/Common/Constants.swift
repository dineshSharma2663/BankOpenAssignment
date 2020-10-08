//
//  Constants.swift
//  BankOpenTask
//
//  Created by Dinesh Kumar on 07/10/20.
//  Copyright © 2020 Dinesh Kumar. All rights reserved.
//

import Foundation

struct Constants {
    static let kEmptyString: String = ""
    static let kNextLine: String = "\n"
    
    struct BusSchedule {
        static let fileName = "BusSchedule"
        static let fileExtension = "json"
    }
}

struct BusScheduleDateFormatter {
    static let tripStartTime: String = "HH:mm"
}
