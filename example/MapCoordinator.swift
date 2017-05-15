//
//  MapCoordinator.swift
//  doroga
//
//  Created by truebucha on 8/9/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import UIKit
import FeathersjsClientSwift

protocol MapCoordinatorDelegate: class {
    func mapCoordinatorDidRequestProfile(_ authCoordinator: AuthCoordinator, userID: Int)
}

class MapCoordinator: Coordinator {
    weak var delegate: AuthCoordinatorDelegate?
    let window: UIWindow
    let feathers: FeathersClient
    
    init(window: UIWindow,
         feathers: FeathersClient) {
        self.window = window
        self.feathers = feathers
    }
    
    func start() {
        if let vc = Utils.vcWithNameFromStoryboardWithName("Map", storyboardName: "Map")
            as? MapViewController {
            let logic = MapLogic()
            logic.model = MapModel(feathers: feathers)
            logic.coordinatorDelegate = self
            vc.mapLogic = logic
            window.rootViewController = vc
        }
    }
}

extension MapCoordinator: MapLogic_CoordinatorProtocol {
    func mapLogicDidRequestProfile(_ logic: MapLogicProtocol, userID: String) {
        
    }
}
