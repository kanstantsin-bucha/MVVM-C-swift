//
//  MapViewController.swift
//  doroga
//
//  Created by truebucha on 8/9/16.
//  Copyright © 2016 Bucha Kanstantsin. All rights reserved.
//

import Foundation
import GoogleMaps
import CDBPlacedUI


class MapViewController: UIViewController {
    
    var mapView: GMSMapView?
    
    var mapLogic: MapLogicProtocol? {
        willSet {
            mapLogic?.viewDelegate = nil
        }
        didSet {
            mapLogic?.viewDelegate = self
            refreshDisplay()
        }
    }
}

// MARK: - LifeCycle -
extension MapViewController  {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let camera = GMSCameraPosition.camera(withLatitude: 53.9, longitude: 27.57, zoom: 11.0)
        mapView = GMSMapView.map(withFrame:CGRect.zero, camera: camera)
        mapView?.isMyLocationEnabled = true
        mapView?.isTrafficEnabled = true
        mapView?.settings.compassButton = true
        mapView?.settings.myLocationButton = true
        
        CDBPlaceholderMaster.placeUI(mapView!,
                                     inPlaceholder: view,
                                     using: [.centered, .equalSize])
        
        // Creates a marker in the center of the map.
        
        mapLogic?.requestUsersPositions(self)
    }
}

// MARK: - Workers -
extension MapViewController  {
    func refreshDisplay() {
        
    }
}

// MARK: - MapLogic_ViewProtocol -
extension MapViewController: MapLogic_ViewProtocol {
    func markersDidChange(_ logic: MapLogicProtocol, markers: Array<MapMarker>?) {
    
        mapView?.clear()
        
        guard markers != nil else {
            return
        }
        
        for mapMarker in markers! {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: mapMarker.location.latitude,
                                                     longitude: mapMarker.location.longitude)
            marker.title = mapMarker.title
            marker.snippet = mapMarker.description
            marker.map = mapView
        }
    }
    
    func userLocationDidChange(_ logic: MapLogicProtocol) {
    }
}
