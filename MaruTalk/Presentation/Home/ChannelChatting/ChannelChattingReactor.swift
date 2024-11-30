//
//  ChannelChattingReactor.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/24/24.
//

import Foundation

import ReactorKit

final class ChannelChattingReactor: Reactor {
    enum Action {
        case fetch
        case viewDisappear
        case inputContent((String, Bool))
        case sendButtonTapped
        case newMessageReceived([Chat])
        case messagePlusButtonTapped
        case selectPhotoImage([Data])
        case deselectPhotoImage(Int)
        case settingButtonTapped
    }
    
    enum Mutation {
        case setNavigationTitle(String)
        case setNetworkError((Router.APIType, String?))
        case setChatList([RealmChannelChat])
        case setContent(String)
        case setMessageSendSuccess(Void)
        case setScrollToBottom(Void)
        case setShowPhotoAlbum(Void)
        case setPhotoImageDatas([Data])
        case setNavigateToSetting(String)
    }
    
    struct State {
        var channelID: String? //채널
        
        @Pulse var navigationTitle: String?
        @Pulse var networkError: (Router.APIType, String?)?
        
        @Pulse var chatList: [RealmChannelChat]?
        
        var content: String = ""
        
        @Pulse var messageSendSuccess: Void?
        @Pulse var shouldScrollToBottom: Void?
        @Pulse var shouldShowPhotoAlbum: Void?
        
        @Pulse var photoImageDatas: [Data] = []
        
        @Pulse var shouldNavigateToSetting: String?
    }
    
    let initialState: State
    
    private let disposeBag = DisposeBag()
    
    init(channelID: String) {
        initialState = State(channelID: channelID)
        
        SocketIOManager.shared.dataRelay
            .subscribe(onNext: { [weak self] dataArray in
                self?.action.onNext(.newMessageReceived(dataArray))
            })
            .disposed(by: disposeBag)
    }
}

//MARK: - Mutate

extension ChannelChattingReactor {
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetch:
            return .concat([
                fetchChatsFromRealm(), //저장된 채팅 내역 가져오기
                fetchChannel(), //채널 정보
                connectChannelSocket() //소켓 연결
            ])
            
        case .viewDisappear:
            return disconnectSocket()
        
        case .inputContent(let value):
            let content = value.0
            let isPlaceholderText = value.1
            
            //공백 체크
            if !content.trimmingCharacters(in: .whitespaces).isEmpty, !isPlaceholderText {
                return .just(.setContent(content))
            } else {
                return .just(.setContent(""))
            }
            
        case .sendButtonTapped:
            return sendChannelChat()
        
        case .newMessageReceived(let values):
            //소켓 통신으로 수신 메시지 DB에 저장하기
            var chatList: [RealmChannelChat] = []
            for chat in values {
                
                if chat.user.userID == UserDefaultsManager.shared.userID { //사용자가 방금 보낸 채팅의 경우 DB 저장 생략하기
                    continue
                }
                
                let realmChat = RealmChannelChat(chat: chat)
                RealmChannelChatRepository.shared.saveChat(chat: realmChat)
                chatList.append(realmChat)
            }
            
            if !chatList.isEmpty {
                return .just(.setChatList(chatList)) //테이블뷰 갱신
            } else {
                return .empty()
            }
        
        case .messagePlusButtonTapped:
            return .just(.setShowPhotoAlbum(()))
        
        case .selectPhotoImage(let imageDataList):
            return .just(.setPhotoImageDatas(imageDataList))
        
        case .deselectPhotoImage(let value):
            var list = currentState.photoImageDatas
            list.remove(at: value)
            return .just(.setPhotoImageDatas(list))
        
        case .settingButtonTapped:
            guard let channelID = currentState.channelID else { return .empty() }
            return .just(.setNavigateToSetting(channelID))
        }
    }
}

//MARK: - Reduce

extension ChannelChattingReactor {
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setNavigationTitle(let value):
            newState.navigationTitle = value
        
        case .setNetworkError(let value):
            newState.networkError = value
            
        case .setChatList(let value):
            //현재 데이터가 있다면 추가
            if newState.chatList == nil {
                newState.chatList = value
            } else {
                newState.chatList?.append(contentsOf: value)
            }
        
        case .setContent(let value):
            newState.content = value
        
        case .setMessageSendSuccess(let value):
            newState.messageSendSuccess = value
        
        case .setScrollToBottom(let value):
            newState.shouldScrollToBottom = value
        
