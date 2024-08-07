//
//  Models.swift
//  Availability
//
//  Created by Praval Gautam on 07/08/24.
//

import Foundation

struct TimeSlot: Identifiable {
    let id = UUID()
    var from: Date
    var to: Date
 
}
