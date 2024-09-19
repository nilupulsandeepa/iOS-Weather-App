//
//  WANetworkManager.swift
//  WeatherApp
//
//  Created by Nilupul Sandeepa on 2024-09-17.
//

import Network

public class WANetworkManager: NSObject {
    
    //---- MARK: Properties
    public static var shared: WANetworkManager = WANetworkManager()
    
    private var g_NetworkMonitor: NWPathMonitor!
    private var g_NetworkMonitorQueue: DispatchQueue!
    
    public var delegate: WANetworkManagerDelegate?
    
    //---- MARK: Constructor
    private override init() {
        super.init()
        
        initialize()
    }
    
    //---- MARK: Initialization
    private func initialize() {
        g_NetworkMonitor = NWPathMonitor()
        g_NetworkMonitor.pathUpdateHandler = {
            path in
            if (path.status == .satisfied) {
                DispatchQueue.main.async {
                    if (self.delegate != nil) {
                        self.delegate?.networkStatusChanged(status: .available)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    if (self.delegate != nil) {
                        self.delegate?.networkStatusChanged(status: .unavailable)
                    }
                }
            }
            print("Status : \(path.status) | Expensive : \(path.isExpensive)")
        }
        g_NetworkMonitorQueue = DispatchQueue(label: "WANetworkMonitorQueue")
        g_NetworkMonitor.start(queue: g_NetworkMonitorQueue)
    }
}

//---- MARK: WANetworkManager protocol
public protocol WANetworkManagerDelegate {
    func networkStatusChanged(status: WANetworkState)
}
