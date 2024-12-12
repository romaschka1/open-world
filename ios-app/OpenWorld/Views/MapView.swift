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
    
    private var sendButton: UIButton!
    private var loadButton: UIButton!
    
    private let userLocationResource: UserLocationResource
    
    private var timer: Timer?

    init(userLocationResource: UserLocationResource = UserLocationResource()) {
        self.userLocationResource = userLocationResource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

        setupButtons()
    }
    
    private func setupButtons() {
        loadButton = UIButton(type: .system)
        loadButton.setTitle("Load", for: .normal)
        loadButton.backgroundColor = UIColor.green
        loadButton.tintColor = UIColor.white
        loadButton.layer.cornerRadius = 8
        loadButton.translatesAutoresizingMaskIntoConstraints = false
        
        loadButton.addTarget(self, action: #selector(loadLocationButtonPressed), for: .touchUpInside)
        
        self.view.addSubview(loadButton)
        
        // Layout for the button
        NSLayoutConstraint.activate([
            loadButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            loadButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loadButton.widthAnchor.constraint(equalToConstant: 200),
            loadButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = UIColor.green
        sendButton.tintColor = UIColor.white
        sendButton.layer.cornerRadius = 8
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        sendButton.addTarget(self, action: #selector(sendLocationButtonPressed), for: .touchUpInside)
        
        self.view.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            sendButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            sendButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 200),
            sendButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func loadLocationButtonPressed() {
        self.userLocationResource.getLocations { data in
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
    
    @objc private func sendLocationButtonPressed() {
        userLocationResource.sendLocations(locationsToSend) { success in
            if success {
                print("Locations were sent successfully.")
                // Perform any additional actions if needed, e.g., clearing sent data
                self.locationsToSend.removeAll()
            } else {
                print("Failed to send locations.")
                // Handle the failure case, e.g., retrying or showing an error message
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
