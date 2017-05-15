//
//  MapLogicProtocol.swift
//  doroga
//
//  Created by truebucha on 8/9/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation

protocol MapLogicProtocol: class {
    
    var viewDelegate: MapLogic_ViewProtocol? { get set }
    var coordinatorDelegate: MapLogic_CoordinatorProtocol? { get set}
    var model: MapLogic_ModelProtocol? { get set }
    
    var markers: Array<MapMarker>? { get}
    
    func requestUsersPositions(_ view: MapLogic_ViewProtocol)
}

protocol MapLogic_ViewProtocol: class {
    func markersDidChange(_ logic: MapLogicProtocol, markers: Array<MapMarker>?)
}

protocol MapLogic_CoordinatorProtocol: class {
    func mapLogicDidRequestProfile(_ logic: MapLogicProtocol, userID: String)
}

protocol MapLogic_ModelProtocol: class {
    func provideMarkers(completionHandler: @escaping (_ markers: Array<MapMarker>?, _ error: Error?) -> ()) 
}
