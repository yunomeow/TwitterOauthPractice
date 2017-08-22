//
//  UserListViewController.swift
//  TwitterDM
//
//  Created by 翰廷 姜 on 2017/5/15.
//  Copyright © 2017年 翰廷 姜. All rights reserved.
//

import Foundation
import UIKit


class UserListViewController : UITableViewController{
    
    
    var nameList : [String]?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.title = "Twitter DM"
        let titleDict: Dictionary<String,Any> = [NSForegroundColorAttributeName: UIColor.init(red: 76/255.0, green: 141/255.0, blue: 237/255.0, alpha: 1.0)]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gotFollowersList(notification:)),
                                               name: NSNotification.Name(rawValue: "gotFollwersList"),
                                               object: nil)
        TwitterAPI.shared().getFollwersList()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard nameList != nil else{
            return 0
        }
        return nameList!.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        cell.textLabel?.text = "@\(nameList?[indexPath.row] ?? "")"
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?){
        let dest = segue.destination as? ChatViewController
        let cell = sender as! UITableViewCell
        dest?.username = cell.textLabel?.text
    }

    
    func gotFollowersList(notification: Notification){
        let list = notification.object as! [String]
        if nameList == nil{
            nameList = [String]()
        }
        for name in list{
            nameList?.append(name)
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
}
