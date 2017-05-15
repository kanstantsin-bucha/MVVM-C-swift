//
//  AppLogic.swift
//  mvvm-c
//
//  Created by truebucha on 8/25/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation

class AppLogic {

    var model: AppModel!
    
    var config: Config = Config()
    var lastLocationUpdate: Date?
    
    init(model: AppModel) {
        self.model = model
    }

    func noteLastUserLocationUpdate() {
        lastLocationUpdate = Date()
    }
    
    func shouldSendUserLocationUpdate() -> Bool {
        if let lastTime = lastLocationUpdate {
            let currentDate = Date()
            let timeInterval = currentDate.timeIntervalSince(lastTime)
            
            guard timeInterval > config.minUpdateUserLocationInterval else {
                return false
            }
        }
        
        return true
    }
}

// MARK: - LocationDelegate -
extension AppLogic: LocationDelegate {
    
    func userLocationDidChange(to position: MapLocation) {
        guard shouldSendUserLocationUpdate() else {
            print("Skip User Location Update During Time Interval")
            return
        }
        
        model.submitUserPosition(position) { [unowned self] (error) in
            guard error == nil else {
                print("===== submitUserLocation: \(String(describing: error))")
                return
            }
            
            self.lastLocationUpdate = Date()
        }
    }
}
