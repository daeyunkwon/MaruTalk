//
//  AuthInterceptor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/21/24.
//

import Foundation

import Alamofire
import RxCocoa
import RxSwift

final class AuthInterceptor: RequestInterceptor {
 
    static let shared = AuthInterceptor()
    private init() { }
    
    private let maxRetryCount = 3
    
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        if let accessToken = KeychainManager.shared.getItem(forKey: .accessToken) {
            var urlRequest = urlRequest
            urlRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
            print("DEBUG: adapt 실행")
            completion(.success(urlRequest))
        } else {
            completion(.success(urlRequest))
        }
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("DEBUG: retry 진행 \(request.retryCount)")
        // 최대 재시도 횟수 초과 시 중단
        if request.retryCount >= maxRetryCount {
            print("DEBUG: 최대 재시도 횟수 초과로 retry 중단")
            completion(.doNotRetryWithError(error))
            return
        }
        
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 400 else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        guard KeychainManager.shared.getItem(forKey: .refreshToken) != nil else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        NetworkManager.shared.refreshToken { result in
            switch result {
            case .success(_):
                completion(.retry)
                print("DEBUG: 토큰 갱신 성공 retry 진행")
            case .failure(_):
                completion(.doNotRetryWithError(NetworkError.responseCode(errorCode: "Refresh token expiration")))
                print("ERROR: 토큰 갱신 실패 retry 스탑")
            }
        }
    }
}
