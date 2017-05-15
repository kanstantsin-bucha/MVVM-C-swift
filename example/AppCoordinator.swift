//
//  AppCoordinator.swift
//  doroga
//
//  Created by Bucha Kanstantsin on 7/3/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import UIKit
import FeathersjsClientSwift

class AppCoordinator: Coordinator {

    let appLogic: AppLogic!
    let appModel: AppModel!
    
    let AUTH_SCENE_KEY: String  = "Authentication"
    let MAP_SCENE_KEY: String  = "Map"
    
    var window: UIWindow
    var coordinators = [String:Coordinator]()
    
    init(window: UIWindow,
         launchOptions: [UIApplicationLaunchOptionsKey : Any]?) {
        self.window = window
        self.appModel = AppModel(config: Config(),
                                 launchOptions: launchOptions)
        self.appLogic = AppLogic(model: appModel)
        appModel.locationDelegate = appLogic
    }
    
    // TODO: handle server disconnect and unauthorize
    
    func start() {
        appModel.initiateServerConnection()
        showAuthentication()
    }
}

extension AppCoordinator {

    func showAuthentication() {
        let authCoordinator = AuthCoordinator(window: window,
                                              feathers: appModel.feathers)
        coordinators[AUTH_SCENE_KEY] = authCoordinator
        authCoordinator.delegate = self
        authCoordinator.start()
    }
    
    func showMap () {
        let mapCoordinator = MapCoordinator(window: window,
                                            feathers: appModel.feathers)
        coordinators[MAP_SCENE_KEY] = mapCoordinator
        mapCoordinator.delegate = self
        mapCoordinator.start()
    }
    
    func showProfile(ID: Int) {
    // TODO: Show profile
        print("requested profile \(ID)")
    }
}

extension AppCoordinator: AuthCoordinatorDelegate {
    func authCoordinatorDidFinishLogin(_ authCoordinator: AuthCoordinator,
                                       profileAuth: UserAuthProtocol,
                                       userID: Int) {
        appModel.loadLoggedUserProfile(ID: userID,
                                       auth: profileAuth)
        showMap()
    }
    func authCoordinatorDidFinishSignUp(_ authCoordinator: AuthCoordinator,
                                        profileAuth: UserAuthProtocol,
                                        userID: Int) {
        appModel.createLoggedUserProfile(ID: userID,
                                         auth: profileAuth)
        showMap()
    }
}

extension AppCoordinator: MapCoordinatorDelegate {
    func mapCoordinatorDidRequestProfile(_ authCoordinator: AuthCoordinator, userID: Int) {
        showProfile(ID: userID)
    }
}
