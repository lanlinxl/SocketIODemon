//
//  SocketManager.swift
//  SocketIODemon
//
//  Created by lzwk_lanlin on 2021/2/22.
//

import Foundation
import SocketIO
import SwiftyJSON

public class SocketService {
    /// 事件id (与服务器协商定义)
    public enum Event: String {
        /// 加入房间
        case join
        /// 房间内聊天
        case chat
    }

    /// Socket状态
    public enum State {
        /// 已连接
        case connected
        /// 正在重连
        case reconnect
        /// 已断开连接
        case disconnected
        /// 连接错误
        case error
    }

    /// 连接状态
    public var state: State = .disconnected
    
    /// Socket状态变化回调
    private var stateChanged: ((_ state: State) -> Void)?

    ///socket对象
    private lazy var manager: SocketManager = {
        let testString = "http://dev.push.goweike.cn"
        var socketURL = URL(string:testString)!
        let manager = SocketManager(socketURL: socketURL, config: [.version(.two), .compress, .forceWebsockets(true),.log(true)])
        return manager
    }()

    private lazy var socketClient = manager.defaultSocket

    public init() {
    }

    deinit {
        disconnect()
    }
}

// MARK: - Public
public extension SocketService {
    /// 开始连接Socket
    func connect() {
        addSocketHandlers()
        socketClient.connect()
        
    }

    /// 断开连接Socket
    func disconnect() {
        socketClient.disconnect()
        socketClient.removeAllHandlers()
    }

    /// Socket状态变化回调
    func onStateChanged(_ callback: ((_ state: State) -> Void)?) {
        stateChanged = callback
    }

    /// 接收指定事件Socket消息
    /// - Parameters:
    ///   - event: 事件名称
    func receive(event: String?, callback: ((_ json: JSON) -> Void)?) {
        guard let event = event else {
            print("传入事件名称为空")
            return
        }
        socketClient.on(event) { datas, _ in
            guard let data = datas.first else {
                print("Socket: 事件[\(event)] 接收的数据为空")
                return
            }
            let json = JSON(data)
            print("接收到Socket消息：event = \(event), data = \(json)")
            callback?(json)
        }
    }

    /// 发送指定事件的Socket消息
    /// - Parameters:
    ///   - event: 事件id
    ///   - parameters: 参数
    func send(event: String?, params: [String: Any]?, completion: (() -> Void)? = nil) {
        guard let event = event, let parameters = params else {
            print("传入事件名称或参数为空")
            return
        }

        socketClient.emit(event, parameters) {
            print("发送Socket消息：event = \(event), parames = \(parameters)")
            completion?()
        }
    }
}

// MARK: - Private

public extension SocketService {
    /// 添加时间处理
    private func addSocketHandlers() {
        socketClient.on(clientEvent: .connect) { [weak self] data, _ in
            guard let _ = data.first as? String else { return }
            print("================== Socket连接成功 ==================")
            self?.state = .connected
            self?.stateChanged?(.connected)
        }

        socketClient.on(clientEvent: .reconnect) { [weak self] _, _ in
            print(".................. Socket正在重连 ....................")
            self?.state = .reconnect
            self?.stateChanged?(.reconnect)
        }

        socketClient.on(clientEvent: .disconnect) { [weak self] _, _ in
            print("xxxxxxxxxxxxxxxxxx Socket已断开连接 xxxxxxxxxxxxxxxxxx")
            self?.state = .disconnected
            self?.stateChanged?(.disconnected)
        }

        socketClient.on(clientEvent: .error) { [weak self] _, _ in
            print("xxxxxxxxxxxxxxxxxx Socket连接失败 xxxxxxxxxxxxxxxxxxxx")
            self?.state = .error
            self?.stateChanged?(.error)
        }
    }
}
