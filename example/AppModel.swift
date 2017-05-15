//
//  AppModel.swift
//  doroga
//
//  Created by truebucha on 8/29/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation
import GoogleMaps
import FeathersjsClientSwift


protocol AppModelProtocol {
    var config: Config {get}
    var feathers: FeathersClient {get}
}

class AppModel: AppModelProtocol {
    
    let config: Config
    var locationDelegate: LocationDelegate? {
        didSet {
            location.delegate = locationDelegate
        }
    }
    
    var userID: Int?
    var profileID: Int?
    var positionID: Int?
    var userAuth: UserAuthProtocol?
    var profileDesc: FeathersRequestObject? {
        let result: FeathersRequestObject = [
            "type": 1,
            "title": userAuth?.email ?? "no email",
            "imageURL": "",
            "description": "just a user"
        ]
        return result
    }
    
    var authorizationAttemptsCount: Int = 0
    var requestProfileAttemptsCount: Int = 0
    var createProfileAttemptsCount: Int = 0

    var feathers: FeathersClient
    var location: Location
    
    lazy var authModel: AuthLogic_ModelProtocol = { [unowned self] in
        let result = AuthModel(feathers: self.feathers)
        return result
    } ()
    
    init(config: Config,
        launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {
        
        self.config = config
        
        self.feathers = FeathersClient(URL: config.feathersURL,
                                       namespace: config.feathersNamespace,
                                       token: config.feathersToken,
                                       timeout: config.feathersEmitTimeout,
                                       debugMode: config.debugMode)
        
        self.location = Location()
        self.location.locateSignificantLocationChanges()
        
        let launchedForLocationEvent =
            nil != launchOptions?[UIApplicationLaunchOptionsKey.location]
        
        if launchedForLocationEvent == false {
            let googleServiceInitiated = GMSServices.provideAPIKey(config.googleServicesAPIKey)
            if (googleServiceInitiated == false) {
                print("FAILURE: Google Services Not Initialized")
            }
        }
    }
    
    func initiateServerConnection() {
        feathers.onConnect = { [unowned self] response, ack in
        
            guard self.userAuth != nil else { return }
            guard self.authorizationAttemptsCount < 3 else {
                self.userAuth = nil
                self.authorizationAttemptsCount = 0
                print("Skip Auto Authorization Attempts During Invalid Profile Auth Data")
                return
            }
            
            self.authModel.authorize(auth: self.userAuth!) { [unowned self] (error, userID) in
                guard self.userAuth != nil, error == nil, self.userID != nil else  {
                    self.authorizationAttemptsCount += 1
                    print("Authorization error: \r\n \(String(describing: error))")
                    return
                }
                
                self.loadLoggedUserProfile(ID: userID!,
                                           auth:self.userAuth!)
                
                self.authorizationAttemptsCount = 0
            }
        }
        
        feathers.onError = { response, ack in
            if case let FeathersResponse.error(error) = response {
                print("Connection error: \r\n \(error)")
            }
        }
        
        feathers.onDisconnect = { response, ack in
            print("Connection disconnect")
        }
        
        feathers.onUnathorize = { response, ack in
            print("Connection unauthorized")
        }
        
        feathers.connect()
    }
}

// MARK: - App Coordinator -

extension AppModel {

    func createLoggedUserProfile (ID: Int,
                                  auth: UserAuthProtocol) {
    
        userAuth = auth
        userID = ID
        
        let request: FeathersRequestObject = [
            "userID" : userID!,
            "type": 1,
            "nick": auth.email,
            "imageURL": ""
        ]
        
        createProfile(request: request)
    }

    func loadLoggedUserProfile(ID: Int,
                               auth: UserAuthProtocol) {
        userAuth = auth
        userID = ID
        
        self.authorizationAttemptsCount = 0
        self.requestProfileAttemptsCount = 0
        
        let request: FeathersRequestObject = [
            "userID" : userID!,
        ]
        
        requestProfile(request: request)
    }
    
    
    func createProfile(request: FeathersRequestObject) {
        let emitter = Emitter(feathers: feathers,
                              event: "profiles::create")
        
        
        do { try emitter.emitWithAck(request){ [unowned self] (response) in
                let error = response.extractError()
                guard error == nil else {
                    self.catchCreateProfile(error: error!,
                                            request: request)
                    return
                }
                let object = response.extractResponseObject()
                let profileID = object?["id"] as? Int
            
                guard profileID != nil else {
                    let error = FeathersError.serverError(reason: "create profile returned no object",
                                                          type: "FeathersError",
                                                          code: 500)
                    self.catchCreateProfile(error: error,
                                            request: request)
                    print(error)
                    return
                }
            
                self.profileID = profileID
            }
        } catch {
            catchCreateProfile(error: error as! FeathersError,
                               request: request)
        }
        createProfileAttemptsCount = 0
    }
    
