//
//  MainMap.swift
//  RideRate
//
//  Created by Máté Majoros on 2025. 06. 10..
//

import SwiftUI
import MapKit
struct MainMap: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Kezdeti régió beállítása (pl. Budapest)
        let coordinate = CLLocationCoordinate2D(latitude: 47.535863635876076, longitude: 21.617380367806415)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        uiView.setRegion(region, animated: true)
        uiView.showsUserLocation = true
        uiView.isZoomEnabled = true
        
        
    }
}

#Preview {
    MainMap().ignoresSafeArea()
}
