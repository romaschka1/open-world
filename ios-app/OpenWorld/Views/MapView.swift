//
//  Map.swift
//  OpenWorld
//
//  Created by romaska on 04.12.2024.
//

import SwiftUI
import MapKit
import CoreLocation

class MapView: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    private var mapView: MKMapView!
    private var locationManager: CLLocationManager!
    
    private var storedLocations: [[UserLocation]] = []
    private var locationsToDraw: [CLLocationCoordinate2D] = []
    private var locationsToSend: [UserLocation] = []
    
    private var timer: Timer?
    
    init(locations: [[UserLocation]]) {
       self.storedLocations = locations
       super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
       super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView = MKMapView(frame: self.view.bounds)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        self.view.addSubview(mapView)

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Load all previously stored locations
        loadStoredLocations()
        // Send new locations to server each minute
        startSendingLocationToServer()
    }

    func loadStoredLocations() -> Void {
        for group in self.storedLocations {
            let coordinates = group.map { location in
                CLLocationCoordinate2D(
                    latitude: location.latitude,
                    longitude: location.longitude
                )
            }
            
            self.drawPath(data: coordinates)
        }
    }
    
    func startSendingLocationToServer() -> Void {
        timer = Timer.scheduledTimer(
            timeInterval: 60,
            target: self,
            selector: #selector(sendLocationToServer),
            userInfo: nil,
            repeats: true
        )
    }
    @objc private func sendLocationToServer() {
        UserLocationResource.shared.sendLocations(locationsToSend) { success in
            if success {
                print("Locations were sent successfully.")
                self.locationsToSend.removeAll()
            } else {
                print("Failed to send locations.")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }

        locationsToDraw.append(newLocation.coordinate)
        locationsToSend.append(
            UserLocation.init(
                time: ISO8601DateFormatter().string(from: Date()),
                latitude: newLocation.coordinate.latitude,
                longitude: newLocation.coordinate.longitude
            )
        )

        drawPath(data: locationsToDraw)
        
        // Clear array to reduce load
        // ToDo: Figureout something more efficient
        if (locationsToDraw.count >= 100) {
            if let lastLocation = self.locationsToDraw.last {
                self.locationsToDraw = [lastLocation]
            }
        }
    }

    func drawPath(data: [CLLocationCoordinate2D]) {
        let polyline = MKPolyline(coordinates: data, count: data.count)
        mapView.addOverlay(polyline)
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 2
            return renderer
        }
        return MKOverlayRenderer()
    }
}

struct MapRepresentable: UIViewControllerRepresentable {
    @Binding var locations: [[UserLocation]]
    
    func makeUIViewController(context: Context) -> MapView {
        return MapView(locations: self.locations)
    }
    
    func updateUIViewController(_ uiViewController: MapView, context: Context) {
        // Handle updates from SwiftUI if needed
    }
}
