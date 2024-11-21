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
        guard let accessToken = KeychainManager.shared.getItem(forKey: .accessToken) else { return }

        var urlRequest = urlRequest
        urlRequest.setValue(accessToken, forHTTPHeaderField: "Authorization")
        print("DEBUG: adator 적용 \(urlRequest.headers)")
        completion(.success(urlRequest))
    }
    
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        print("DEBUG: retry 진행(\(request.retryCount)")
        
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
        
        let disposeBag = DisposeBag()
        guard let refreshToken = KeychainManager.shared.getItem(forKey: .refreshToken) else {
            completion(.doNotRetryWithError(error))
            return
        }
        
        NetworkManager.shared.performRequest(api: .refresh(refreshToken: refreshToken), model: [String: String].self)
            .asObservable()
            .bind(with: self) { owner, result in
                switch result {
                case .success(let value):
                    let newToken = value.values.map { String($0) }.first ?? ""
                    let _ = KeychainManager.shared.saveItem(item: newToken, forKey: .accessToken)
                    print("DEBUG: 액세스 토큰 갱신 성공으로 retry 진행")
                    completion(.retryWithDelay(0.2))
                
                case .failure(_):
                    completion(.doNotRetryWithError(NetworkError.responseCode(errorCode: "Refresh token expiration")))
                    print("ERROR: 액세스 토큰 갱신 실패로 retry 미진행")
                }
            }
            .disposed(by: disposeBag)
    }
}
