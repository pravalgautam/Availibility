//
//  TimeSlotView.swift
//  Availability
//
//  Created by Praval Gautam on 07/08/24.
//
import SwiftUI

struct TimeSlotsListView: View {
    var availability: [DayAvailability]
    
    private let colors: [Color] = [
        Color.red.opacity(0.7),
        Color.green.opacity(0.7),
        Color.blue.opacity(0.7),
        Color.orange.opacity(0.7),
        Color.purple.opacity(0.7),
        Color.yellow.opacity(0.7)
    ]
    
    private let gridItems = [
        GridItem(.adaptive(minimum: 160), spacing: 5),
        GridItem(.adaptive(minimum: 160), spacing: 5),
        GridItem(.adaptive(minimum: 160), spacing: 5)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: gridItems, spacing: 16) {
                    ForEach(availability.filter { !$0.timeSlots.isEmpty }) { dayAvailability in
                        Section(header: HStack {
                            Text(dayAvailability.day)
                                .font(.headline)
                                .padding(.bottom, 8)
                            Spacer()
                        }) {
                            ForEach(dayAvailability.timeSlots.indices) { index in
                                let slot = dayAvailability.timeSlots[index]
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("\(formattedDate(slot.from))")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                    Text("to")
                                        .foregroundColor(.white)
                                        .padding(.leading, 20)
                                        .font(.system(size: 18))
                                    Text("\(formattedDate(slot.to))")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(colors[index % colors.count]) // Apply different colors with opacity
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitle("All Time Slots", displayMode: .inline)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
