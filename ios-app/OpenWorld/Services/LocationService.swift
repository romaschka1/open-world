import Foundation
import CoreLocation

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private var API_URL = "http://localhost:8080/api/location"
    
    private var locationManager: CLLocationManager!
    private var userLocations: [UserLocation] = []
    private var timer: Timer?
    private let userLocationResource: UserLocationResource

    init(userLocationResource: UserLocationResource = UserLocationResource()) {
        self.userLocationResource = userLocationResource
        self.locationManager = CLLocationManager()
        super.init()

        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    // Start sending location to the server every minute
    func startSendingLocationToServer() {
        timer = Timer.scheduledTimer(
            timeInterval: 60,
            target: self,
            selector: #selector(sendLocationToServer),
            userInfo: nil,
            repeats: true
        )
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        let userLocation = UserLocation.init(
            time: ISO8601DateFormatter().string(from: Date()),
            latitude: newLocation.coordinate.latitude,
            longitude: newLocation.coordinate.longitude
        )

        userLocations.append(userLocation);
    }

    @objc func sendLocationToServer() {
        guard !userLocations.isEmpty else { return }
        
        userLocationResource.sendLocations(userLocations) { success in
            if success {
                print("Coordinates sent successfully")
                self.userLocations.removeAll()
            } else {
                print("Failed to send coordinates")
            }
        }
    }

    public func getCoordinatesFromServer(completion: @escaping ([[UserLocation]]) -> Void) {
        guard let url = URL(string: API_URL) else {
           print("Invalid URL")
           return
       }

       let task = URLSession.shared.dataTask(with: url) { data, response, error in
           if let error = error {
               print("Error fetching data: \(error)")
               return
           }
           
           guard let data = data else {
               print("No data received")
               return
           }
           
           do {
               let decoder = JSONDecoder()
               let locations = try decoder.decode([[UserLocation]].self, from: data)

               completion(locations)
           } catch {
               print("Error decoding JSON: \(error)")
           }
       }
       
       task.resume()
    }
}
