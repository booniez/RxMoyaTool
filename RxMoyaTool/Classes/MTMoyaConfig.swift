//
//  MTMoyaConfig.swift
//  RxMoyaTool
//
//  Created by kled on 2022/1/6.
//

import Foundation

public class MTMoyaConfig: NSObject {
    public static let shared = MTMoyaConfig()
    
    /// The network returned a response, including status code
    public var networkResponseCode: Int = 200
    
    public var timeoutIntervalForRequest: TimeInterval = 20
    public var timeoutIntervalForResource: TimeInterval = 20
    
    public var host = ""
    
    public var openLogger = false
    
}

public protocol MTMoyaConf {
    func baseModel() -> Decodable
}

struct NetModel: Decodable {
    let message: String?
    let status: Int
    var isSucceed: Bool {
        return MTMoyaConfig.shared.networkResponseCode == status
    }
}
