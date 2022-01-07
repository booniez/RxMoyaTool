//
//  MTMoyaLogger.swift
//  RxMoyaTool
//
//  Created by kled on 2022/1/6.
//

import Moya
import Result

public class MTMoyaLogger: PluginType {
    public init() {
        
    }
    
    /// Called immediately before a request is sent over the network (or stubbed).
    public func willSend(_ request: RequestType, target: TargetType) {
        if MTMoyaConfig.shared.mtMoyaConf?.openLogger?() ?? false {
            print("MTMoyaLogger requestUrl: \(request.request?.url?.absoluteString ?? String())")
        }
    }
    /// Called after a response has been received, but before the MoyaProvider has invoked its completion handler.
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        if MTMoyaConfig.shared.mtMoyaConf?.openLogger?() ?? false {
            switch result {
            case .success(let response):
                print("MTMoyaLogger requestUrl: \(response.response?.url?.absoluteString ?? String())")
                    if let json = try? response.mapJSON() {
                        print("MTMoyaLogger Response:")
                        print(json)
                    }
            case .failure(let error):
                print("MTMoyaLogger error: \(error.localizedDescription)")
            }
        }
    }        
}
