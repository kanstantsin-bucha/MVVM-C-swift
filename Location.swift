//
//  Location.swift
//  mvvm-c
//
//  Created by truebucha on 8/10/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import UIKit
import INTULocationManager

protocol LocationDelegate: class {
    func userLocationDidChange(to: MapLocation)
}

class Location {

    weak var delegate: LocationDelegate?
    
    var manager: INTULocationManager = INTULocationManager.sharedInstance()
    
    func locateSignificantLocationChanges() {
        manager.subscribeToSignificantLocationChanges() {
            [weak self] (location: CLLocation?,
                         accuracy: INTULocationAccuracy,
                         status:INTULocationStatus) -> () in
            guard self?.delegate != nil else {
                return
            }
            
            guard location != nil, status == .success else {
                return
            }
            let mapLocation = MapLocation(location: location!)
            self?.delegate?.userLocationDidChange(to: mapLocation)
        }
    }
    
    func currentPosition(completion: @escaping (_ userPosition: MapLocation?) -> ()) {
        manager.requestLocation(withDesiredAccuracy: INTULocationAccuracy.house, timeout: 20) { (location, accuracy, status) in
            guard location != nil else {
                completion(nil)
                return
            }
            let position = MapLocation(location: location!)
            completion(position)
        }
    }
}
