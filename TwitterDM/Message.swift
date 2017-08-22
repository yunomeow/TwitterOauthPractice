//
//  Message.swift
//  TwitterDM
//
//  Created by 翰廷 姜 on 2017/5/22.
//  Copyright © 2017年 翰廷 姜. All rights reserved.
//

import Foundation
class Message{
    var text : String
    var user : String
    init(text: String,user: String){
        self.text = text
        self.user = user
    }
}
