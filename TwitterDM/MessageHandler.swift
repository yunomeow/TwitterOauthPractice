//
//  MessageHandler.swift
//  TwitterDM
//
//  Created by 翰廷 姜 on 2017/5/22.
//  Copyright © 2017年 翰廷 姜. All rights reserved.
//

import Foundation
class MessageHandler{
    var array : [Message]
    
    init(){
        array = [Message]()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(receive(notification:)),
                                               name: NSNotification.Name(rawValue: "gotMessage"),
                                               object: nil)

    }
    deinit{
        NotificationCenter.default.removeObserver(observer: self)
    }
    func send(message:String){
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gotMessage"),
                                        object: Message(text: message,user: "self"))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gotMessage"),
                                            object: Message(text: "\(message) \(message)",user: "other"))

        })
    }
    @objc func receive(notification : Notification){
        guard let newMessage = notification.object as! Message? else{
            return
        }
        array.append(newMessage)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "messageArrayChange"),
                                        object: nil)

    }
}
