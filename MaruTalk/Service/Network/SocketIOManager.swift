//
//  SocketIOManager.swift
//  MaruTalk
//
//  Created by 권대윤 on 11/26/24.
//

import Foundation

import SocketIO
import RxRelay

final class SocketIOManager {
    
    static let shared = SocketIOManager()
    private init() { }
    
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    
    let dataRelay = PublishRelay<[Chat]>()
    
    func connect(channelID: String?) {
        guard let channelID = channelID else {
            print("ERROR: 채널 아이디 없음 - \(#function)")
            return
        }
        guard let url = URL(string: APIURL.baseURL + "ws-channel-\(channelID)") else {
            print("ERROR: URL 생성 실패 - \(#function)")
            return
        }
        manager = SocketManager(socketURL: url, config: [.log(true), .forceWebsockets(true)])
        socket = manager?.socket(forNamespace: "/ws-channel-\(channelID)")
        
        //소켓 연결
        socket?.on(clientEvent: .connect) { data, ack in
            print("DEBUG: 소켓 연결됨", data, ack)
        }
        
        //이벤트 수신
        socket?.on("channel") { [weak self] dataArray, ack in
            guard let self else { return }
            print("DEBUG: 데이터 수신됨 CHANNEL RECEIVED!!", dataArray, ack)
            
            self.decodeSocketData(dataArray) { chatList in
                self.dataRelay.accept(chatList)
            }
        }
        
        //소켓 해제
        socket?.on(clientEvent: .disconnect) { data, ack in
            print("DEBUG: 소켓 연결 해제 됨", data, ack)
        }
        
        socket?.connect() //소켓 연결
    }
    
    func disconnect() {
        socket?.disconnect() //소켓 연결 해제
        socket?.didDisconnect(reason: "소켓 연결 해제됨")
    }
}

extension SocketIOManager {
    func decodeSocketData(_ data: [Any], completion: @escaping ([Chat]) -> Void) {
        do {
            // JSONSerialization을 이용해 JSON 데이터를 Data로 변환
            let jsonData = try JSONSerialization.data(withJSONObject: data)

            let chatList = try JSONDecoder().decode([Chat].self, from: jsonData)
            
            completion(chatList)
            
            print("DEBUG: 디코딩 성공 - \(chatList)")
        } catch {
            print("ERROR: 디코딩 실패 - \(error)")
        }
    }
}
