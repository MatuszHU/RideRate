//
//  Agency.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 10..
//
import FirebaseFirestore
struct Agency: Identifiable, Codable{
    
    var phone: String?
    var tz: String?
    var url: String?
    var fare_url: String?
    var lang: String?
    var name: String?
    @DocumentID var id: String?
    var agency_id: String
    
}
