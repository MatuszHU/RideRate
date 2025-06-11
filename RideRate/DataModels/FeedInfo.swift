//
//  FeedInfo.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 10..
//

import FirebaseFirestore

struct FeedInfo: Identifiable, Codable {
    
    var lang: String?
    var publisher_name: String?
    var start_date: String?
    var end_date: String?
    var version: String?
    var publisher_url: String?
    @DocumentID var id: String?
    
}
