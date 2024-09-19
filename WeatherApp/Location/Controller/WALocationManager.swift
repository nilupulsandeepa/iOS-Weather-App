//
//  WALocationManagger.swift
//  WeatherApp
//
//  Created by Nilupul Sandeepa on 2024-09-11.
//

import CoreLocation

public class WALocationManager: NSObject {
    
    //---- MARK: Properties
    public static var shared: WALocationManager = WALocationManager()
    
    private var g_LocationManager: CLLocationManager!
    private var g_LocationAuthorizationState: CLAuthorizationStatus = .notDetermined
    public var delegate: WALocationManagerDelegate? = nil
    
    //---- MARK: Constructor
    private override init() {
        super.init()
        
        initialize()
    }
    
    //---- MARK: Initialization
    private func initialize() {
        g_LocationManager = CLLocationManager()
        g_LocationManager.delegate = self
    }
    
    //---- MARK: Action Methods
    public func requestLocation() {
        g_LocationManager.requestLocation()
    }
    
    public func requestLocationPermision() {
        g_LocationManager.requestWhenInUseAuthorization()
    }
    
    public func getCurrentLocationPermision() -> WALocationPermisionState {
        switch g_LocationManager.authorizationStatus {
        case .authorizedWhenInUse:
            return .whenInUse
        case .authorizedAlways:
            return .always
        default:
            return .denied
        }
    }
    
    //---- MARK: Helper Methods
    private func locationDidUpdated(updatedLocation: CLLocation) {
        let m_UpdatedLocationObject: WALocation = WALocation()
        m_UpdatedLocationObject.setLatitude(updatedLocation.coordinate.latitude)
        m_UpdatedLocationObject.setLongitude(updatedLocation.coordinate.longitude)
        
        if (delegate != nil) {
            delegate?.currentLocationChanged(newLocation: m_UpdatedLocationObject)
        }
    }
    
    private func locationPermisionDidChanged(authorizationState: CLAuthorizationStatus) {
        if (delegate != nil) {
            switch authorizationState {
            case .authorizedWhenInUse:
                delegate?.locationPermisionChanged(state: .whenInUse)
            case .authorizedAlways:
                delegate?.locationPermisionChanged(state: .always)
            case .denied, .restricted:
                delegate?.locationPermisionChanged(state: .denied)
            default:
                delegate?.locationPermisionChanged(state: .denied)
                break
            }
        }
    }
}

//---- MARK: Extensions
extension WALocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let m_UpdatedLocation: CLLocation = locations.first!
        locationDidUpdated(updatedLocation: m_UpdatedLocation)
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationPermisionDidChanged(authorizationState: manager.authorizationStatus)
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("\(error.localizedDescription)")
    }
}


//---- MARK: Location Manager Protocol
public protocol WALocationManagerDelegate {
    func currentLocationChanged(newLocation: WALocation)
    func locationPermisionChanged(state: WALocationPermisionState)
}
