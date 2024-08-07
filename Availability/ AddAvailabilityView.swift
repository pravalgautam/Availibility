//
//  ContentView.swift
//  Availability
//
//  Created by Praval Gautam on 06/08/24.
//
import SwiftUI

struct AddAvailabilityView: View {
    @State private var availability = [
        DayAvailability(day: "Sunday"),
        DayAvailability(day: "Monday"),
        DayAvailability(day: "Tuesday"),
        DayAvailability(day: "Wednesday"),
        DayAvailability(day: "Thursday"),
        DayAvailability(day: "Friday"),
        DayAvailability(day: "Saturday")
    ]
    
    @State private var isShowingTimeSlots = false
    
    // Filtering time slots
    
    private func filteredAvailability() -> [DayAvailability] {
        return availability.map { dayAvailability in
            let filteredSlots = dayAvailability.timeSlots.filter { slot in
                // Checking if any selected time slots overlap with the current slot
                AvailabilityManager.shared.selectedTimeSlots.contains { selectedSlot in
                    selectedSlot.overlaps(with: slot)
                }
            }
            return DayAvailability(day: dayAvailability.day, timeSlots: filteredSlots)
        }
    }


    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                        .padding(.leading, 16)
                    Spacer()
                    Text("Add Availability")
                        .font(.headline)
                        .foregroundColor(Color.white)
                        .padding().padding(.trailing, 30)
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 17)
                .background(.nav)
                
                DateScheduledOffComponent()
                    .frame(width: UIScreen.screenWidth - 20)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach($availability) { $dayAvailability in
                            DayRowComponent(dayAvailability: $dayAvailability)
                        }
                        .padding(.horizontal, 5)
                    }
                }
                .frame(width: UIScreen.screenWidth - 30)
                .padding(.top, 20)
                
                NavigationLink(destination: TimeSlotsListView(availability: filteredAvailability()), isActive: $isShowingTimeSlots) {
                    Button(action: {
                        isShowingTimeSlots = true
                        printSelectedTimeSlots()
                    }) {
                        Text("Update")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.btn)
                            .cornerRadius(50)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
            }
        }
    }
    func printSelectedTimeSlots() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        for timeSlot in AvailabilityManager.shared.selectedTimeSlots {
            let fromTime = dateFormatter.string(from: timeSlot.from)
            let toTime = dateFormatter.string(from: timeSlot.to)
            print("From: \(fromTime), To: \(toTime)")
        }
    }


}


struct DateScheduledOffComponent: View {
    var body: some View {
        HStack {
            ZStack{
                Circle()
                    .frame(width: 50)
                    .foregroundColor(.purple)
                Circle()
                    .frame(width: 30)
                    .foregroundColor(.green)
                    .overlay{
                        Image(systemName: "circle.hexagongrid")
                            .foregroundColor(.white)
                    }
            }
            
            Text("Dates Scheduled Off")
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.3), radius: 3, x: 0, y: 2)
    }
}

struct DayRowComponent: View {
    @Binding var dayAvailability: DayAvailability
    @ObservedObject var availabilityManager = AvailabilityManager.shared
    let columns = [
        GridItem(.flexible(minimum: 120, maximum: .infinity), alignment: .leading),
        GridItem(.adaptive(minimum: 180)),
        GridItem(.adaptive(minimum: 70)),
    ]
    let columnsTime = [
        GridItem(.flexible(minimum: 180, maximum: .infinity), alignment: .leading),
        GridItem(.adaptive(minimum: 280)),
        GridItem(.adaptive(minimum: 70)),
    ]
    
    @State private var showAlert = false
    @State private var warningMessages: [UUID: String] = [:]
    @State private var showToast = false
    
