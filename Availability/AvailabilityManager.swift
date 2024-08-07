//
//  AvailabilityManager.swift
//  Availability
//
//  Created by Praval Gautam on 06/08/24.
//

import SwiftUI
import Combine

class AvailabilityManager: ObservableObject {
    static let shared = AvailabilityManager()
    @Published var selectedTimeSlots: [TimeSlot] = []

    func addTimeSlot(_ timeSlot: TimeSlot) -> Bool {
        if !isSlotOverlappingWithinSameDay(newSlot: timeSlot) {
            selectedTimeSlots.append(timeSlot)
            return true
        }
        return false
    }
    func getTimeSlots(for day: String) -> [TimeSlot] {
        return selectedTimeSlots.filter { slot in
            let slotDay = Calendar.current.weekdaySymbols[Calendar.current.component(.weekday, from: slot.from) - 1]
            return slotDay == day
        }
    }


    func isSlotOverlappingWithinSameDay(newSlot: TimeSlot) -> Bool {
        let dayTimeSlots = selectedTimeSlots.filter { Calendar.current.isDate($0.from, equalTo: newSlot.from, toGranularity: .day) }
        
        for existingSlot in dayTimeSlots {
            if existingSlot.overlaps(with: newSlot) {
                return true
            }
        }
        return false
    }

    func removeTimeSlot(_ timeSlot: TimeSlot) {
        if let index = selectedTimeSlots.firstIndex(where: { $0.id == timeSlot.id }) {
            selectedTimeSlots.remove(at: index)
        }
    }
}



extension TimeSlot {
    func overlaps(with other: TimeSlot) -> Bool {
        return (self.from < other.to && self.to > other.from) || (other.from < self.to && other.to > self.from)
    }
}
