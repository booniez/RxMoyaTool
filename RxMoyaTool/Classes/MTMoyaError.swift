//
//  MTMoyaError.swift
//  RxMoyaTool
//
//  Created by kled on 2022/1/6.
//

public enum MTMoyaError {
    case timeOut
    case serverDataError
    case dataMapError(String)
    case server(String, String)
    case tokenInvalid
    case refreshTokenError
}

extension MTMoyaError: Error {}

public extension MTMoyaError {
    var errorMessage: String {
        switch self {
        case .timeOut:
            return "网络异常，请检查网络"
        case .serverDataError:
            return "服务器返回数据错误"
        case .server(_, let msg):
            return msg
        case .tokenInvalid:
            return "会话过期"
        case .dataMapError:
            return "数据解析出错"
        case .refreshTokenError:
            return "登录信息过期,请重新登录"
        }
    }
}