    var body: some View {
        VStack(alignment:.leading) {
            LazyVGrid(columns: columns, spacing: 20) {
                Text(dayAvailability.day)
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                
                Toggle("", isOn: $dayAvailability.isOn)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.green, lineWidth: 1)
                    )
                    .labelsHidden()
                    .padding(.horizontal, 30)
                
                Button(action: {
                    if !dayAvailability.addTimeSlot() {
                        showAlert = true
                    }
                }) {
                    Text("Add")
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                }
                .padding(.leading,30)
                .disabled(!dayAvailability.isOn)
                .alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Time Slot Occupied"),
                        message: Text("The selected time slot is already occupied. Please choose a different time."),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .padding(25)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.green, lineWidth: 1)
            )
            
            .overlay(
            ToastView(message: "Slot is occupied ", duration: 1, isPresented: $showToast)
            )
            
            if dayAvailability.isOn {
                ForEach(dayAvailability.timeSlots.indices.filter { !warningMessages.keys.contains(dayAvailability.timeSlots[$0].id) }, id: \.self) { index in
                    HStack {
                        VStack(alignment: .leading) {
                            LazyVGrid(columns: columnsTime, spacing: 10) {
                                HStack {
                                    Text("From:")
                                        .font(.subheadline)
                                        .padding(.trailing, -10)
                                    DatePicker("", selection: $dayAvailability.timeSlots[index].from, displayedComponents: .hourAndMinute)
                                        .font(.subheadline)
                                        .onChange(of: dayAvailability.timeSlots[index].from) { _ in
                                            updateAllAvailability()
                                        }
                                    Text("To:")
                                        .font(.subheadline)
                                        .padding(.trailing, -10)
                                    DatePicker("", selection: $dayAvailability.timeSlots[index].to, displayedComponents: .hourAndMinute)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .font(.subheadline)
                                        .onChange(of: dayAvailability.timeSlots[index].to) { _ in
                                            updateAllAvailability()
                                        }
                                }
                            }
                        }
                        .padding(.leading, 10)
                        .frame(width: UIScreen.screenWidth - 180)
                        
                        Button(action: {
                            withAnimation(.easeOut(duration: 0.5)) {
                                dayAvailability.removeTimeSlot(at: index)
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.red)
                                .cornerRadius(5)
                        }.padding(.leading,80)
                    }
                }
            }
        }
    }
    private func updateAllAvailability() {
        // Remove existing warnings
        warningMessages.removeAll()
        
        // Getting the time slots for the current day here
        let currentSlots = dayAvailability.timeSlots
        
        // Check for overlaps within the same day
        for (index, timeSlot) in currentSlots.enumerated() {
            // Checking if the current slot overlaps with any of the previous slots in the same day
            for previousIndex in 0..<index {
                let previousSlot = currentSlots[previousIndex]
                if previousSlot.overlaps(with: timeSlot) {
                    warningMessages[timeSlot.id] = "Slot is occupied"
                    showToast = false
                    break
                }
            }
        }
        dayAvailability.updateAvailability()
    }


}


struct DayAvailability: Identifiable {
    let id = UUID()
    let day: String
    var isOn = false
    var timeSlots: [TimeSlot] = []

    mutating func addTimeSlot() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let startTime = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now)!
        let endTime = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now)!
        
        let newSlot = TimeSlot(from: startTime, to: endTime)
        
        // Check for overlap with existing slots within the same day
        for slot in timeSlots {
            if slot.overlaps(with: newSlot) {
                return false
            }
        }
        
        // If no overlap within the same day, add the slot
        if AvailabilityManager.shared.addTimeSlot(newSlot) {
            timeSlots.append(newSlot)
            return true
        } else {
            return false
        }
    }
    
    mutating func removeTimeSlot(at index: Int) {
        let slotToRemove = timeSlots.remove(at: index)
        AvailabilityManager.shared.removeTimeSlot(slotToRemove)
    }
    
    mutating func updateAvailability() {
        for timeSlot in timeSlots {
            AvailabilityManager.shared.removeTimeSlot(timeSlot)
            AvailabilityManager.shared.addTimeSlot(timeSlot)
        }
    }
}
#Preview(body: {
    AddAvailabilityView()
})
