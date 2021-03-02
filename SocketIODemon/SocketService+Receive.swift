//
//  SocketManager.swift
//  SocketIODemon
//
//  Created by lzwk_lanlin on 2021/2/22.
//

import Foundation
import SwiftyJSON
// MARK: - 接收消息

public extension SocketService {
    /// 房间内部聊天类型
    enum ChatType: String {
        /// 讲师、管理员的消息
        case message
        /// 学员讨论的消息
        case discuss
        /// 系统消息
        case system = "system_message"
        /// 直播课、小班课相关的消息
        case promotion = "PROMOTION_NOTICE_MESSAGE"
    }

    /// 接收房间内聊天消息
    func receiveChat(callback: ((_ type: ChatType, _ json: JSON) -> Void)?) {
        receive(event: Event.chat.rawValue) { json in
            guard let type = ChatType(rawValue: json["type"].stringValue) else { return }
            callback?(type, json)
        }
    }
}
