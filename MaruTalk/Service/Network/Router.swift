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
    //Auth
    case emailValidation(String)
    case join(email: String, password: String, nickname: String, phone: String, deviceToken: String)
    case login(email: String, password: String, deviceToken: String)
    case loginWithApple(idToken: String, nickname: String, deviceToken: String)
    case loginWithKakao(oauthToken: String, deviceToken: String)
    //Workspace
    case workspaces //사용자가 속한 워크스페이스 리스트
    case createWorkspace(name: String, description: String, imageData: Data)
    case workspace(id: String) //특정 워크스페이스
    case workspaceMemberInvite(workspaceID: String, email: String)
    case workspaceMembers(workspaceID: String)
    case workspaceEdit(workspaceID: String, name: String, description: String?, imageData: Data?) //워크스페이스 편집
    case workspaceExit(workspaceID: String) //워크스페이스 나가기
    //User
    case userMe //내 프로필 정보 조회
    case user(userID: String) //다른 유저 정보 조회
    case userMeImage(imageData: Data) //프로필 이미지 수정
    //Channel
    case channels(workspaceID: String) //워크 스페이스에 속하는 모든 채널들
    case myChannels(workspaceID: String) //워크 스페이스에 속하는 사용자가 속한 채널들
    case channel(workspaceID: String, channelID: String)
    case createChannel(workspaceID: String, name: String, description: String?, imageData: Data?)
    case chats(workspaceID: String, channelID: String, cursorDate: String?)
    case sendChannelChat(workspaceID: String, channelID: String, content: String, files: [Data])
    case channelEdit(workspaceID: String, channelID: String, name: String, description: String?)
    case channelMembers(workspaceID: String, channelID: String)
    case channelChangeAdmin(workspaceID: String, channelID: String, memberID: String)
    case channelExit(workspaceID: String, channelID: String)
    case channelDelete(workspaceID: String, channelID: String)
    //DMS
    case dms(workspaceID: String)
    case dmChats(workspaceID: String, roomID: String, cursorDate: String?)
    case createDM(workspaceID: String, opponentID: String) //DM방 생성 또는 조회 수행
    case sendDMChat(workspaceID: String, roomID: String, content: String, files: [Data])
    case dmUnreadCount(workspaceID: String, roomID: String, after: String?)
    
    enum APIType {
        case empty //초기화용 빈 값
        case refresh
        //Auth
        case emailValidation
        case join
        case login
        case loginWithApple
        case loginWithKakao
        //Workspace
        case workspaces
        case createWorkspace
        case workspace
        case workspaceMemberInvite
        case workspaceMembers
        case workspaceEdit
        case workspaceExit
        //User
        case userMe
        case user
        case userMeImage
        //Channel
        case channels
        case myChannels
        case channel
        case createChannel
        case chats
        case sendChannelChat
        case channelEdit
        case channelMembers
        case channelChangeAdmin
        case channelExit
        case channelDelete
        //DMS
        case dms
        case dmChats
        case createDM
        case sendDMChat
        case dmUnreadCount
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
        case .userMe: return APIURL.userMe
        case .user(let userID): return APIURL.user(userID: userID)
        case .userMeImage: return APIURL.userMeImage
            
        case .workspaces, .createWorkspace, .workspace: return APIURL.workspaces
        case .workspaceMemberInvite(let workspaceID, _): return APIURL.workspaceMemberInvite(workspaceID: workspaceID)
        case .workspaceMembers(let workspaceID): return APIURL.workspaceMembers(workspaceID: workspaceID)
        case .workspaceEdit(let workspaceID, _, _, _): return APIURL.workspaceEdit(workspaceID: workspaceID)
        case .workspaceExit(let workspaceID): return APIURL.workspaceExit(workspaceID: workspaceID)
            
        case .channels(let workspaceID): return APIURL.channels(workspaceID: workspaceID)
        case .myChannels(let workspaceID): return APIURL.myChannels(workspaceID: workspaceID)
        case .channel(let workspaceID, let channelID): return APIURL.channel(workspaceID: workspaceID, channelID: channelID)
        case .createChannel(let workspaceID, _, _, _): return APIURL.createChannel(workspaceID: workspaceID)
        case .chats(let workspaceID, let channelID, _): return APIURL.chats(workspaceID: workspaceID, channelID: channelID)
        case .sendChannelChat(let workspaceID, let channelID, _, _): return APIURL.sendChannelChat(workspaceID: workspaceID, channelID: channelID)
        case .channelEdit(let workspaceID, let channelID, _, _): return APIURL.channel(workspaceID: workspaceID, channelID: channelID)
        case .channelMembers(let workspaceID, let channelID): return APIURL.channelMembers(workspaceID: workspaceID, channelID: channelID)
        case .channelChangeAdmin(let workspaceID, let channelID, _): return APIURL.channelChangeAdmin(workspaceID: workspaceID, channelID: channelID)
        case .channelExit(let workspaceID, let channelID): return APIURL.channelExit(workspaceID: workspaceID, channelID: channelID)
        case .channelDelete(let workspaceID, let channelID): return APIURL.channel(workspaceID: workspaceID, channelID: channelID)
            
        case .dms(let workspaceID): return APIURL.dms(workspaceID: workspaceID)
        case .dmChats(let workspaceID, let roomID, _): return APIURL.dmChats(workspaceID: workspaceID, roomID: roomID)
        case .createDM(let workspaceID, _): return APIURL.dms(workspaceID: workspaceID)
        case .sendDMChat(let workspaceID, let roomID, _, _): return APIURL.dmChats(workspaceID: workspaceID, roomID: roomID)
        case .dmUnreadCount(let workspaceID, let roomID, _): return APIURL.dmUnreadCount(workspaceID: workspaceID, roomID: roomID)
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .refresh, .fetchImage, .workspaces, .workspace, .workspaceMembers, .workspaceExit, .userMe, .user, .myChannels, .dms, .chats, .channel, .channels, .channelMembers, .channelExit, .dmChats, .dmUnreadCount:
            return .get
            
        case .emailValidation(_), .join, .login, .loginWithApple, .loginWithKakao, .createWorkspace, .createChannel, .sendChannelChat, .workspaceMemberInvite, .createDM, .sendDMChat:
            return .post
            
        case .workspaceEdit, .channelEdit, .channelChangeAdmin, .userMeImage:
            return .put
            
        case .channelDelete:
            return .delete
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
            
        case .workspaces, .workspace, .workspaceMembers, .workspaceExit, .userMe, .user, .myChannels, .dms, .chats, .channel, .workspaceMemberInvite, .channels, .channelMembers, .channelChangeAdmin, .channelExit, .channelDelete, .dmChats, .createDM, .dmUnreadCount:
            return [
                "Content-Type": "application/json",
                "Authorization": KeychainManager.shared.getItem(forKey: .accessToken) ?? "",
                "SesacKey": APIKey.apiKey
            ]
            
        case .createWorkspace, .createChannel, .sendChannelChat, .channelEdit, .sendDMChat, .userMeImage, .workspaceEdit:
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
            
        case .workspaceMemberInvite(_, let email):
            return try? JSONEncoder().encode([
                BodyKey.email: email
            ])
            
        case .channelChangeAdmin(_, _, let memberID):
            return try? JSONEncoder().encode([
                BodyKey.owner_id: memberID
            ])
            
        case .createDM(_, let opponentID):
            return try? JSONEncoder().encode([
                BodyKey.opponent_id: opponentID
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
            
        case .workspaceEdit(_, let name, let description, let imageData):
            let multipartFormData = MultipartFormData()
            multipartFormData.append(Data(name.utf8), withName: "name")
            if let description = description {
                multipartFormData.append(Data(description.utf8), withName: "description")
            }
            if let imageData = imageData {
                multipartFormData.append(imageData, withName: "image", fileName: UUID().uuidString, mimeType: "image/jpeg")
            }
            return multipartFormData
            
        case .userMeImage(let imageData):
            let multipartFormData = MultipartFormData()
            multipartFormData.append(imageData, withName: "image", fileName: UUID().uuidString, mimeType: "image/jpeg")
            return multipartFormData
            
        case .createChannel(_, let name, let description, let imageData):
            let multipartFormData = MultipartFormData()
            multipartFormData.append(Data(name.utf8), withName: "name")
            if let description = description {
                multipartFormData.append(Data(description.utf8), withName: "description")
            }
            if let imageData = imageData {
                multipartFormData.append(imageData, withName: "image", fileName: UUID().uuidString, mimeType: "image/jpeg")
            }
            return multipartFormData
            
        case .sendChannelChat(_, _, let content, let files):
            let multipartFormData = MultipartFormData()
            multipartFormData.append(Data(content.utf8), withName: "content")
            for item in files {
                multipartFormData.append(item, withName: "files", fileName: UUID().uuidString, mimeType: "image/jpeg")
            }
            return multipartFormData
            
        case .channelEdit(_, _, let name, let description):
            let multipartFormData = MultipartFormData()
            multipartFormData.append(Data(name.utf8), withName: "name")
            if let description = description {
                multipartFormData.append(Data(description.utf8), withName: "description")
            }
            return multipartFormData
            
        case .sendDMChat(_, _, let content, let files):
            let multipartFormData = MultipartFormData()
            multipartFormData.append(Data(content.utf8), withName: "content")
            for item in files {
                multipartFormData.append(item, withName: "files", fileName: UUID().uuidString, mimeType: "image/jpeg")
            }
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
            
        case .chats(_, _, let cursorDate):
            return [
                URLQueryItem(name: "cursor_date", value: cursorDate)
            ]
            
        case .dmChats(_, _, let cursorDate):
            return [
                URLQueryItem(name: "cursor_date", value: cursorDate)
            ]
            
        case .dmUnreadCount(_, _, let after):
            return [
                URLQueryItem(name: "after", value: after)
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
