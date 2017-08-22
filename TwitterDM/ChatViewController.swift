//
//  ChatViewController.swift
//  TwitterDM
//
//  Created by 翰廷 姜 on 2017/5/15.
//  Copyright © 2017年 翰廷 姜. All rights reserved.
//

import Foundation
import UIKit

class ChatViewController : UIViewController,UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var input: UITextField!
    @IBOutlet weak var sendButton: UIButton!

    var handler : MessageHandler?
    var username : String?
    deinit{
        NotificationCenter.default.removeObserver(observer: self)
    }
    override func viewDidLoad() {
        self.automaticallyAdjustsScrollViewInsets = false
        chatTableView.allowsSelection = false
        chatTableView.rowHeight = UITableViewAutomaticDimension
        chatTableView.estimatedRowHeight = 150;
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard(_:)))
        chatTableView.addGestureRecognizer(gesture)

        navigationItem.title = username

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reload(notification:)),
                                               name: NSNotification.Name(rawValue: "messageArrayChange"),
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: Notification.Name.UIKeyboardWillShow,
                                               object: nil
        )
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(notification:)),
                                               name: Notification.Name.UIKeyboardWillHide,
                                               object: nil
        )
        
        
        handler = MessageHandler()
    }

    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(observer: self)
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return (handler?.array.count)!
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : UITableViewCell
        //print(handler?.array[indexPath.section].user)
        if handler?.array[indexPath.section].user.compare("self") == ComparisonResult.orderedSame{
            cell = tableView.dequeueReusableCell(withIdentifier: "SelfCell", for: indexPath)
        }else{
            cell = tableView.dequeueReusableCell(withIdentifier: "OtherCell", for: indexPath)
        }
        if cell is SelfMessageTableViewCell{
            let customCell = cell as! SelfMessageTableViewCell
            customCell.message.text = handler?.array[indexPath.section].text
            customCell.message.textColor = UIColor.white
            customCell.messageView.backgroundColor = UIColor.init(red: 76/255.0, green: 141/255.0, blue: 237/255.0, alpha: 1.0)
            customCell.messageView.layer.cornerRadius = 10
            customCell.messageView.layer.masksToBounds = true
            let messageSize = customCell.message.sizeThatFits(cell.frame.size)
            let screenWidth = UIApplication.shared.keyWindow?.frame.size.width
            var finalWidth = screenWidth! - messageSize.width - 40
            finalWidth = min(finalWidth,screenWidth! - 50)
            finalWidth = max(finalWidth, 14)
            customCell.messagePadding.constant = finalWidth
            cell.updateConstraints()
            customCell.message.preferredMaxLayoutWidth = customCell.frame.size.width
        }else if cell is OtherMessageTableViewCell{
            let customCell = cell as! OtherMessageTableViewCell
            customCell.message.text = handler?.array[indexPath.section].text
            customCell.message.textColor = UIColor.white
           
            customCell.messageView.backgroundColor = UIColor.init(red: 178/255.0, green: 178/255.0, blue: 178/255.0, alpha: 1.0)
            customCell.messageView.layer.cornerRadius = 10
            customCell.messageView.layer.masksToBounds = true
            let messageSize = customCell.message.sizeThatFits(cell.frame.size)
            let screenWidth = UIApplication.shared.keyWindow?.frame.size.width
            var finalWidth = screenWidth! - messageSize.width - 40
            finalWidth = min(finalWidth,screenWidth! - 50)
            finalWidth = max(finalWidth, 14)
            customCell.messagePadding.constant = finalWidth
            cell.updateConstraints()
            customCell.message.preferredMaxLayoutWidth = customCell.frame.size.width
        }
        
        return cell
    }
    @IBAction func sendMessage(_ sender: Any) {
        guard (input.text?.characters.count)! > 0 else{
            return
        }
        handler?.send(message: input.text!)
        input.text = ""
    }
    

    func reload(notification : Notification){
        chatTableView.reloadData()
    }
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        view.frame = CGRect(x:view.frame.origin.x,
                            y:view.frame.origin.y,
                            width: (UIApplication.shared.keyWindow?.frame.width)!,
                            height: (UIApplication.shared.keyWindow?.frame.height)! - keyboardFrame.height)
    }
    func keyboardWillHide(notification: NSNotification) {
        view.frame = CGRect(x:view.frame.origin.x,
                            y:view.frame.origin.y,
                            width: (UIApplication.shared.keyWindow?.frame.width)!,
                            height: (UIApplication.shared.keyWindow?.frame.height)!)
    }
    @objc func closeKeyboard(_ sender:UITapGestureRecognizer){
        view.endEditing(true)
    }
}
