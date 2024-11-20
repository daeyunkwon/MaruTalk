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
    
    func performRequest<T: Decodable>(api: Router, model: T.Type) -> Single<Result<T, NetworkError>> {
        return Single.create { single -> Disposable in
            
            do {
                let request = try api.asURLRequest()
                
                AF.request(request).validate(statusCode: 200..<300).responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        single(.success(.success(value)))
                    
                    case .failure(let error):
                        print(error)
                        
                        if let data = response.data {
                            //에러 코드 디코딩 작업
                            if let result = try? JSONDecoder().decode(SLPErrorResponse.self, from: data) {
                                print("Error response: \(result)")
                                single(.success(.failure(.responseCode(errorCode: result.errorCode))))
                            } else {
                                //디코딩 작업 실패
                                single(.success(.failure(.responseCode(errorCode: nil))))
                            }
                        } else {
                            //서버에서 주는 에러 코드 데이터가 없는 경우
                            single(.success(.failure(.responseCode(errorCode: nil))))
                        }
                    }
                }
            } catch {
                print("Error: request 생성 실패")
                single(.success(.failure(.invalidURL)))
            }
            
            return Disposables.create()
        }
    }
    
    func performRequestMultipartFormData<T: Decodable>(api: Router, model: T.Type) -> Single<Result<T, NetworkError>> {
        return Single.create { single -> Disposable in
            
            guard let multipartFormData = api.multipartFormData else {
                single(.success(.failure(.invalidRequestData)))
                print("ERROR: invalid multipartFormData")
                return Disposables.create()
            }
            
            guard let url = URL(string: api.baseURL + api.path) else {
                single(.success(.failure(.invalidURL)))
                print("ERROR: invalid url")
                return Disposables.create()
            }
            
            let headers: HTTPHeaders = HTTPHeaders(api.header.map { HTTPHeader(name: $0.key, value: $0.value) })
            
            AF.upload(multipartFormData: multipartFormData, to: url, method: api.method, headers: headers).responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    single(.success(.success(value)))
                    
                case .failure(let error):
                    print(error)
                    
                    if let data = response.data {
                        //에러 코드 디코딩 작업
                        if let result = try? JSONDecoder().decode(SLPErrorResponse.self, from: data) {
                            print("Error response: \(result)")
                            single(.success(.failure(.responseCode(errorCode: result.errorCode))))
                        } else {
                            //디코딩 작업 실패
                            single(.success(.failure(.responseCode(errorCode: nil))))
                        }
                    } else {
                        //서버에서 주는 에러 코드 데이터가 없는 경우
                        single(.success(.failure(.responseCode(errorCode: nil))))
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    func checkEmailDuplication(email: String) -> Single<Result<Void, NetworkError>> {
        return Single.create { single -> Disposable in
            
            do {
                let request = try Router.emailValidation(email).asURLRequest()
                
                AF.request(request).validate(statusCode: 200...299).responseData(emptyResponseCodes: [200]) { response in
                    switch response.result {
                    case .success(_):
                        single(.success(.success(())))
                        
                    case .failure(let error):
                        print(error)
                        
                        if let data = response.data {
                            //에러 코드 디코딩 작업
                            if let result = try? JSONDecoder().decode(SLPErrorResponse.self, from: data) {
                                print("Error response: \(result)")
                                single(.success(.failure(.responseCode(errorCode: result.errorCode))))
                            } else {
                                //디코딩 작업 실패
                                single(.success(.failure(.responseCode(errorCode: nil))))
                            }
                        } else {
                            //서버에서 주는 에러 코드 데이터가 없는 경우
                            single(.success(.failure(.responseCode(errorCode: nil))))
                        }
                    }
                }
            } catch {
                single(.success(.failure(.invalidURL)))
            }
            
            return Disposables.create()
        }
    }
}
