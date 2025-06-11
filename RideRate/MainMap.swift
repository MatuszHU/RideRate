import SwiftUI
import MapKit
import SwiftProtobuf

struct Vehicle: Identifiable {
    let id: String
    let coordinate: CLLocationCoordinate2D
    let type: String
    // Enhanced properties from RealCity extensions
    let vehicleModel: String?
    let isDeviated: Bool
    let vehicleType: Int32?
    let isDoorOpen: Bool
    let stopDistance: Int32?
}

class VehicleViewModel: ObservableObject {
    @Published var vehicles: [Vehicle] = []

    func fetchVehiclePositions() {
        guard let url = URL(string: "https://go.bkk.hu/api/query/v1/ws/gtfs-rt/full/VehiclePositions.pb?key=f92930cd-2611-45f4-b894-d9c9c615547f") else {
            print("❌ Invalid URL")
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let feedMessage = try TransitRealtime_FeedMessage(serializedBytes: data)
                DispatchQueue.main.async {
                    self.vehicles = feedMessage.entity.filter { entity in
                        entity.hasVehicle && entity.vehicle.hasPosition
                    }.compactMap { entity in
                        let vehicle = entity.vehicle

                        // Note: BKK API likely doesn't include RealCity extensions
                        // For now, we'll set realCityVehicle to nil and use fallback logic
                        let realCityVehicle: Realcity_VehicleDescriptor? = nil
                        
                        // TODO: If you have access to a feed with RealCity extensions, use:
                        // let realCityVehicle = vehicle.hasRealcity_vehicle ? vehicle.Realcity_vehicle : nil
                        
                        // Determine vehicle type from various sources
                        let vehicleTypeString = self.determineVehicleType(
                            from: vehicle,
                            realCityVehicle: realCityVehicle
                        )

                        return Vehicle(
                            id: entity.id,
                            coordinate: CLLocationCoordinate2D(
                                latitude: CLLocationDegrees(vehicle.position.latitude),
                                longitude: CLLocationDegrees(vehicle.position.longitude)
                            ),
                            type: vehicleTypeString,
                            vehicleModel: realCityVehicle?.hasVehicleModel == true ? realCityVehicle?.vehicleModel : nil,
                            isDeviated: realCityVehicle?.deviated ?? false,
                            vehicleType: realCityVehicle?.hasVehicleType == true ? realCityVehicle?.vehicleType : nil,
                            isDoorOpen: realCityVehicle?.doorOpen ?? false,
                            stopDistance: realCityVehicle?.hasStopDistance == true ? realCityVehicle?.stopDistance : nil
                        )
                    }
                    
                    print("✅ Loaded \(self.vehicles.count) vehicles")
                    // Print debug info for vehicles with RealCity data
                    let vehiclesWithExtensions = self.vehicles.filter { $0.vehicleModel != nil || $0.vehicleType != nil }
                    if !vehiclesWithExtensions.isEmpty {
                        print("🔍 Found \(vehiclesWithExtensions.count) vehicles with RealCity extensions")
                    }
                }
            } catch {
                print("❌ Protobuf decode error: \(error)")
            }
        }

        task.resume()
    }
    
    private func determineVehicleType(from vehicle: TransitRealtime_VehicleDescriptor, realCityVehicle: Realcity_VehicleDescriptor?) -> String {
        // First try to get type from RealCity extensions
        if let realCityType = realCityVehicle?.vehicleType {
            switch realCityType {
            case 0: return "bus"
            case 1: return "tram"
            case 2: return "train"
            case 3: return "metro"
            case 4: return "ferry"
            default: return "unknown"
            }
        }
        
        // Fallback to route-based detection or other methods
        if vehicle.hasTrip {
            let routeId = vehicle.trip.routeID.lowercased()
            if routeId.contains("bus") || routeId.hasPrefix("b") {
                return "bus"
            } else if routeId.contains("tram") || routeId.contains("villamos") {
                return "tram"
            } else if routeId.contains("metro") || routeId.contains("m1") || routeId.contains("m2") || routeId.contains("m3") || routeId.contains("m4") {
                return "metro"
            } else if routeId.contains("train") || routeId.contains("hev") {
                return "train"
            }
        }
        
        return "bus" // Default fallback
    }
}

