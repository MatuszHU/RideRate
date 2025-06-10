//
//  RideRateApp.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 07..
//

import SwiftUI
import SwiftData
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
@main
struct RideRateApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    struct ContentView: View {
        @StateObject var manager = RatingManager()
        
        @State private var vehicleId = "MAV-IC-1234"
        @State private var cleanliness = 3
        @State private var punctuality = 4
        @State private var crowdedness = 2
        @State private var comment = ""

        var body: some View {
            NavigationView {
                VStack {
                    Form {
                        Text("Jármű ID: \(vehicleId)")
                        Stepper("Tisztaság: \(cleanliness)", value: $cleanliness, in: 1...5)
                        Stepper("Pontosság: \(punctuality)", value: $punctuality, in: 1...5)
                        Stepper("Zsúfoltság: \(crowdedness)", value: $crowdedness, in: 1...5)
                        TextField("Megjegyzés", text: $comment)
                        Button("Értékelés beküldése") {
                            let rating = Rating(
                                vehicleId: vehicleId,
                                cleanliness: cleanliness,
                                punctuality: punctuality,
                                crowdedness: crowdedness,
                                comment: comment,
                                timestamp: Date()
                            )
                            manager.addRating(rating)
                            comment = ""
                        }
                    }

                    List(manager.ratings) { rating in
                        VStack(alignment: .leading) {
                            Text("🧹 Tisztaság: \(rating.cleanliness), ⏱️ Pontosság: \(rating.punctuality), 👥 Zsúfoltság: \(rating.crowdedness)")
                            Text("💬 \(rating.comment)").italic()
                            Text("📅 \(rating.timestamp.formatted())").font(.caption)
                        }
                    }
                }
                .onAppear {
                    manager.fetchRatings(for: vehicleId)
                }
                .navigationTitle("Értékelés")
            }
        }
    }
    

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
