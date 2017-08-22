//
//  ViewController.swift
//  TwitterDM
//
//  Created by 翰廷 姜 on 2017/5/14.
//  Copyright © 2017年 翰廷 姜. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var webview: UIWebView!

    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBAction func loginAction(_ sender: Any) {
        webview.isHidden = false
        let btn = sender as! UIButton
        btn.isHidden = true
        logoImage.isHidden = true
        loadingSpinner.isHidden = false
        loadingSpinner.hidesWhenStopped = true
        loadingSpinner.startAnimating()
        TwitterAPI.shared().start(webview: webview)

        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        webview.isHidden = true
        loadingSpinner.isHidden = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(authenticateSuccess(notification:)),
                                               name: NSNotification.Name(rawValue: "authenticateSuccess"),
                                               object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

    func webViewDidFinishLoad(_ webView: UIWebView){
        //webview.isHidden = true
        print(webview.request?.url! ?? "")
        print(webview.request?.url?.host ?? "")
       // print(webview.request?.url?.query ?? "")
        loadingSpinner.stopAnimating()
        if(webview.request?.url?.host?.compare("example.com") == ComparisonResult.orderedSame){
            let queryString = webview.request?.url?.query?.components(separatedBy: "&")
            guard queryString?.count == 2 else{
                return
            }
            
            var param = Dictionary<String,String>()
            for component in queryString!{
                let subcomponent = component.components(separatedBy: "=")
                guard subcomponent.count == 2 else{
                    return
                }
                param[subcomponent[0]] = subcomponent[1]
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gotOAuthToken"), object: nil, userInfo: param)
            webview.isHidden = true
            loadingSpinner.isHidden = false
            loadingSpinner.hidesWhenStopped = true
            loadingSpinner.startAnimating()

        }
        
    }
    
    @objc func authenticateSuccess(notification: NSNotification){
        loadingSpinner.stopAnimating()
        self.performSegue(withIdentifier: "showFollwersList", sender: self)
    }

}