        case .setShowPhotoAlbum(let value):
            newState.shouldShowPhotoAlbum = value
        
        case .setPhotoImageDatas(let value):
            newState.photoImageDatas = value
        
        case .setNavigateToSetting(let value):
            newState.shouldNavigateToSetting = value
        }
        return newState
    }
}

//MARK: - Logic

extension ChannelChattingReactor {
    private func fetchChannel() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        guard let channelID = currentState.channelID else { return .empty() }
        return NetworkManager.shared.performRequest(api: .channel(workspaceID: workspaceID, channelID: channelID), model: Channel.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    let memberCount = value.channelMembers?.count ?? 0
                    let channelName = value.name
                    let title = channelName + " \(memberCount)"
                    return .just(.setNavigationTitle(title))
                    
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.channel, error.errorCode)))
                }
            }
    }
    
    private func fetchChatsFromRealm() -> Observable<Mutation> {
        guard let channelID = currentState.channelID else { return .empty() }
        let result = RealmChannelChatRepository.shared.fetchChatList(channelID: channelID)
        
        if result.isEmpty {
            print("DEBUG: 데이터 없음 \(#function)")
            return .concat([
                fetchChats(cursorDate: nil)
            ])
        } else {
            
            return .concat([
                .just(.setChatList(result)),
                fetchChats(cursorDate: Date.formatToISO8601String(date: result.last?.createdAt ?? Date())),
                .just(.setScrollToBottom(()))
            ])
        }
    }
    
    //채널 채팅 내역 조회
    ///해당 api를 호출하면 자동으로 해당 채널의 멤버가 된다.
    private func fetchChats(cursorDate: String?) -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        guard let channelID = currentState.channelID else { return .empty() }
        print("실행 전 커서----------------")
        print(cursorDate ?? "없음")
        //cursorDate -> 채팅 내용 중 가장 마지막 날짜에 해당하는 값, 이 값이 없을 경우 모든 채팅 내용을 불러옴
        //cursorDate를 기준으로 새로운 체팅 내용들을 서버로부터 가져오고, DB에 저장해둔다.
        return NetworkManager.shared.performRequest(api: .chats(workspaceID: workspaceID, channelID: channelID, cursorDate: cursorDate), model: [Chat].self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    print("실행결과")
                    print(value)
                    print("채널아이디: \(String(describing: self.currentState.channelID))")
                    
                    if !value.isEmpty {
                        //새로운 채팅 내역들을 DB에 저장 및 테이블뷰에 전달 수행
                        var chatList: [RealmChannelChat] = []
                        for chat in value {
                            RealmChannelChatRepository.shared.saveChat(chat: RealmChannelChat(chat: chat))
                            chatList.append(RealmChannelChat(chat: chat))
                        }
                        //과거순 정렬
                        chatList.sort {
                            $0.createdAt < $1.createdAt
                        }
                        return .concat([
                            .just(.setChatList(chatList)),
                            .just(.setScrollToBottom(()))
                        ])
                    } else {
                        return .empty()
                    }
                    
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.chats, error.errorCode)))
                }
            }
    }
    
    private func connectChannelSocket() -> Observable<Mutation> {
        SocketIOManager.shared.connect(channelID: self.currentState.channelID)
        return .empty()
    }
    
    private func disconnectSocket() -> Observable<Mutation> {
        SocketIOManager.shared.disconnect()
        return .empty()
    }
    
    private func sendChannelChat() -> Observable<Mutation> {
        guard let workspaceID = UserDefaultsManager.shared.recentWorkspaceID else { return .empty() }
        guard let channelID = currentState.channelID else { return .empty() }
        let content = currentState.content
        let files: [Data] = currentState.photoImageDatas
        
        return NetworkManager.shared.performRequestMultipartFormData(api: .sendChannelChat(workspaceID: workspaceID, channelID: channelID, content: content, files: files), model: Chat.self)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                switch result {
                case .success(let value):
                    //보낸 메시지 DB에 저장
                    RealmChannelChatRepository.shared.saveChat(chat: RealmChannelChat(chat: value))
                    return .concat([
                        .just(.setMessageSendSuccess(())),
                        .just(.setChatList([RealmChannelChat(chat: value)])),
                        .just(.setPhotoImageDatas([])),
                        .just(.setScrollToBottom(()))
                    ])
                    
                case .failure(let error):
                    return .just(.setNetworkError((Router.APIType.sendChannelChat, error.errorCode)))
                }
            }
    }
}

