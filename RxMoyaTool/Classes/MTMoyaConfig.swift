//
//  MTMoyaConfig.swift
//  RxMoyaTool
//
//  Created by kled on 2022/1/6.
//

import Foundation

public class MTMoyaConfig {
    public static let shared = MTMoyaConfig()
    
    public var mtMoyaConf: MTMoyaConfProtocol?
    
    public func startWith(_ mtMoyaConf: MTMoyaConfProtocol) {
        self.mtMoyaConf = mtMoyaConf
    }
    
}

@objc public protocol MTMoyaConfProtocol {
    /// Determine the rest request is successful or unsuccessful
    @objc optional func baseModelIsSucceed(_ data: Data) -> Bool

    /// The network returned a response status code
    @objc optional func baseModelStatusCode(_ data: Data) -> String

    /// The network returned a response message
    @objc optional func baseModelMessage(_ data: Data) -> String
    
    /// timeoutIntervalForRequest
    /// default 20.0
    @objc optional func timeoutIntervalForRequest() -> TimeInterval
    
    /// timeoutIntervalForResource
    /// /// default 20.0
    @objc optional func timeoutIntervalForResource() -> TimeInterval
    
    /// rest requests host
    func host() -> String
    
    /// open request logger
    /// default false
    @objc optional func openLogger() -> Bool
    
    /// The network returned a response status code
    /// default 200
    @objc optional func networkResponseCode() -> Int
    
    
}
