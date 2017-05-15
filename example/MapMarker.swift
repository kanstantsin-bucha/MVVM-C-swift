//
//  MapMarker.swift
//  doroga
//
//  Created by truebucha on 8/10/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import UIKit

class MapMarker {
    let location: MapLocation
    let title: String
    let description: String
    let image: UIImage?
    
    init(location: MapLocation,
         title: String,
         description: String,
         image: UIImage? = nil) {
        self.location = location
        self.title = title
        self.description = description
        self.image = image
    }
}
