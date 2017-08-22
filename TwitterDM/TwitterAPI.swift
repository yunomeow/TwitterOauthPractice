//
//  TwitterAPI.swift
//  TwitterDM
//
//  Created by 翰廷 姜 on 2017/5/21.
//  Copyright © 2017年 翰廷 姜. All rights reserved.
//

import Foundation
import UIKit

class TwitterAPI{
  
    let consumerKey = "0N1S6stE1mzf6p8inNsZ1YN6Q"
    let consumerKeySecret = "mhQl4mmc2KlCkIB85kc5zdlID54iqqVIDBQFS1w4eDCYhLik6r"
    var oauthTokenSecret :String?
    var oauthToken : String?
    var userID: String?
    var screenName : String?
    
    let connection = OAuth()
    
    
    static var instance : TwitterAPI?
    
    private init(){
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gotOAuthToken(notification:)),
                                               name: NSNotification.Name(rawValue: "gotOAuthToken"),
                                               object: nil)
    }
    static func shared() -> TwitterAPI{
        if TwitterAPI.instance == nil {
            TwitterAPI.instance = TwitterAPI()
        }
        return TwitterAPI.instance!
    }
    func start(webview : UIWebView){
        
        connection.getRequestToken(consumerKey: consumerKey,
                                 consumerSecret: consumerKeySecret,
                                 requestTokenUrl: "https://api.twitter.com/oauth/request_token"){
                                    (token,tokenSecret,error)in
                                    guard error == nil else{
                                        return
                                    }
                                    webview.loadRequest(URLRequest(url: URL(string: "https://api.twitter.com/oauth/authenticate?oauth_token=\(token ?? "")")!))
                                    self.oauthTokenSecret = tokenSecret
                                 }

    }
    @objc func gotOAuthToken(notification: NSNotification){
        //print(notification.userInfo ?? "userInfo is nil")
        let oauth_verifier = notification.userInfo?["oauth_verifier"] as! String
        let oauth_token = notification.userInfo?["oauth_token"] as! String
        connection.getAccessToken(consumerKey: consumerKey,
                                   consumerSecret: consumerKeySecret,
                                   accessTokenUrl: "https://api.twitter.com/oauth/access_token",
                                   oauthToken: oauth_token,
                                   oauthTokenSecret: oauthTokenSecret!,
                                   oauthVerifier: "oauth_verifier=\(oauth_verifier)"){
                                    (token,tokenSecret,userID,screenName,error)in
                                    guard error == nil else{
                                        return
                                    }
                                    self.oauthToken = token
                                    self.oauthTokenSecret = tokenSecret
                                    self.userID = userID
                                    self.screenName = screenName
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "authenticateSuccess"),object: nil)
        }
    }
    
    func getFollwersList(){
        //TODO: get more follwers, default is 20
        connection.useAPI(apiName: "FollwersList",
                          consumerKey: consumerKey,
                          consumerSecret: consumerKeySecret,
                          method: "GET",
                          apiURL: "https://api.twitter.com/1.1/followers/list.json",
                          body: "",
                          oauthToken: oauthToken!,
                          oauthTokenSecret: oauthTokenSecret!,
                          other: nil){
                            (result,error) in
                            do{
                                var nameList = [String]()
                                guard error == nil else{
                                    return
                                }
                                let json = try JSONSerialization.jsonObject(with: result!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String : AnyObject]
                                if let array = json["users"] as? [AnyObject]{
                                    for i in 0...array.count-1 {
                                        let obj = array[i] as! [String : AnyObject]
                                        nameList.append(obj["screen_name"] as! String)
                                    }
                                }
                                print(nameList)
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gotFollwersList"), object: nameList)
                            }catch let err as NSError {
                                print(err.localizedDescription)
                            }
                            
        }
    }
    
    
}
