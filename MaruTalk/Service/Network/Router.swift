//
//  Router.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/4/24.
//

import Foundation

import Alamofire

enum Router {
    case refresh(refreshToken: String)
    case fetchImage(imagePath: String)
    
    case emailValidation(String)
    case join(email: String, password: String, nickname: String, phone: String, deviceToken: String)
    case login(email: String, password: String, deviceToken: String)
    case loginWithApple(idToken: String, nickname: String, deviceToken: String)
    case loginWithKakao(oauthToken: String, deviceToken: String)
    
    case workspaces //사용자가 속한 워크스페이스 리스트
    case createWorkspace(name: String, description: String, imageData: Data)
    case workspace(id: String) //특정 워크스페이스
    
    
    enum APIType {
        case empty //초기화용 빈 값
        case refresh
        case emailValidation
        case join
        case login
        case loginWithApple
        case loginWithKakao
        
        case workspaces
        case createWorkspace
        case workspace
    }
}

extension Router: URLRequestConvertible {
    var baseURL: String {
        return APIURL.baseURL
    }
    
    var path: String {
        switch self {
        case .refresh: return APIURL.refresh
        case .fetchImage(let imagePath): return "v1\(imagePath)"
        case .emailValidation: return APIURL.validEmail
        case .join: return APIURL.join
        case .login: return APIURL.login
        case .loginWithApple: return APIURL.loginWithApple
        case .loginWithKakao: return APIURL.loginWithKakao
        case .workspaces, .createWorkspace, .workspace: return APIURL.workspaces
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .emailValidation(_), .join, .login, .loginWithApple, .loginWithKakao, .createWorkspace:
            return .post
            
        case .refresh, .fetchImage, .workspaces, .workspace:
            return .get
        }
    }
    
    var header: [String: String] {
        switch self {
        case .refresh(let refreshToken):
            return [
                "Content-Type": "application/json",
                "Authorization": KeychainManager.shared.getItem(forKey: .accessToken) ?? "",
                "RefreshToken": refreshToken,
                "SesacKey": APIKey.apiKey
            ]
            
        case .emailValidation, .join, .login, .loginWithApple, .loginWithKakao:
            return [
                "Content-Type": "application/json",
                "SesacKey": APIKey.apiKey
            ]
            
        case .workspaces, .workspace:
            return [
                "Content-Type": "application/json",
                "Authorization": KeychainManager.shared.getItem(forKey: .accessToken) ?? "",
                "SesacKey": APIKey.apiKey
            ]
            
        case .createWorkspace:
            return [
                "Content-Type": "multipart/form-data",
                "Authorization": KeychainManager.shared.getItem(forKey: .accessToken) ?? "",
                "SesacKey": APIKey.apiKey
            ]
            
        case .fetchImage:
            return [
                "Authorization": KeychainManager.shared.getItem(forKey: .accessToken) ?? "",
                "SesacKey": APIKey.apiKey
            ]
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
            
        case .login(let email, let password, let deviceToken):
            return try? JSONEncoder().encode([
                BodyKey.email: email,
                BodyKey.password: password,
                BodyKey.deviceToken: deviceToken
            ])
            
        case .loginWithApple(let idToken, let nickname, let deviceToken):
            return try? JSONEncoder().encode([
                BodyKey.idToken: idToken,
                BodyKey.nickname: nickname,
                BodyKey.deviceToken: deviceToken
            ])
            
        case .loginWithKakao(let oauthToken, let deviceToken):
            return try? JSONEncoder().encode([
                BodyKey.oauthToken: oauthToken,
                BodyKey.deviceToken: deviceToken
            ])
            
        default: return nil
        }
    }
    
    var multipartFormData: MultipartFormData? {
        switch self {
        case .createWorkspace(let name, let description, let imageData):
            let multipartFormData = MultipartFormData()
            multipartFormData.append(Data(name.utf8), withName: "name")
            multipartFormData.append(Data(description.utf8), withName: "description")
            multipartFormData.append(imageData, withName: "image", fileName: UUID().uuidString, mimeType: "image/jpeg")
            return multipartFormData
            
        default: return nil
        }
    }
    
    var query: [URLQueryItem]? {
        switch self {
        case .refresh(let refreshToken):
            return [
                URLQueryItem(name: "RefreshToken", value: refreshToken)
            ]
            
        case .workspace(let id):
            return [
                URLQueryItem(name: "workspaceID", value: id)
            ]
            
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
