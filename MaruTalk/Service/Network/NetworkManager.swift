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
                AF.request(request, interceptor: AuthInterceptor.shared).validate(statusCode: 200..<300).responseDecodable(of: T.self) { response in
                    switch response.result {
                    case .success(let value):
                        single(.success(.success(value)))
                    
                    case .failure(let error):
                        print(error)
                        
                        if let refreshError = error.asAFError?.underlyingError as? NetworkError {
                            //리프레시 만료 에러의 경우
                            single(.success(.failure(.responseCode(errorCode: refreshError.errorCode))))
                        }
                        
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
            
            AF.upload(multipartFormData: multipartFormData, to: url, method: api.method, headers: headers, interceptor: AuthInterceptor.shared).responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    single(.success(.success(value)))
                    
                case .failure(let error):
                    print(error)
                    
                    if let refreshError = error.asAFError?.underlyingError as? NetworkError {
                        //리프레시 만료 에러의 경우
                        single(.success(.failure(.responseCode(errorCode: refreshError.errorCode))))
                    }
                    
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
    
    //이메일 중복 확인
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
    
    //서버로부터 이미지 데이터 요청(사용안할듯?)
//    func fetchImageData(imagePath: String) -> Single<Result<Data, NetworkError>> {
//        return Single.create { single -> Disposable in
//            
//            do {
//                let request = try Router.fetchImage(imagePath: imagePath).asURLRequest()
//                
//                AF.request(request, interceptor: AuthInterceptor.shared).validate(statusCode: 200..<300).responseData { response in
//                    switch response.result {
//                    case .success(let value):
//                        single(.success(.success(value)))
//                        
//                    case .failure(let error):
//                        if let refreshError = error.asAFError?.underlyingError as? NetworkError {
//                            //리프레시 만료 에러의 경우
//                            single(.success(.failure(.responseCode(errorCode: refreshError.errorCode))))
//                        }
//                        
//                        if let data = response.data {
//                            //에러 코드 디코딩 작업
//                            if let result = try? JSONDecoder().decode(SLPErrorResponse.self, from: data) {
//                                print("Error response: \(result)")
//                                single(.success(.failure(.responseCode(errorCode: result.errorCode))))
//                            } else {
//                                //디코딩 작업 실패
//                                single(.success(.failure(.responseCode(errorCode: nil))))
//                            }
//                        } else {
//                            //서버에서 주는 에러 코드 데이터가 없는 경우
//                            single(.success(.failure(.responseCode(errorCode: nil))))
//                        }
//                    }
//                }
//            } catch {
//                print("Error: request 생성 실패")
//                single(.success(.failure(.invalidURL)))
//            }
//            return Disposables.create()
//        }
//    }
    
    //서버로부터 이미지 요청
    func downloadImageData(imagePath: String?, completion: @escaping (Data) -> Void) {
        do {
            guard let path = imagePath else { return }
            let request = try Router.fetchImage(imagePath: path).asURLRequest()
            
            AF.request(request, interceptor: AuthInterceptor.shared).responseData { response in
                switch response.result {
                case .success(let value):
                    completion(value)
                case .failure(let error):
                    print(error)
                }
            }
        } catch {
            print("Error: request 만들기 실패: \(error)")
        }
    }
    
    //액세스 토큰 갱신 요청
    func refreshToken(completionHandler: @escaping (Result<Bool, NetworkError>) -> Void) {
        do {
            guard let token = KeychainManager.shared.getItem(forKey: .refreshToken) else { return }
            let request = try Router.refresh(refreshToken: token).asURLRequest()
            
            AF.request(request).validate(statusCode: 200...299).responseDecodable(of: [String: String].self) { response in
                
                switch response.result {
                case .success(let value):
                    let newToken = value.values.map { String($0) }.first ?? ""
                    let _ = KeychainManager.shared.saveItem(item: newToken, forKey: .accessToken)
                    completionHandler(.success(true))
                    
                case .failure(let error):
                    print(error)
                    completionHandler(.failure(.invalidRequestData))
                    
                    if let data = response.data {
                        //에러 코드 디코딩 작업
                        if let result = try? JSONDecoder().decode(SLPErrorResponse.self, from: data) {
                            print("Error response: \(result)")
                        }
                    }
                }
            }
        } catch {
            print("Error: request 만들기 실패: \(error)")
        }
    }
    
    //워크스페이스 & 채널 삭제용
    func performDelete(api: Router) -> Single<Result<Void, NetworkError>> {
        return Single.create { single -> Disposable in
            
            do {
                let request = try api.asURLRequest()
                
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
