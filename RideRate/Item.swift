//
//  Item.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 07..
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
