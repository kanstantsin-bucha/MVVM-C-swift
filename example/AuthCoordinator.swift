//
//  AuthCoordinator.swift
//  doroga
//
//  Created by Bucha Kanstantsin on 7/3/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import UIKit
import FeathersjsClientSwift

protocol AuthCoordinatorDelegate: class {
    func authCoordinatorDidFinishLogin(_ authCoordinator: AuthCoordinator,
                                       profileAuth: UserAuthProtocol,
                                       userID: Int)
    func authCoordinatorDidFinishSignUp(_ authCoordinator: AuthCoordinator,
                                        profileAuth: UserAuthProtocol,
                                        userID: Int)
}

class AuthCoordinator: Coordinator {

    weak var delegate: AuthCoordinatorDelegate?
    let window: UIWindow
    let feathers: FeathersClient
    
    init(window: UIWindow,
         feathers: FeathersClient) {
        self.window = window
        self.feathers = feathers
    }
    
    func start() {
        if let vc = Utils.vcWithNameFromStoryboardWithName("Auth", storyboardName: "Auth")
           as? AuthViewController {
            let logic = AuthLogic()
            logic.model = AuthModel(feathers: feathers)
            logic.coordinatorDelegate = self
            vc.authLogic = logic
            window.rootViewController = vc
        }
    }
}

extension AuthCoordinator: AuthLogic_CoordinatorProtocol {
    func authLogicDidLogin(_ logic: AuthLogicProtocol,
                           profileAuth: UserAuthProtocol,
                           userID: Int) {
        delegate?.authCoordinatorDidFinishLogin(self,
                                                profileAuth: profileAuth,
                                                userID: userID)
    }
    
    func authLogicDidSignUp(_ logic: AuthLogicProtocol, profileAuth: UserAuthProtocol, userID: Int) {
        delegate?.authCoordinatorDidFinishSignUp(self,
                                                 profileAuth: profileAuth,
                                                 userID: userID)
    }
}
