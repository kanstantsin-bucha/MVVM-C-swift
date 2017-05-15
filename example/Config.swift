//
//  Config.swift
//  doroga
//
//  Created by truebucha on 8/9/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation

class Config {
    
    let remoteServerURL = URL(string: "https://dorogamobi.herokuapp.com")!
    let localServerURL = URL(string: "http://localhost:303")!

    var feathersURL: URL {
        #if (DEBUG)
            let serverSetup = ProcessInfo.processInfo.environment["USE_SERVER"]
            if serverSetup != nil, serverSetup == "remote" {
                return remoteServerURL
            } else {
                return localServerURL
            }
        #else
            return remoteServerURL
        #endif
    }
    
    var feathersEmitTimeout: Int {
        // sec
        #if (DEBUG)
            return 5
        #else
            return 20
        #endif
    }
    
    let feathersNamespace: String? = nil
    
    let feathersToken = "19ayeiTJa7uoV434Vlx96Tg7EK40cvW82+NkwDD6XRnIK3rA6WAZti9I7hLmCrePwPPij7ftJr/8YLl3HeWV9A=="
    
    let debugMode: Bool = false
    
    let googleServicesAPIKey: String = "AIzaSyAP6ntM1zhm5WndVrzF-28GfTagc_e85q0"
    
    let minUpdateUserLocationInterval: Double = 5.0 // sec
}
