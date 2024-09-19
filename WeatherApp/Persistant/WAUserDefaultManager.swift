//
//  UserDefaultManager.swift
//  WeatherApp
//
//  Created by Nilupul Sandeepa on 2024-09-12.
//

import Foundation

public class WAUserDefaultManager {
    
    public static var shared: WAUserDefaultManager = WAUserDefaultManager()
    
    public var isAppFirstTime: Bool {
        get {
            return UserDefaults.standard.value(forKey: WANamespace.WAUserDefaultIdentifiers.isAppFirstTime) as? Bool ?? true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: WANamespace.WAUserDefaultIdentifiers.isAppFirstTime)
        }
    }
}
