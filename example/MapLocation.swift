//
//  MapLocation.swift
//  doroga
//
//  Created by truebucha on 8/10/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation
import CoreLocation

class MapLocation {
    
    let latitude: Double
    let longitude: Double
    let accuracy: Double
    
    init(location: CLLocation) {
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.accuracy = location.horizontalAccuracy
    }
    
    init(latitude: Double,
         longitude: Double,
         accuracy: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.accuracy = accuracy
    }
}
