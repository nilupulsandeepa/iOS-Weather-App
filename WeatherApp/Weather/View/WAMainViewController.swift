//
//  WAMainViewController.swift
//  WeatherApp
//
//  Created by Nilupul Sandeepa on 2024-09-10.
//

import UIKit

public class WAMainViewController: UIViewController {
    
    //----  MARK: Properties
    private var g_AppState: WAAppState = .none
    
    public override func viewDidLoad() {
        WALocationManager.shared.delegate = self
        WAWeatherManager.shared.delegate = self
        WANetworkManager.shared.delegate = self
        
        configureUI()
    }
    
    //---- MARK: Helper Methods
    //---- UI Methods
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(g_CurrentWeatherConditionImageView)
        g_CurrentWeatherConditionImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 48).isActive = true
        g_CurrentWeatherConditionImageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        g_CurrentWeatherConditionImageView.heightAnchor.constraint(equalToConstant: 64).isActive = true
        g_CurrentWeatherConditionImageView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        view.addSubview(g_CurrentWeatherConditionView)
        g_CurrentWeatherConditionView.topAnchor.constraint(equalTo: g_CurrentWeatherConditionImageView.bottomAnchor, constant: 4).isActive = true
        g_CurrentWeatherConditionView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -48).isActive = true
        g_CurrentWeatherConditionView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        view.addSubview(g_LocationNameView)
        g_LocationNameView.topAnchor.constraint(equalTo: g_CurrentWeatherConditionView.bottomAnchor, constant: 24).isActive = true
        g_LocationNameView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        g_LocationNameView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -48).isActive = true
        
        view.addSubview(g_TemperatureContainerView)
        g_TemperatureContainerView.topAnchor.constraint(equalTo: g_LocationNameView.bottomAnchor, constant: 24).isActive = true
        g_TemperatureContainerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        g_TemperatureContainerView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -48).isActive = true
        
        view.addSubview(g_TemperatureFeelsLikeValueView)
        g_TemperatureFeelsLikeValueView.topAnchor.constraint(equalTo: g_TemperatureValueView.bottomAnchor, constant: 8).isActive = true
        g_TemperatureFeelsLikeValueView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        g_TemperatureFeelsLikeValueView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, constant: -48).isActive = true
        
        view.addSubview(g_DataLoadingActivityView)
        g_DataLoadingActivityView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        g_DataLoadingActivityView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        g_DataLoadingActivityView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor).isActive = true
        g_DataLoadingActivityView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor).isActive = true
    }
    
    //---- Location Methods
    private func updateCurrentLocation(location: WALocation) {
        g_LoadingProgressDescriptionView.text = "Fetching weather..."
        g_AppState = .weatherUpdating
        WAWeatherManager.shared.updateCurrentLocation(latitude: Float(location.getLatitude().magnitude), longitude: Float(location.getLongitude().magnitude))
    }
    
    private func checkLocationPermision(state: WALocationPermisionState) {
        switch state {
        case .whenInUse, .always:
            print("1111111")
            g_LoadingActivityIndicatorView.startAnimating()
            g_LoadingProgressDescriptionView.text = "Fetching location..."
            g_AppState = .locationUpdating
            WALocationManager.shared.requestLocation()
        default:
            if (WAUserDefaultManager.shared.isAppFirstTime) {
                WALocationManager.shared.requestLocationPermision()
                WAUserDefaultManager.shared.isAppFirstTime = false
            } else {
                g_LoadingProgressDescriptionView.text = "Cannot fetch location info!"
                showLocationPermissionAlert()
            }
        }
    }
    
    private func showLocationPermissionAlert() {
        let alert = UIAlertController(title: "Location Access Denied", message: "To get weather updates, enable location access in Settings.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Open Settings", style: .default) { _ in
            if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSettings)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //---- Weather Methods
    private func updateCurrentWeather(weather: WAWeather) {
        g_CurrentWeatherConditionView.text = weather.weather[0].description.capitalized
        g_LocationNameView.text = weather.name
        g_TemperatureValueView.text = "\(Int(weather.main.temp))℃"
        g_TemperatureFeelsLikeValueView.text = "Feels like: \(Int(weather.main.feelsLike))℃"
        
        g_LoadingActivityIndicatorView.stopAnimating()
        g_DataLoadingActivityView.isHidden = true
        
        g_AppState = .weatherDidUpdate
    }
    
    private func weatherUpdateFailedForCurrentLocation() {
        g_AppState = .locationDidUpdate
    }
    
    //---- Network Methods
    private func updateNetworkStatus(status: WANetworkState) {
        if (status == .available) {
            if (g_AppState != .none && g_AppState != .weatherDidUpdate) {
                g_LoadingActivityIndicatorView.startAnimating()
                g_LoadingProgressDescriptionView.text = "Fetching location..."
                g_AppState = .locationUpdating
                print("22222222")
                WALocationManager.shared.requestLocation()
            }
        } else {
            g_LoadingActivityIndicatorView.stopAnimating()
            g_LoadingProgressDescriptionView.text = "Turn on your internet connection!"
            g_AppState = .none
            
        }
    }
    
    //---- MARK: UI Components
    private lazy var g_CurrentWeatherConditionImageView: UIImageView = {
        let m_View: UIImageView = UIImageView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        let m_ImageConfig = UIImage.SymbolConfiguration(paletteColors: [.systemTeal, .white])
        let m_SymbolImage: UIImage = UIImage(systemName: "cloud")!.withRenderingMode(.alwaysTemplate)
        m_View.image = m_SymbolImage.applyingSymbolConfiguration(m_ImageConfig)
        m_View.tintAdjustmentMode = .normal
        m_View.contentMode = .center
        m_View.contentMode = .scaleAspectFit
        
        return m_View
    }()
    
    private lazy var g_CurrentWeatherConditionView: UILabel = {
        let m_View: UILabel = UILabel()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.text = "Rainy"
        m_View.textAlignment = .center
        m_View.font = .systemFont(ofSize: 30)
        m_View.textColor = .black
        
        return m_View
    }()
    
    private lazy var g_LocationNameView: UILabel = {
        let m_View: UILabel = UILabel()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.text = "Galle"
        m_View.textAlignment = .center
        m_View.font = .systemFont(ofSize: 24)
        m_View.textColor = .darkGray
        
        return m_View
    }()
    
    private lazy var g_TemperatureContainerView: UIView = {
        let m_View: UIView = UIView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.addSubview(g_TemperatureValueView)
        g_TemperatureValueView.leadingAnchor.constraint(equalTo: m_View.leadingAnchor).isActive = true
        g_TemperatureValueView.topAnchor.constraint(equalTo: m_View.topAnchor).isActive = true
        g_TemperatureValueView.trailingAnchor.constraint(equalTo: m_View.trailingAnchor).isActive = true
        
        return m_View
    }()
    
    private lazy var g_TemperatureValueView: UILabel = {
        let m_View: UILabel = UILabel()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.text = "45℃"
        m_View.textAlignment = .center
        m_View.font = .systemFont(ofSize: 30)
        m_View.textColor = .systemTeal
        
        return m_View
    }()
    
    private lazy var g_TemperatureFeelsLikeValueView: UILabel = {
        let m_View: UILabel = UILabel()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.text = "Feels Like: 45℃"
        m_View.textAlignment = .center
        m_View.font = .systemFont(ofSize: 14)
        m_View.textColor = .black
        
        return m_View
    }()
    
    private lazy var g_DataLoadingActivityView: UIView = {
        let m_View: UIView = UIView()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.backgroundColor = .white
        
        m_View.addSubview(g_LoadingActivityIndicatorView)
        g_LoadingActivityIndicatorView.centerXAnchor.constraint(equalTo: m_View.centerXAnchor).isActive = true
        g_LoadingActivityIndicatorView.centerYAnchor.constraint(equalTo: m_View.centerYAnchor).isActive = true
        g_LoadingActivityIndicatorView.widthAnchor.constraint(equalToConstant: 32).isActive = true
        g_LoadingActivityIndicatorView.heightAnchor.constraint(equalToConstant: 32).isActive = true
        
        m_View.addSubview(g_LoadingProgressDescriptionView)
        g_LoadingProgressDescriptionView.topAnchor.constraint(equalTo: g_LoadingActivityIndicatorView.bottomAnchor, constant: 24).isActive = true
        g_LoadingProgressDescriptionView.widthAnchor.constraint(equalTo: m_View.widthAnchor, constant: -48).isActive = true
        g_LoadingProgressDescriptionView.centerXAnchor.constraint(equalTo: m_View.centerXAnchor).isActive = true
        
        return m_View
    }()
    
    private lazy var g_LoadingActivityIndicatorView: UIActivityIndicatorView = {
        let m_View: UIActivityIndicatorView = UIActivityIndicatorView(style: .large)
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        return m_View
    }()
    
    private lazy var g_LoadingProgressDescriptionView: UILabel = {
        let m_View: UILabel = UILabel()
        m_View.translatesAutoresizingMaskIntoConstraints = false
        
        m_View.text = "Fetching Location Info..."
        m_View.textAlignment = .center
        m_View.font = .systemFont(ofSize: 14)
        m_View.textColor = .black
        
        return m_View
    }()
}

//---- MARK: Extensions
//---- Location Delegate
extension WAMainViewController: WALocationManagerDelegate {
    public func currentLocationChanged(newLocation: WALocation) {
        updateCurrentLocation(location: newLocation)
    }
    
    public func locationPermisionChanged(state: WALocationPermisionState) {
        checkLocationPermision(state: state)
    }
}

//---- Weather Delegate
extension WAMainViewController: WAWeatherManagerDelegate {
    public func weatherUpdateFailed() {
        weatherUpdateFailedForCurrentLocation()
    }
    
    public func weatherUpdateRequestStarted() {
    }
    
    public func currentWeatherChanged(newWeather: WAWeather) {
        updateCurrentWeather(weather: newWeather)
    }
}

//---- Network Delegate
extension WAMainViewController: WANetworkManagerDelegate {
    public func networkStatusChanged(status: WANetworkState) {
        updateNetworkStatus(status: status)
    }
}
