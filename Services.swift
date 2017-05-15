//
//  Service.swift
//  doroga
//
//  Created by truebucha on 8/10/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation
import GoogleMaps

class Services {

    var googleServicesAPIKey: String
    var connection: Connection
    var location: Location
    
    init(config: Config, locationDelegate: LocationDelegate) {
        self.connection = Connection(serverURL: config.serverURL,
                                     namespace: config.serverNamespace,
                                     timeout: config.connectionEmitTimeout,
                                     debugMode: config.debugMode)
        self.googleServicesAPIKey = config.googleServicesAPIKey
        self.location = Location()
        self.location.delegate = locationDelegate
    }
    
    func initiate(config: Config,
                  launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {
        initiateConnection()
        initiateLocation()
        let launchedForLocationEvent = nil != launchOptions?[UIApplicationLaunchOptionsKey.location]
        
        guard false == launchedForLocationEvent else { return }
        
        initiateGoogleServices()
    }
    
}

// MARK: - Initiate -
extension Services {

    func initiateGoogleServices() {
        let googleConnected = GMSServices.provideAPIKey(googleServicesAPIKey)
        if googleConnected == false {
            print("Failed To Connect To Google Services")
        }
    }
    
    func initiateConnection() {
        connection.connect { (error) in
            guard self.connection.connected == true else {
                print("Failed To Connect To Server")
                return;
            }
            
            self.connection.testWebSocket()
        }
    }
    
    func initiateLocation() {
        location.locateSignificantLocationChanges()
    }
}


