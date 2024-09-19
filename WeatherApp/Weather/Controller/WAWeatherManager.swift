//
//  WAWeatherManager.swift
//  WeatherApp
//
//  Created by Nilupul Sandeepa on 2024-09-10.
//

import Foundation

public class WAWeatherManager: NSObject {
    
    //---- MARK: Properties
    public static var shared: WAWeatherManager = WAWeatherManager()
    
    private var g_CurrentLatitude: Float = .infinity
    private var g_CurrentLongitude: Float = .infinity
    
    //---- OpenWeather API
    private let g_APIKey: String = ""
    private let g_APIURLFormat: String = "https://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&appid=%@&units=metric"
    
    public var delegate: WAWeatherManagerDelegate?
    
    //---- MARK: Constructor
    override private init() {
        super.init()
    }
    
    //---- MARK: Action Methods
    public func updateCurrentLocation(latitude: Float, longitude: Float) {
        if (delegate != nil) {
            delegate!.weatherUpdateRequestStarted()
        }
        let m_APIURLString: String = String(format: g_APIURLFormat, latitude, longitude, g_APIKey)
        guard let m_APIURL: URL = URL(string: m_APIURLString) else {
            fatalError("Invalid weather url")
        }
        Task {
            await fetchCurrentWeather(url: m_APIURL)
        }
    }
    
    
    //---- MARK: Helper Methods
    private func fetchCurrentWeather(url: URL) async {
        do {
            let m_WeatherResponse: (Data, URLResponse) = try await URLSession.shared.data(from: url)
            let m_JSONData: Data = m_WeatherResponse.0
            let m_URLResponse: HTTPURLResponse = m_WeatherResponse.1 as! HTTPURLResponse
            if (m_URLResponse.statusCode == 200) {
                let m_JSONDecoder: JSONDecoder = JSONDecoder()
                m_JSONDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let m_CurrentWeather: WAWeather = try m_JSONDecoder.decode(WAWeather.self, from: m_JSONData)
                DispatchQueue.main.async {
                    if (self.delegate != nil) {
                        self.delegate!.currentWeatherChanged(newWeather: m_CurrentWeather)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    if (self.delegate != nil) {
                        print(m_URLResponse.statusCode)
                        self.delegate!.weatherUpdateFailed()
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                if (self.delegate != nil) {
                    print(error.localizedDescription)
                    self.delegate!.weatherUpdateFailed()
                }
            }
        }
    }
}


//---- MARK: Weather Manager Protocol
public protocol WAWeatherManagerDelegate {
    func weatherUpdateRequestStarted()
    func currentWeatherChanged(newWeather: WAWeather)
    func weatherUpdateFailed()
}
