//
//  calendar.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 10..
//
import FirebaseFirestore

struct Calendar: Identifiable, Codable{
    
    @DocumentID var id: String?
    var monday: String?
    var tuesday: String?
    var wednesday: String?
    var thursday: String?
    var friday: String?
    var saturday: String?
    var sunday: String?
    var end_date: String?
    var start_date: String?
    
}
