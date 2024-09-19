//
//  Weather.swift
//  WeatherApp
//
//  Created by Nilupul Sandeepa on 2024-09-10.
//

import Foundation

public struct WAWeather: Codable {
    
    var weather: [WACurrentWeather]
    var main: WAMainWeather
    var wind: WAWindWeather
    var clouds: WACloudsWeather
    var name: String
    
    public struct WAMainWeather: Codable {
        var temp: Float
        var feelsLike: Float
        var tempMin: Float
        var tempMax: Float
        var humidity: Int
    }
    
    public struct WACurrentWeather: Codable {
        var main: String
        var description: String
    }
    
    public struct WAWindWeather: Codable {
        var speed: Float
        var deg: Int
    }
    
    public struct WACloudsWeather: Codable {
        var all: Int
    }
}
