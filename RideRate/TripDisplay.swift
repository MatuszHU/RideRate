//
//  TripDisplay.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 11..
//

import SwiftUI
import Foundation

struct TripDisplay: View {
    @StateObject var manager = GTFS_manager()
    var body: some View {
        NavigationView {
            List(manager.trips, id: \.id) { trip in
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.trip_short_name ?? "Failed to load t")
                        .font(.headline)
                    if let headsign = trip.trip_headsign {
                        Text(headsign)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Service: \(trip.service_id)")
                        if let route = trip.route_id { Text("Route: \(route)") }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding(.vertical, 6)
            }
            .navigationTitle("Járatok")
            .onAppear { manager.fetchAllTrips() }
        }
    }
}

#Preview {
    TripDisplay()
}

