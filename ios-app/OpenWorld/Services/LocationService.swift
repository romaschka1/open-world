import Foundation
import CoreLocation

class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private var API_URL = "http://localhost:8080/api/location"
    
    private var locationManager: CLLocationManager!
    private var userLocations: [UserLocation] = []
    private var timer: Timer?

    override init() {
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

    // CLLocationManager delegate method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        let userLocation = UserLocation.init(
            time: ISO8601DateFormatter().string(from: Date()),
            latitude: Int64(newLocation.coordinate.latitude * 1_000_000),
            longitude: Int64(newLocation.coordinate.longitude * 1_000_000)
        )

        userLocations.append(userLocation);
    }

    @objc func sendLocationToServer() {
        guard !userLocations.isEmpty else { return }

        sendCoordinatesToServer(userLocations) { success in
            if success {
                print("Coordinates sent successfully")
                self.userLocations.removeAll()
            } else {
                print("Failed to send coordinates")
            }
        }
    }

    private func sendCoordinatesToServer(_ locations: [UserLocation], completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: API_URL) else {
            completion(false)
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(locations)
            request.httpBody = jsonData
        } catch {
            completion(false)
            return
        }

        let task = URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Error sending coordinates: \(error)")
                completion(false)
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
        
        task.resume()
    }

    public func getCoordinatesFromServer(completion: @escaping ([UserLocation]) -> Void) {
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
               let locations = try decoder.decode([UserLocation].self, from: data)
               
               DispatchQueue.global().asyncAfter(deadline: .now()) {
                   completion(locations)
               }
      
           } catch {
               print("Error decoding JSON: \(error)")
           }
       }
       
       task.resume()
    }
}
