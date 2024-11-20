//
//  Locations.swift
//  OpenWorld
//
//  Created by romaska on 02.09.2024.
//

import Foundation
import MapKit

struct Location: Identifiable {
    let name: String
    let cityName: String
    let coordinates: CLLocationCoordinate2D
    let description: String
    let link: String
    
    var id: String {
        name + cityName
    }
}
