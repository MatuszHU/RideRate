//
//  Route.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 10..
//
import FirebaseFirestore
struct Route: Identifiable, Codable {
    @DocumentID var id: String?
    var route_url: String?
    var route_long_name: String?
    var agency_id: String?
    var route_short_name: String?
    var route_desc: String?
    var route_text_color: String?
    var route_type: String?
    var route_color: String?

}
