//
//  ExampleAPI.swift
//  RxMoyaTool_Example
//
//  Created by kled on 2022/1/6.
//  Copyright © 2022 CocoaPods. All rights reserved.
//

import Moya
import RxMoyaTool

let exampleAPIProvider = MTMoyaProvider<ExampleAPI>()


enum ExampleAPI {
    //知乎最新日报列表
    case latestNews
}

// MARK: - TargetType Protocol Implementation
extension ExampleAPI: TargetType {
    var path: String {
        switch self {
        case .latestNews:
            return "/api/4/news/latest"        
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var parameters: [String : Any] {
        var _params = [String:Any]()
        switch self {
        default:
            break
        }
        return _params
    }
    
    var task: Task {
        return Task.requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String : String]? {
        return ["Content-Type":"application/x-www-form-urlencoded"]
    }
    
    var baseURL: URL {
        switch self {
        default:
            guard let url = URL.init(string: MTMoyaConfig.shared.mtMoyaConf?.host() ?? "") else {
                fatalError("host convert failed")
            }
            return url
        }
    }
}
