//
//  NetworkManager.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/4/24.
//

import Foundation

import Alamofire
import RxSwift

final class NetworkManager {
    
    static let shared = NetworkManager()
    private init() { }
    
    func performRequest<T: Decodable>(api: Router, model: T.Type) -> Single<Result<T, Error>> {
        return Single.create { single -> Disposable in
            
            do {
                let request = try api.asURLRequest()
                
                AF.request(request).validate(statusCode: 200..<300).responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        single(.success(.success(value)))
                        print(1111)
                    
                    case .failure(let error):
                        print(22222)
                        switch error {
                        case .responseSerializationFailed(let reason):
                            switch reason {
                            case .inputDataNilOrZeroLength:
                                if response.response?.statusCode ?? 0 == 200 {
                                    //서버에서 빈 값을 줬으나, 이는 정상 케이스인 경우
//                                    single(.success(.success(EmptyEntity.emptyValue() as! T)))
                                }
                            default: print(error)
                            }
                        default: 
                            print(error)
                            print(response.response?.statusCode)
                        }
                    }
                }
            } catch {
                print("Error: request 생성 실패")
            }
            
            return Disposables.create()
        }
    }
    
    func checkEmailDuplication(email: String) -> Single<Result<Void, Error>> {
        return Single.create { single -> Disposable in
            
            do {
                let request = try Router.emailValidation(email).asURLRequest()
                
                AF.request(request).validate(statusCode: 200..<300).responseData(emptyResponseCodes: [200]) { response in
                    switch response.result {
                    case .success(_):
                        single(.success(.success(())))
                    
                    case .failure(let error):
                        print(error)
                    }
                }
            } catch {
                print("Error: request 생성 실패")
            }
            
            return Disposables.create()
        }
    }
}
