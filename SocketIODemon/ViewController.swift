//
//  ViewController.swift
//  SocketIODemon
//
//  Created by lzwk_lanlin on 2021/2/22.
//

import UIKit
class ViewController: UIViewController {
    
    var dataSource : [String] = []
    let testRoomId = "v1_1111257748"
    let testLectureId = 1111257748
    let testUserId = 107595324
    let nickName = "fsafeswf"
    let avatarUrl = "https://img.lycheer.net/avatar/3059488d81f7f3d8739a9ea6d909dd46.jpeg/avatar"
    
    /// socket
    lazy var socketIO = SocketService()
    
    @IBOutlet weak var textFiled: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    /// 设置Socket服务
    func setupSocketService() {
        // 监听Socket联接状态
        socketIO.onStateChanged {[weak self] state in
            switch state {
            case .connected:
                print("连接成功")
                // 发送加入房间的消息
                self?.socketIO.sendJoinChatRoomMessage(roomId: self?.testRoomId, lectureId: self?.testLectureId, userId: self?.testUserId)
   
            default: break
            }
        }

        // 接受房间Socket聊天消息
        socketIO.receiveChat {[weak self] type, json in
            print("收到socket消息：\(json)")
            guard let message = json["body"]["content"].string else { return }
            self?.dataSource.append(message)
            self?.tableView.reloadData()
        }
    }
}



extension ViewController{
    
    ///连接socket
    @IBAction func connectClick(_ sender: Any) {
        setupSocketService()
        socketIO.connect()
    }
    
    
    /// 断开socket
    @IBAction func DisconnectClick(_ sender: Any) {
        print("断开socket")
        socketIO.disconnect()
    }
    
    @IBAction func sendMessageBtnClick(_ sender: Any) {
        textFiled.resignFirstResponder()
        guard let message = textFiled.text else { return }
        self.socketIO.sendEnterLiveClassMessage(roomId: testRoomId, userId: testUserId, nickname: nickName, avatarUrl: avatarUrl,content: message)
    }
}

extension ViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell") else { return UITableViewCell() }
        cell.textLabel?.text = dataSource[indexPath.row]
        return cell
    }
}
