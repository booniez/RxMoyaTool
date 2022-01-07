//
//  MTMoyaProviderDecodable.swift
//  RxMoyaTool
//
//  Created by kled on 2022/1/6.
//

struct MTMoyaProviderDecodable {
    static func decodableObject<T: Decodable>(data: Data, type: T.Type,
                                              decoder: JSONDecoder = JSONDecoder.init(),
                                              keyPath: String? = "data") throws -> T {

        let json = try JSONSerialization.jsonObject(with: data,
                                                        options: .allowFragments)
        
        guard let keyPath = keyPath, !keyPath.isEmpty else {
            if (!JSONSerialization.isValidJSONObject(json)) {
                throw MTMoyaError.serverDataError
            }
            var nestedData: Data!
            var nestedObj: T!
            do {
                nestedData = try JSONSerialization.data(withJSONObject: json)
                nestedObj = try decoder.decode(T.self, from: nestedData)
            } catch {
                throw MTMoyaError.dataMapError("数据解析出错")
            }
            return nestedObj
        }
        let isSucceed = MTMoyaConfig.shared.mtMoyaConf?.baseModelIsSucceed?(data) ?? false
        let statusCode = MTMoyaConfig.shared.mtMoyaConf?.baseModelStatusCode?(data) ?? ""
        let message = MTMoyaConfig.shared.mtMoyaConf?.baseModelMessage?(data) ?? ""
        if isSucceed {
            if let nestedJson = (json as AnyObject).value(forKeyPath: keyPath) {
                if (!JSONSerialization.isValidJSONObject(nestedJson)) {
                    throw MTMoyaError.serverDataError
                }
                do {
                    let nestedData = try JSONSerialization.data(withJSONObject: nestedJson)
                    let nestedObj = try decoder.decode(T.self, from: nestedData)
                    return nestedObj
                } catch {
                    throw MTMoyaError.dataMapError("数据解析出错")
                }
            } else {
                throw MTMoyaError.server(statusCode, message)
            }
        }
        throw MTMoyaError.server(statusCode, message)

    }

    static func decodableArrayObject<T: Decodable>(data: Data, type: T.Type, decoder: JSONDecoder = JSONDecoder.init(), keyPath: String? = "data") throws -> [T] {

        guard let keyPath = keyPath, !keyPath.isEmpty else {
            // 适用于通用数据类型
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            if let nestedJsons = (json as AnyObject) as? NSArray {
                var nestedObjs: [T] = []
                for nestedJson in nestedJsons {
                    do {
                        let nestedData = try JSONSerialization.data(withJSONObject: nestedJson)
                        let nestedObj = try decoder.decode(T.self, from: nestedData)
                        nestedObjs.append(nestedObj)
                    } catch {
                        throw MTMoyaError.dataMapError("数据解析出错")
                    }
                }
                return nestedObjs
            } else {
                throw MTMoyaError.serverDataError
            }
        }
        
        // 适用于 含有 {status: 200, message:"",data: [xxx,xxx]}
        let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
        
        let isSucceed = MTMoyaConfig.shared.mtMoyaConf?.baseModelIsSucceed?(data) ?? false
        let statusCode = MTMoyaConfig.shared.mtMoyaConf?.baseModelStatusCode?(data) ?? ""
        let message = MTMoyaConfig.shared.mtMoyaConf?.baseModelMessage?(data) ?? ""
        
        
        if isSucceed {
            if let nestedJsons = ((json as Any) as AnyObject).value(forKeyPath: keyPath) as? NSArray {
                var nestedObjs: [T] = []
                for nestedJson in nestedJsons {
                    do {
                        let nestedData = try JSONSerialization.data(withJSONObject: nestedJson)
                        let nestedObj = try decoder.decode(T.self, from: nestedData)
                        nestedObjs.append(nestedObj)
                    } catch {
                        throw MTMoyaError.dataMapError("数据解析出错")
                    }
                }
                return nestedObjs
            } else {
                throw MTMoyaError.serverDataError
            }
        } else {
            throw MTMoyaError.server(statusCode, message)
        }
    }

}
