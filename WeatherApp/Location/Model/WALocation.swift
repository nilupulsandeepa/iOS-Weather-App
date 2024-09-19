//
//  WALocation.swift
//  WeatherApp
//
//  Created by Nilupul Sandeepa on 2024-09-11.
//

import CoreLocation

public class WALocation {
    
    //---- MARK: Properties
    private var g_Latitude: CLLocationDegrees = .zero
    private var g_Longitude: CLLocationDegrees = .zero
    
    //---- MARK: Action Methods
    public func setLatitude(_ latitude: CLLocationDegrees) {
        g_Latitude = latitude
    }
    
    public func getLatitude() -> CLLocationDegrees {
        return g_Latitude
    }
    
    public func setLongitude(_ longitude: CLLocationDegrees) {
        g_Longitude = longitude
    }
    
    public func getLongitude() -> CLLocationDegrees {
        return g_Longitude
    }
    
    public func description() -> String {
        return "WALocation: Latitude: \(g_Latitude.magnitude) | Longitude: \(g_Longitude.magnitude)"
    }
}
