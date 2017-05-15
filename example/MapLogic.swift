//
//  MapLogic.swift
//  doroga
//
//  Created by truebucha on 8/9/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation

class MapLogic : MapLogicProtocol {

    weak var viewDelegate: MapLogic_ViewProtocol?
    weak var coordinatorDelegate: MapLogic_CoordinatorProtocol?
    var model: MapLogic_ModelProtocol?
    
    var markers: Array<MapMarker>?
    
    func requestUsersPositions(_ view: MapLogic_ViewProtocol) {
        model?.provideMarkers() { [unowned self] (markers, error) in
            self.viewDelegate?.markersDidChange(self, markers: markers)
            
            let dispatchTime: DispatchWallTime =
                DispatchWallTime.now() + DispatchTimeInterval.seconds(5)
            DispatchQueue.main.asyncAfter(wallDeadline: dispatchTime) {
                self.requestUsersPositions(view)
            }
        }
    }
}
