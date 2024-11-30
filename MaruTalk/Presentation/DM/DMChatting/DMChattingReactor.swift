//
//  DMChattingReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/30/24.
//

import Foundation

import ReactorKit

final class DMChattingReactor: Reactor {
    enum Action {
        case fetch
        case newMessageReceived([Chat])
    }
    
    enum Mutation {
        case setChatList([RealmDMChat])
        case setNavigationTitle(String)
        case setNetworkError((Router.APIType, String?))
    }
    
    struct State {
        var roomID: String
        var otherUserID: String //상대방 유저ID
        @Pulse var chatList: [RealmDMChat]?
        @Pulse var navigationTitle: String?
        @Pulse var networkError: (Router.APIType, String?)?
    }
    
    var initialState: State
    
    private let disposeBag = DisposeBag()
    
    init(roomID: String, otherUserID: String) {
        self.initialState = State(roomID: roomID, otherUserID: otherUserID)
        
        SocketIOManager.shared.dataRelay
            .subscribe(onNext: { [weak self] dataArray in
                self?.action.onNext(.newMessageReceived(dataArray))
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Mutate

extension DMChattingReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return .concat([
                fetchOtherUser()
            ])
        
        case .newMessageReceived(let values):
            //소켓 통신으로 수신 메시지 DB에 저장하기
            var chatList: [RealmDMChat] = []
            for chat in values {
                
                if chat.user.userID == UserDefaultsManager.shared.userID ?? "" { //사용자가 방금 보낸 채팅의 경우 DB 저장 생략하기
                    continue
                }
                
                let realmChat = RealmDMChat(chat: chat)
                RealmDMChatRepository.shared.saveChat(chat: realmChat)
                chatList.append(realmChat)
            }
            
            if !chatList.isEmpty {
                return .just(.setChatList(chatList)) //테이블뷰 갱신
            } else {
                return .empty()
            }
        }
    }
}

//MARK: - Reduce

extension DMChattingReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setChatList(let value):
            //현재 데이터가 있다면 추가
            if newState.chatList == nil {
                newState.chatList = value
            } else {
                newState.chatList?.append(contentsOf: value)
            }
        
        case .setNavigationTitle(let value):
            newState.navigationTitle = value
        
        case .setNetworkError(let value):
            newState.networkError = value
        }
        return newState
    }
}


//MARK: - Logic

extension DMChattingReactor {
    private func connectDMSocket() -> Observable<Mutation> {
        SocketIOManager.shared.connect(roomID: self.currentState.roomID)
        return .empty()
    }
    
    private func disconnectSocket() -> Observable<Mutation> {
        SocketIOManager.shared.disconnect()
        return .empty()
    }
    
    private func fetchOtherUser() -> Observable<Mutation> {
        let otherUserID = currentState.otherUserID
        return NetworkManager.shared.performRequest(api: .user(userID: otherUserID), model: User.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    return .just(.setNavigationTitle(value.nickname))
                
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.user, error.errorCode)))
                }
            }
    }
}
