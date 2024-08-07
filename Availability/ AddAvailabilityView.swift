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
        DayAvailability(day: "Wednesday")
    ]

    var body: some View {
        NavigationView {
            VStack {
                DateScheduledOffComponent()
                    .padding()

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach($availability) { $dayAvailability in
                            DayRowComponent(dayAvailability: $dayAvailability)
                        }
                    }
                    .padding(.horizontal)
                }

                Button(action: {
                    // Update action
                }) {
                    Text("Update")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.top)
            }
            .navigationBarTitle("Add Availability", displayMode: .inline)
        }
    }
}

struct DateScheduledOffComponent: View {
    var body: some View {
        HStack {
            Image(systemName: "calendar")
                .resizable()
                .frame(width: 30, height: 30)
                .padding()
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)

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
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

struct DayRowComponent: View {
    @Binding var dayAvailability: DayAvailability

    var body: some View {
        VStack {
            HStack {
                Text(dayAvailability.day)
                    .fontWeight(.medium)
                    .foregroundColor(.black)

                Spacer()

                Toggle("", isOn: $dayAvailability.isOn)
                    .labelsHidden()

                Button(action: {
                    dayAvailability.addTimeSlot()
                }) {
                    Text("Add")
                        .fontWeight(.bold)
                        .foregroundColor(Color.green)
                }
                .disabled(!dayAvailability.isOn)
            }

            if dayAvailability.isOn {
                ForEach(dayAvailability.timeSlots.indices, id: \.self) { index in
                    HStack {
                        TextField("From", text: $dayAvailability.timeSlots[index].from)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)

                        TextField("To", text: $dayAvailability.timeSlots[index].to)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)

                        Spacer()

                        Button(action: {
                            dayAvailability.removeTimeSlot(at: index)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
    }
}

struct DayAvailability: Identifiable {
    let id = UUID()
    let day: String
    var isOn = false
    var timeSlots: [TimeSlot] = []

    mutating func addTimeSlot() {
        timeSlots.append(TimeSlot(from: "00:00", to: "00:00"))
    }

    mutating func removeTimeSlot(at index: Int) {
        timeSlots.remove(at: index)
    }
}

struct TimeSlot: Identifiable {
    let id = UUID()
    var from: String
    var to: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        AddAvailabilityView()
    }
}