struct MapKitMapView: UIViewRepresentable {
    var vehicles: [Vehicle]
    @Binding var region: MKCoordinateRegion

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView(frame: .zero)
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: false)
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update region if needed
        if uiView.region.center.latitude != region.center.latitude ||
            uiView.region.center.longitude != region.center.longitude ||
            uiView.region.span.latitudeDelta != region.span.latitudeDelta ||
            uiView.region.span.longitudeDelta != region.span.longitudeDelta {
            uiView.setRegion(region, animated: true)
        }

        // Remove all current annotations
        uiView.removeAnnotations(uiView.annotations)

        // Add annotations for vehicles
        for vehicle in vehicles {
            let annotation = VehicleAnnotation(vehicle: vehicle)
            uiView.addAnnotation(annotation)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapKitMapView

        init(_ parent: MapKitMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let vehicleAnnotation = annotation as? VehicleAnnotation else {
                return nil
            }

            let identifier = "VehicleAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
            } else {
                annotationView?.annotation = annotation
            }

            // Configure the annotation view with enhanced styling
            let vehicle = vehicleAnnotation.vehicle
            let tuple: (String, UIColor) = {
                switch vehicle.type.lowercased() {
                case "bus": return ("bus", vehicle.isDeviated ? UIColor.systemRed : UIColor.systemBlue)
                case "tram": return ("tram", vehicle.isDeviated ? UIColor.systemRed : UIColor.systemYellow)
                case "train": return ("train.side.front.car", vehicle.isDeviated ? UIColor.systemRed : UIColor.systemGreen)
                case "metro": return ("m.circle", vehicle.isDeviated ? UIColor.systemRed : UIColor.systemPurple)
                case "ferry": return ("ferry", vehicle.isDeviated ? UIColor.systemRed : UIColor.systemCyan)
                default: return ("questionmark", UIColor.systemGray)
                }
            }()

            let diameter: CGFloat = vehicle.isDoorOpen ? 42 : 36 // Larger if doors are open
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter, height: diameter))
            let img = renderer.image { ctx in
                // Draw colored circle with special styling for deviated vehicles
                let circleRect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
                ctx.cgContext.setFillColor(tuple.1.cgColor)
                ctx.cgContext.fillEllipse(in: circleRect)
                
                // Add border for deviated vehicles
                if vehicle.isDeviated {
                    ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
                    ctx.cgContext.setLineWidth(3)
                    ctx.cgContext.strokeEllipse(in: circleRect)
                }
                
                // Add dashed border for vehicles with doors open
                if vehicle.isDoorOpen {
                    ctx.cgContext.setStrokeColor(UIColor.white.cgColor)
                    ctx.cgContext.setLineWidth(2)
                    ctx.cgContext.setLineDash(phase: 0, lengths: [4, 2])
                    ctx.cgContext.strokeEllipse(in: circleRect.insetBy(dx: 6, dy: 6))
                }

                // Draw system image
                if let symbolImage = UIImage(systemName: tuple.0) {
                    let config = UIImage.SymbolConfiguration(pointSize: vehicle.isDoorOpen ? 20 : 18, weight: .regular)
                    let symbol = symbolImage.withConfiguration(config).withTintColor(.white, renderingMode: .alwaysOriginal)
                    let symbolRect = CGRect(
                        x: (diameter - symbol.size.width) / 2,
                        y: (diameter - symbol.size.height) / 2,
                        width: symbol.size.width,
                        height: symbol.size.height
                    )
                    symbol.draw(in: symbolRect)
                }
            }

            annotationView?.image = img
            annotationView?.centerOffset = CGPoint(x: 0, y: -diameter / 2)

            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            // Enhanced callout could show RealCity data
            guard let vehicleAnnotation = view.annotation as? VehicleAnnotation else { return }
            let vehicle = vehicleAnnotation.vehicle
            
            var calloutText = "Vehicle ID: \(vehicle.id)"
            if let model = vehicle.vehicleModel {
                calloutText += "\nModel: \(model)"
            }
            if vehicle.isDeviated {
                calloutText += "\n⚠️ Off Route"
            }
            if vehicle.isDoorOpen {
                calloutText += "\n🚪 Doors Open"
            }
            if let distance = vehicle.stopDistance {
                calloutText += "\n📍 \(distance)m to stop"
            }
            
            // You could show an alert or custom callout here
            print("Selected vehicle: \(calloutText)")
        }
    }

    class VehicleAnnotation: NSObject, MKAnnotation {
        let vehicle: Vehicle
        var coordinate: CLLocationCoordinate2D {
            vehicle.coordinate
        }
        var title: String? {
            var title = "Vehicle \(vehicle.id)"
            if let model = vehicle.vehicleModel {
                title += " (\(model))"
            }
            return title
        }
        
        var subtitle: String? {
            var parts: [String] = []
            if vehicle.isDeviated {
                parts.append("Off Route")
            }
            if vehicle.isDoorOpen {
                parts.append("Doors Open")
            }
            if let distance = vehicle.stopDistance {
                parts.append("\(distance)m to stop")
            }
            return parts.isEmpty ? nil : parts.joined(separator: " • ")
        }

        init(vehicle: Vehicle) {
            self.vehicle = vehicle
            super.init()
        }
    }
}

struct MainMapView: View {
    @StateObject private var viewModel = VehicleViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 47.4979, longitude: 19.0402), // Budapest
        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
    )
    @State private var timer: Timer?

    var body: some View {
        ZStack {
            MapKitMapView(vehicles: viewModel.vehicles, region: $region)
                .ignoresSafeArea()
            
            // Status overlay
            VStack {
                HStack {
                    Text("\(viewModel.vehicles.count) vehicles")
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    
                    Spacer()
                    
                    // Show count of vehicles with special status
                    let deviatedCount = viewModel.vehicles.filter(\.isDeviated).count
                    let doorsOpenCount = viewModel.vehicles.filter(\.isDoorOpen).count
                    
                    if deviatedCount > 0 || doorsOpenCount > 0 {
                        VStack(alignment: .trailing, spacing: 2) {
                            if deviatedCount > 0 {
                                Text("⚠️ \(deviatedCount) off route")
                                    .font(.caption)
                            }
                            if doorsOpenCount > 0 {
                                Text("🚪 \(doorsOpenCount) doors open")
                                    .font(.caption)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            viewModel.fetchVehiclePositions()
            // Set up periodic updates
            timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { _ in
                viewModel.fetchVehiclePositions()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
}

#Preview {
    MainMapView()
}
