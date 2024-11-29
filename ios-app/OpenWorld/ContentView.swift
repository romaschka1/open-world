//
//  ContentView.swift
//  open-world
//
//  Created by romaska on 14.11.2024.
//

import SwiftUI
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    private var mapView: MKMapView!
    private var locationManager: CLLocationManager!

    private var newUserLocations: [CLLocationCoordinate2D] = []
    private var locationService: LocationService!
    
    private var sendButton: UIButton!
    private var loadButton: UIButton!
    
    private let userLocationResource: UserLocationResource

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
        
        locationService = LocationService()
        // Start sending location to server every minute
//        locationService.startSendingLocationToServer()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        setupSendButton()
        setupLoadButton()
    }
    
    private func setupLoadButton() {
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

    private func setupSendButton() {
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
    
    @objc private func sendLocationButtonPressed() {
        locationService.sendLocationToServer()
        print("Send Location Button Pressed")
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        newUserLocations.append(newLocation.coordinate)
        drawPath(data: newUserLocations)
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

struct MapViewControllerRepresentable: UIViewControllerRepresentable {
    
    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController()
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        // Handle updates from SwiftUI if needed
    }
}

struct ContentView: View {
    @StateObject private var locationService = LocationService()

    var body: some View {
        VStack {
            // Display the map view
            MapViewControllerRepresentable().edgesIgnoringSafeArea(.all)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
