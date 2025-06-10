//
//  RatingManager.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 07..
//


import Foundation
import FirebaseFirestore


class RatingManager: ObservableObject {
    private let db = Firestore.firestore()
    @Published var ratings: [Rating] = []

    func fetchRatings(for vehicleId: String) {
        db.collection("ratings")
            .whereField("vehicleId", isEqualTo: vehicleId)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                self.ratings = documents.compactMap { doc in
                    try? doc.data(as: Rating.self)
                }
            }
    }

    func addRating(_ rating: Rating) {
        do {
            _ = try db.collection("ratings").addDocument(from: rating)
        } catch {
            print("Hiba a mentéskor: \(error.localizedDescription)")
        }
    }
}
