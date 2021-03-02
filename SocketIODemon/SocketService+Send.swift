//
//  SocketManager.swift
//  SocketIODemon
//
//  Created by lzwk_lanlin on 2021/2/22.
//

import Foundation

// MARK: - 发送消息

public extension SocketService {
    /// 发送加入房间的消息
    /// - Parameters:
    ///   - roomId: 房间id
    ///   - lectureId: 课程id
    ///   - userId: 用户id
    func sendJoinChatRoomMessage(roomId: String?, lectureId: Int?, userId: Int?) {
        var params: [String: Any] = [
            "systemType": "ios",
            "clientType": "app",
            "clientVersion": "1.1.1",
        ]
        if let userId = userId { params["accountId"] = userId }
        if let lectureId = lectureId { params["lectureId"] = lectureId }
        if let roomId = roomId { params["chatRoomId"] = roomId }

        send(event: Event.join.rawValue, params: params)
    }
    

}

// MARK: - 发送消息 - 直播课相关

public extension SocketService {
    /// 发送进入直播课的消息
    /// - Parameters:
    ///   - roomId: 房间id
    ///   - userId: 用户id
    ///   - nickname: 用户昵称
    ///   - avatarUrl: 用户头像链接
    func sendEnterLiveClassMessage(roomId: String?, userId: Int?, nickname: String?, avatarUrl: String?,content:String? = "") {
        var params: [String: Any] = [
            "id": UUID().uuidString,
            "type": "PROMOTION_NOTICE_MESSAGE",
            "action": "visitor",
            "body": ["content": content],
        ]
        if let roomId = roomId {
            params["chatRoomId"] = roomId
        }
        if let userId = userId, let nickname = nickname, let avatar = avatarUrl {
            params["user"] = [
                "id": userId,
                "nickname": nickname,
                "avatar_url": avatar,
            ]
        }
        send(event: Event.chat.rawValue, params: params)
    }
    
    
    
}
