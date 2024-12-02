//
//  DMListReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/30/24.
//

import Foundation

import ReactorKit

final class DMListReactor: Reactor {
    enum Action {
        case fetch
        case selectMember(User)
        case selectChat(Chat)
    }
    
    enum Mutation {
        case setNetworkError((Router.APIType, String?))
        case setMemberList([User])
        case setUser(User)
        case setDMRoomList([Chat])
        case setNavigateToDMChatting(DMRoom)
    }
    
    struct State {
        @Pulse var networkError: (Router.APIType, String?)?
        @Pulse var memberList: [User]?
        @Pulse var user: User?
        @Pulse var dmRoomList: [Chat]?
        @Pulse var shouldNavigateToDMChatting: DMRoom?
    }
    
    var initialState: State = State()
}

//MARK: - Mutate

extension DMListReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return .concat([
                fetchMemberList(),
                fetchProfile(),
                fetchDMS()
            ])
        
        case .selectMember(let value):
            return createDMRoom(opponentID: value.userID)
        
        case .selectChat(let value):
            return createDMRoom(opponentID: value.user.userID)
        }
    }
}

//MARK: - Reduce

extension DMListReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNetworkError(let value):
            newState.networkError = value
            
        case .setMemberList(let value):
            newState.memberList = value
        
        case .setUser(let value):
            newState.user = value
        
        case .setDMRoomList(let value):
            newState.dmRoomList = value
        
        case .setNavigateToDMChatting(let value):
            newState.shouldNavigateToDMChatting = value
        }
        return newState
    }
}

//MARK: - Logic

extension DMListReactor {
    //멤버 리스트 조회
    private func fetchMemberList() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        
        return NetworkManager.shared.performRequest(api: .workspaceMembers(workspaceID: workspaceID), model: [User].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    let filteredList = value.filter { $0.userID != UserDefaultsManager.shared.userID ?? ""}
                    return .just(.setMemberList(filteredList))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.workspaceMembers, error.errorCode)))
                }
            }
    }
    
    //내 프로필 조회
    private func fetchProfile() -> Observable<Mutation> {
        return NetworkManager.shared.performRequest(api: .userMe, model: User.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    return .just(.setUser(value))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.userMe, error.errorCode)))
                }
            }
    }
    
    //DM 방 리스트 조회
    private func fetchDMS() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        return NetworkManager.shared.performRequest(api: .dms(workspaceID: workspaceID), model: [DMRoom].self)
            .asObservable()
            .flatMap { [weak self] result -> Observable<Mutation> in
                guard let self else { return .empty() }
                switch result {
                case .success(let value):
                    let roomIDs = value.map { $0.roomID }
                    
                    //상대방 유저 정보
                    let otherUser = Dictionary(uniqueKeysWithValues: value.map { ($0.roomID, $0.user)})
                    
                    return self.fetchDMRoomChat(roomIDs: roomIDs, otherUser: otherUser)
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.userMe, error.errorCode)))
                }
            }
    }
    
    //DM 방 채팅 내용 조회
    private func fetchDMRoomChat(roomIDs: [String], otherUser: [String: User]) -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        
        let requests = roomIDs.map { roomID -> Observable<Chat?> in
//            var cursorDate: String?
//            if let chat = RealmDMChatRepository.shared.fetchLastChat(roomID: roomID) {
//                cursorDate = Date.formatToISO8601String(date: chat.createdAt)
//            }
            
            return NetworkManager.shared
                .performRequest(api: .dmChats(workspaceID: workspaceID, roomID: roomID, cursorDate: nil), model: [Chat].self)
                .asObservable()
                .flatMap { result -> Observable<Chat?> in
                    switch result {
                    case .success(let chats):
                        
                        var sorted = chats.sorted { $0.createdAt > $1.createdAt }
                        
                        if sorted.count > 1 {
                            if let otherUser = otherUser[roomID] {
                                sorted[0].user = otherUser //마지막 채팅 유저 정보를 본인이 아닌 상대방 유저 정보로 변경하기(테이블셀에서 상대방 유저 정보로 표현하기 위함)
                            }
                        }
                        
                        var after: String? //마지막 채팅 날짜
                        //DB에서 마지막 채팅 날짜 가져오기
                        if let lastChatDate = RealmDMChatRepository.shared.fetchLastChat(roomID: roomID)?.createdAt {
                            after = Date.formatToISO8601String(date: lastChatDate)
                        } else {
                            //신규 메시지의 경우 DB에 아직 저장된 내용이 없기 때문에 임의 날짜로 지정: (서버에서 공백을 포함하여 빈 값으로 보낼 시 응답값의 count가 0으로 리턴됩니다.)
                            var tempDate = Date(timeIntervalSince1970: TimeInterval())
                            after = Date.formatToISO8601String(date: tempDate)
                        }
                        
                        return NetworkManager.shared.performRequest(api: .dmUnreadCount(workspaceID: workspaceID, roomID: roomID, after: after), model: Unread.self)
                            .asObservable()
                            .map { result -> Chat? in
                                switch result {
                                case .success(let value):
                                    //읽지 않은 채팅 개수 업데이트
                                    if sorted.count > 1 {
                                        sorted[0].unreadCount = value.count
                                    }
                                    print("count: \(value.count)")
                                    return sorted.first
                                case .failure(let error):
                                    print("ERROR: \(error)")
                                    return sorted.first
                                }
                            }
                        
                    case .failure(let error):
                        print("ERROR: \(error)")
                        return .just(nil)
                    }
                }
            }
        
        return Observable.zip(requests)
                .map { allChats -> Mutation in
                    let combinedChats = allChats.compactMap { $0 }
                    print("DEBUG: Fetched all DM room chats: \(combinedChats)")
                    return .setDMRoomList(combinedChats)
                }
    }
    
    //DM방 생성 또는 조회
    private func createDMRoom(opponentID: String) -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        
        return NetworkManager.shared.performRequest(api: .createDM(workspaceID: workspaceID, opponentID: opponentID), model: DMRoom.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    return .just(.setNavigateToDMChatting(value))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.createDM, error.errorCode)))
                }
            }
    }
}