    func catchCreateProfile(error: FeathersError,
                            request: FeathersRequestObject) {
        print("requestProfile Error \(error)")
        if  createProfileAttemptsCount < 3 {
            let dispatchTime: DispatchWallTime =
                DispatchWallTime.now() + DispatchTimeInterval.seconds(2)
            DispatchQueue.main.asyncAfter(wallDeadline: dispatchTime) { [unowned self] in
                self.createProfile(request: request)
            }
        }
        createProfileAttemptsCount = 0
    }
    
    
    func requestProfile(request:FeathersRequestObject) {
        let emitter = Emitter(feathers: feathers,
                              event: "profiles::find")
        do { try emitter.emitWithAck(request){ (response) in
                let error = response.extractError()
                guard error == nil else {
                    self.catchRequestProfile(error: error!,
                                             request: request)
                    return
                }
    
                let profile = response.extractDataArray()?.first
                let profileID = profile?["id"] as? Int
                
                guard profileID != nil else {
                    let error = FeathersError.serverError(reason: "find profile returned no object",
                                                          type: "FeathersError",
                                                          code: 500)
                    self.catchRequestProfile(error: error,
                                             request: request)
                    print(error)
                    return
                }
                
                self.profileID = profileID
                self.location.currentPosition(){ (position) in
                    guard position != nil else {
                        print("Current Position Detection Failed")
                        return
                    }
                    
                    self.submitUserPosition(position!) { (error) in
                        guard error == nil else {
                            print("Current Position Submittion Failed \(String(describing: error))")
                            return
                        }
                    }
                }
            }
        } catch {
            catchRequestProfile(error: error as! FeathersError,
                                request: request)
        }
        requestProfileAttemptsCount = 0
    }
    
    func catchRequestProfile(error: FeathersError,
                             request: FeathersRequestObject) {
        print("requestProfile Error \(error)")
        if  requestProfileAttemptsCount < 3 {
            let dispatchTime: DispatchWallTime =
                DispatchWallTime.now() + DispatchTimeInterval.seconds(2)
            DispatchQueue.main.asyncAfter(wallDeadline: dispatchTime) {
                self.requestProfile(request: request)
            }
        }
        return
    }
}

// MARK: - location updates -
extension AppModel {
    
    func submitUserPosition(_ position: MapLocation,
                            completion: @escaping ErrorCompletion<Error>) {
        guard profileID != nil, profileDesc != nil else {
            print("Profile Description Requered To Update User Location On Server")
            return
        }
            
        
        
        let patch: FeathersRequestObject =  [
            "longitude": position.longitude,
            "latitude": position.latitude,
            "accuracy": position.accuracy,
            "minZoom": 10
        ]
        
        if let ID = positionID {
            patchPosition(id: ID,
                          patch: patch,
                          completion: completion)
            return
        }
        
        findPosition(profileID: profileID!) { (error, id) in
            guard error == nil, id != nil else {
                let position: FeathersRequestObject =  [
                    "profileID": self.profileID!,
                    "type": self.profileDesc!["type"]!,
                    "title": self.profileDesc!["title"]!,
                    "imageURL": self.profileDesc!["imageURL"]!,
                    "description": self.profileDesc!["description"]!,
                    "longitude": position.longitude,
                    "latitude": position.latitude,
                    "accuracy": position.accuracy,
                    "minZoom": 10
                ]
            
                self.createPosition(position: position,
                                    completion: completion)
                return
            }
            
            self.positionID = id!
            self.patchPosition(id: id!,
                               patch: patch,
                               completion: completion)
        }
    }
    
    func findPosition(profileID: Int,
                      completion: @escaping DataCompletion<Error, Int?>) {
        let findEmitter = Emitter(feathers: feathers,
                                     event: "positions::find")
        let request: FeathersRequestObject = ["profileID": profileID]
        
        do { try findEmitter.emitWithAck(request) { response in
                let error = response.extractError()
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                
                let object = response.extractDataArray()?.first
                let ID = object?["id"] as? Int
                if  let id = ID {
                    completion(nil, id)
                } else {
                    let error = FeathersError.connectionError(reason: "Received Invalid Position ID")
                    completion(error, nil)
                    return
                }
            }
        } catch {
            completion(error, nil)
        }
    }
    
    func patchPosition(id: Int,
                       patch: FeathersRequestObject,
                       completion: @escaping ErrorCompletion<Error>) {
        let patchEmitter = Emitter(feathers: feathers,
                                   event: "positions::patch")
        
        do { try patchEmitter.emitWithAck(id: id, patch) { response in
                let error = response.extractError()
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
    
    func createPosition(position: FeathersRequestObject,
                        completion: @escaping ErrorCompletion<Error>) {
        let createEmitter = Emitter(feathers: feathers,
                                    event: "positions::create")
        do { try
            createEmitter.emitWithAck(position) { response in
                let error = response.extractError()
                guard error == nil else {
                    completion(error)
                    return
                }
                
                let object = response.extractResponseObject()
                let ID = object?["id"] as? Int
                if  let id = ID {
                    self.positionID = id
                } else {
                    let error = FeathersError.connectionError(reason: "Received Invalid Position ID")
                    completion(error)
                    return
                }
                
                completion(error)
            }
        } catch {
            completion(error)
        }
    }
}
