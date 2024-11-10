//
//  Router.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/4/24.
//

import Foundation

import Alamofire

enum Router {
    case emailValidation(String)
    case join(email: String, password: String, nickname: String, phone: String, deviceToken: String)
    
    
    enum APIType {
        case empty //초기화용 빈 값
        case emailValidation
        case join
    }
}

extension Router: URLRequestConvertible {
    
    var baseURL: String {
        return APIURL.baseURL
    }
    
    var path: String {
        switch self {
        case .emailValidation(_): return APIURL.validEmail
        case .join: return APIURL.join
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .emailValidation(_), .join:
            return .post
        }
    }
    
    var header: [String: String] {
        switch self {
        case .emailValidation(_), .join:
            return [
                "Content-Type": "application/json",
                "SesacKey": APIKey.apiKey
            ]
            
        default:
            return [:]
        }
    }
    
    var body: Data? {
        switch self {
        case .emailValidation(let email):
            return try? JSONEncoder().encode([
                BodyKey.email: email
            ])
            
        case .join(let email, let password, let nickname, let phone, let deviceToken):
            return try? JSONEncoder().encode([
                BodyKey.email: email,
                BodyKey.password: password,
                BodyKey.nickname: nickname,
                BodyKey.phone: phone,
                BodyKey.deviceToken: deviceToken
            ])
            
        default:
            return nil
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        
            
        default:
            return nil
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: baseURL + path) else {
            throw URLError(.badURL)
        }
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = header
        
        //body 데이터 셋팅
        if method == .post || method == .put || method == .patch {
            request.httpBody = body
        }
        
        //query 데이터 셋팅
        if method == .get {
            urlComponents.queryItems = query
            guard let newURL = urlComponents.url else {
                throw URLError(.badURL)
            }
            request.url = newURL
        }
        
        return request
    }
}

