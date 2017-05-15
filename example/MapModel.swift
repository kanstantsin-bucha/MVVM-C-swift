//
//  MapModelStub.swift
//  doroga
//
//  Created by truebucha on 8/9/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation
import FeathersjsClientSwift

class MapModel {
    
    unowned let feathers: FeathersClient
    
    init(feathers: FeathersClient) {
        self.feathers = feathers
    }
}

extension MapModel: MapLogic_ModelProtocol {
    func provideMarkers(completionHandler: @escaping (_ markers: Array<MapMarker>?, _ error: Error?) -> ()) {
        requestPositions() { (positions, error) in
            guard error == nil, positions != nil else {
                completionHandler(nil, error)
                return
            }
        
            
            
            let markers: Array<MapMarker> = positions!.map({ (position) -> MapMarker in
                self.mapMarkerUsing(position: position)
            })
            
            completionHandler(markers, nil)
        }
    }
    
    func mapMarkerUsing(position: FeathersResponseObject) -> MapMarker {
        let latitude = position["latitude"] as? Double ?? 0
        let longitude = position["longitude"] as? Double ?? 0
        let accuracy = position["accuracy"] as? Double ?? 1000
        
        let location = MapLocation(latitude: latitude,
                                   longitude: longitude,
                                   accuracy: accuracy)
        
        let title = position["title"] as? String ?? ""
        let description = position["description"] as? String ?? ""
        
        let result = MapMarker(location: location,
                               title: title,
                               description: description)
        return result
    }
    
    func requestPositions(completionHandler: @escaping (_ positions: FeathersResponseArray?, _ error: Error?) -> ()) {
        let emitter = Emitter(feathers: feathers,
                              event: "positions::find")
    
        do { try emitter.emitWithAck() { (response) in
                let error = response.extractError()
                guard error == nil else {
                    completionHandler(nil, error)
                    return
                }
            
                let array = response.extractDataArray()
                if let positions = array {
                    completionHandler(positions, nil)
                } else {
                    let error = FeathersError.connectionError(reason: "Received Nil Positoins")
                    completionHandler(nil, error)
                }
            }
        } catch {
            completionHandler(nil, error)
        }
    }
    
    /* let ex: FeathersRequestObject = ["latitude": 37.73238473,
     "imageURL": "",
     "profileID": 2,
     "description": "",
     "minZoom": 12,
     "title": "KB three",
     "longitude": -122.41413938,
     "type": 1,
     "accuracy": 5,
     "id": 2] */
    
}
