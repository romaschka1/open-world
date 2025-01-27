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

    private var locationsToDraw: [CLLocationCoordinate2D] = []
    private var locationsToSend: [UserLocation] = []
    
    private var timer: Timer?
    
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

    func loadStoredLocations() {
        UserLocationResource.shared.getLocations { data in
            for group in data {
                let coordinates = group.map { location in
                    CLLocationCoordinate2D(
                        latitude: location.latitude,
                        longitude: location.longitude
                    )
                }
                
                self.drawPath(data: coordinates)
            }
        }
    }
    
    func startSendingLocationToServer() {
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
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
}

struct MapRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> MapView {
        return MapView()
    }
    
    func updateUIViewController(_ uiViewController: MapView, context: Context) {
        // Handle updates from SwiftUI if needed
    }
}
