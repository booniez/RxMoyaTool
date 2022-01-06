//
//  MTMoyaProvider.swift
//  RxMoyaTool
//
//  Created by kled on 2022/1/6.
//

import Moya
import RxSwift
import RxCocoa
import Alamofire

public class MTMoyaProvider<Target: TargetType> {
    private let provider: MoyaProvider<Target>

    public init(endpointClosure: @escaping MoyaProvider<Target>.EndpointClosure = MTMoyaProvider.endpointMapping,
         stubClosure: @escaping MoyaProvider<Target>.StubClosure = MoyaProvider.neverStub,
         manager: Manager = MTMoyaProvider.sessionManager(),
                plugins: [PluginType] = [MTMoyaLogger()],
         trackInflights: Bool = false) {
        self.provider = MoyaProvider(endpointClosure: endpointClosure,
                                     stubClosure: stubClosure,
                                     manager: manager,
                                     plugins: plugins,
                                     trackInflights: trackInflights)
    }

    public func request(_ target: Target) -> Observable<Moya.Response> {
        return provider.rx
            .request(target)
            .filterSuccessfulStatusAndRedirectCodes()
            .asObservable()
    }

}


extension MTMoyaProvider {

   public static func endpointMapping(_ target: Target) -> Endpoint {
        var urlString = URL.init(target: target).absoluteString
        urlString = urlString.replacingOccurrences(of: "%3F", with: "?")
        return Endpoint(
            url: urlString,
            sampleResponseClosure: { .networkResponse(MTMoyaConfig.shared.networkResponseCode, target.sampleData) },
            method: target.method,
            task: target.task,
            httpHeaderFields: target.headers
        )
    }

    public static func sessionManager() -> Manager {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = MTMoyaConfig.shared.timeoutIntervalForRequest
        configuration.timeoutIntervalForResource = MTMoyaConfig.shared.timeoutIntervalForResource
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            MTMoyaConfig.shared.host: .pinCertificates(certificates: ServerTrustPolicy.certificates(), validateCertificateChain:true, validateHost:false)
        ]
        
        let sessionDelegate = SessionDelegate()
        
        let manager = SessionManager.init(configuration: configuration, delegate: sessionDelegate, serverTrustPolicyManager: ServerTrustPolicyManager.init(policies: serverTrustPolicies))
        sessionDelegate.sessionDidReceiveChallenge = { session, challenge in
            var disposition: URLSession.AuthChallengeDisposition = .performDefaultHandling
            var credential: URLCredential?
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
                disposition = URLSession.AuthChallengeDisposition.useCredential
                credential = URLCredential.init(trust: challenge.protectionSpace.serverTrust!)
            } else {
                if challenge.previousFailureCount > 0 {
                    disposition = .cancelAuthenticationChallenge
                } else {
                    if let cr =
                        manager.session.configuration.urlCredentialStorage?.defaultCredential(for: challenge.protectionSpace) {
                        disposition = .useCredential
                        credential = cr
                    }
                }
            }
            return (disposition, credential)
        }
        return manager
    }

}

public extension ObservableType where E == Response {

    //data字段为空（或者值没有意义）时，使用 MapVoid()
    func mapVoid() -> Observable<Void> {
        return mapToModel(NetModel.self, keyPath: "").map { _ in Void() }
    }
    
    func mapToModel<T: Decodable>(_: T.Type, decoder: JSONDecoder = JSONDecoder.init(), keyPath: String = "data") -> Observable<T> {
        return map({ (response) -> T in
            let object = try MTMoyaProviderDecodable.decodableObject(data: response.data, type: T.self, decoder: decoder, keyPath: keyPath)
            return object
        }).catchError { (err) -> Observable<T> in
            return Observable<T>.create({ (observe) -> Disposable in
                var finalError = MTMoyaError.server(0, "")
                if let error = err as? MoyaError, let reponse = error.response {
                    if reponse.statusCode == NSURLErrorTimedOut {
                        finalError = MTMoyaError.timeOut
                    }
                } else if let error = err as? MTMoyaError {
                    finalError = error
                }
                observe.onError(finalError)
                return Disposables.create()
            })}
    }

    func mapToArrayModel<T: Decodable>(_: T.Type, decoder: JSONDecoder = JSONDecoder.init(), keyPath: String? = "data") -> Observable<[T]> {

        return map({ (response) -> [T] in
            let object = try MTMoyaProviderDecodable.decodableArrayObject(data: response.data,
                                                          type: T.self,
                                                          decoder: decoder,
                                                          keyPath: keyPath)
            return object
        }).catchError { (err) -> Observable<[T]> in
            return Observable<[T]>.create({ (observe) -> Disposable in
                var finalError = MTMoyaError.server(0, "")
                if let error = err as? MoyaError, let reponse = error.response {
                    if reponse.statusCode == NSURLErrorTimedOut {
                        finalError = MTMoyaError.timeOut
                    }
                } else if let error = err as? MTMoyaError {
                    finalError = error
                }
                observe.onError(finalError)
                return Disposables.create()
            })}
    }

    func mapToDict() -> Observable<[String: Any]> {
        return map({ (response) -> [String: Any] in
            let json = try JSONSerialization.jsonObject(with: response.data, options: .allowFragments)
            if let dict = json as? [String: Any] {
                let status = dict["status"] as? Int
                if status != nil, status == 200 {
                    return dict
                }
                let message = dict["message"] as? String
                throw MTMoyaError.server(status ?? 0, message ?? "未知错误")
            }
            throw MTMoyaError.serverDataError
        }).catchError { (err) -> Observable<[String: Any]> in
            return Observable<[String: Any]>.create({ (observe) -> Disposable in
                var finalError = MTMoyaError.server(0, "")
                if let error = err as? MoyaError, let reponse = error.response {
                    if reponse.statusCode == NSURLErrorTimedOut {
                        finalError = MTMoyaError.timeOut
                    }
                } else if let error = err as? MTMoyaError {
                    finalError = error
                }
                observe.onError(finalError)
                return Disposables.create()
            })}
    }
}
