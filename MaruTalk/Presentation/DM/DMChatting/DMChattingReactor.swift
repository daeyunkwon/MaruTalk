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
        case viewDisappear
        
    }
    
    enum Mutation {
        case setChatList([RealmDMChat])
        case setNavigationTitle(String)
        case setNetworkError((Router.APIType, String?))
        case setScrollToBottom
    }
    
    struct State {
        var roomID: String
        var otherUserID: String //상대방 유저ID
        @Pulse var chatList: [RealmDMChat]?
        @Pulse var navigationTitle: String?
        @Pulse var networkError: (Router.APIType, String?)?
        @Pulse var shouldScrollToBottom: Void?
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
                fetchOtherUser(),
                fetchDMChatListFromRealmDB(), //DB에서 채팅 내역 가져오기
                connectDMSocket()
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
        
        case .viewDisappear:
            return disconnectSocket()
        }
    }
}

//MARK: - Reduce

extension DMChattingReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setChatList(let value):
            //현재 데이터가 있다면 끝에 추가
            if newState.chatList == nil {
                newState.chatList = value
            } else {
                newState.chatList?.append(contentsOf: value)
            }
        
        case .setNavigationTitle(let value):
            newState.navigationTitle = value
        
        case .setNetworkError(let value):
            newState.networkError = value
        
        case .setScrollToBottom:
            newState.shouldScrollToBottom = ()
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
    
    private func fetchDMChatListFromRealmDB() -> Observable<Mutation> {
        let roomID = currentState.roomID
        let result = RealmDMChatRepository.shared.fetchChatList(roomID: roomID)
        
        if result.isEmpty {
            return fetchChats(cursorDate: nil)
        } else {
            return .concat([
                .just(.setChatList(result)),
                fetchChats(cursorDate: Date.formatToISO8601String(date: result.last?.createdAt ?? Date())),
                .just(.setScrollToBottom)
            ])
        }
    }
    
    //채팅 내역 조회
    ///해당 api를 호출하면 자동으로 해당 채널의 멤버가 된다.
    private func fetchChats(cursorDate: String?) -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        let roomID = currentState.roomID
        print("실행 전 커서----------------")
        print(cursorDate ?? "없음")
        //cursorDate -> 채팅 내용 중 가장 마지막 날짜에 해당하는 값, 이 값이 없을 경우 모든 채팅 내용을 불러옴
        //cursorDate를 기준으로 새로운 체팅 내용들을 서버로부터 가져오고, DB에 저장해둔다.
        return NetworkManager.shared.performRequest(api: .dmChats(workspaceID: workspaceID, roomID: roomID, cursorDate: cursorDate), model: [Chat].self)
            .asObservable()
            .flatMap { [weak self] result -> Observable<Mutation> in
                guard let self else { return .empty() }
                switch result {
                case .success(let value):
                    print("룸 아이디: \(String(describing: self.currentState.roomID))")
                    
                    if !value.isEmpty {
                        //새로운 채팅 내역들을 DB에 저장 및 테이블뷰에 전달 수행
                        var chatList: [RealmDMChat] = []
                        for chat in value {
                            RealmDMChatRepository.shared.saveChat(chat: RealmDMChat(chat: chat))
                            chatList.append(RealmDMChat(chat: chat))
                        }
                        //과거순 정렬
                        chatList.sort {
                            $0.createdAt < $1.createdAt
                        }
                        return .concat([
                            .just(.setChatList(chatList)),
                            .just(.setScrollToBottom)
                        ])
                    } else {
                        return .empty()
                    }
                    
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.chats, error.errorCode)))
                }
            }
    }
}
