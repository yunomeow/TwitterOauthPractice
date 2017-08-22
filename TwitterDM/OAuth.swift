//
//  OAuth.swift
//  TwitterDM
//
//  Created by 翰廷 姜 on 2017/5/20.
//  Copyright © 2017年 翰廷 姜. All rights reserved.
//

import Foundation
import UIKit
import CommonCrypto

enum OAuthError: Error {
    case oauth_callback_confirmed_false
    case oauth_x_auth_expires
    case api_Error
}
class OAuth{

    var dataEncoding: String.Encoding = String.Encoding.utf8
    
    init(){
    }
    
    
    func getRequestToken(consumerKey: String,
                         consumerSecret: String,
                         requestTokenUrl: String,
                         completionHandler: @escaping (String?, String?, Error?) -> Void){
        
        print("Start Get RequestToken")
        var param = Dictionary<String, String>()
        param["oauth_version"] = "1.0"
        param["oauth_signature_method"] = "HMAC-SHA1"
        param["oauth_consumer_key"] = consumerKey
        param["oauth_timestamp"] = getTimeStamp()
        param["oauth_nonce"] = getNonce()
        param["oauth_callback"] = "http://example.com/"
        param["oauth_signature"] = self.getOauthSignature(method: "POST",
                                                                url: URL(string:requestTokenUrl)!,
                                                                parameters: param,
                                                                consumerSecret: consumerSecret,
                                                                oauthTokenSecret: "")

        
        let headerComponents = makeHeader(param: param)
        var request = URLRequest(url: URL(string: requestTokenUrl)!);
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.setValue("OAuth \(headerComponents.joined(separator: ","))", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if(error != nil){
                print("Error occur \(error!)")
                completionHandler(nil,nil,error)
                return
            }
            let result = String(data: data!, encoding: .utf8)!
            print("Request Token Result: \(result)")
            let resultComponent = result.components(separatedBy: "&")
            var res_oauthToken : String?
            var res_oauthTokenSecret : String?
            
            for component in  resultComponent{
                let subcomponent = component.components(separatedBy: "=")
                if subcomponent.count == 2 {
                    if subcomponent[0].compare("oauth_token") == ComparisonResult.orderedSame{
                        res_oauthToken = subcomponent[1]
                    }else if subcomponent[0].compare("oauth_token_secret") == ComparisonResult.orderedSame{
                        res_oauthTokenSecret = subcomponent[1]
                    }else if subcomponent[0].compare("oauth_callback_confirmed") == ComparisonResult.orderedSame{
                        guard subcomponent[1].compare("true") == ComparisonResult.orderedSame else{
                            completionHandler(nil,nil,OAuthError.oauth_callback_confirmed_false)
                            return
                        }
                    }
                    
                    
                }
            }
            completionHandler(res_oauthToken,res_oauthTokenSecret,nil)

        })
        task.resume()
    }
    func getAccessToken(consumerKey: String,
                        consumerSecret: String,
                        accessTokenUrl: String,
                        oauthToken : String,
                        oauthTokenSecret : String ,
                        oauthVerifier : String,
                        completionHandler: @escaping (String?, String?, String?,String?, Error?) -> Void){
        
        print("Start Get AccessToken")
        var param = Dictionary<String, String>()
        param["oauth_version"] = "1.0"
        param["oauth_signature_method"] = "HMAC-SHA1"
        param["oauth_consumer_key"] = consumerKey
        param["oauth_timestamp"] = getTimeStamp()
        param["oauth_nonce"] = getNonce()
        param["oauth_token"] = oauthToken
        param["oauth_signature"] = self.getOauthSignature(method: "POST", url: URL(string:accessTokenUrl)!, parameters: param,consumerSecret: consumerSecret,oauthTokenSecret: oauthTokenSecret)
        
        let headerComponents = makeHeader(param: param)
        var request = URLRequest(url: URL(string: accessTokenUrl)!);
        request.httpMethod = "POST"
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.setValue("OAuth \(headerComponents.joined(separator: ","))", forHTTPHeaderField: "Authorization")
        request.httpBody = oauthVerifier.data(using: .utf8)
        
       // print(request)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if(error != nil){
                print("Error occur \(error!)")
                return
            }
            let result = String(data: data!, encoding: .utf8)!
           print("Access Token Result: \(result)")
            let resultComponent = result.components(separatedBy: "&")
            var res_oauthToken : String?
            var res_oauthTokenSecret : String?
            var res_userID : String?
            var res_screenName : String?
            for component in  resultComponent{
                let subcomponent = component.components(separatedBy: "=")

                
                if subcomponent.count == 2 {
                    if subcomponent[0].compare("oauth_token") == ComparisonResult.orderedSame{
                        res_oauthToken = subcomponent[1]
                    }else if subcomponent[0].compare("oauth_token_secret") == ComparisonResult.orderedSame{
                        res_oauthTokenSecret = subcomponent[1]
                    }else if subcomponent[0].compare("user_id") == ComparisonResult.orderedSame{
                        res_userID = subcomponent[1]
                    }else if subcomponent[0].compare("screen_name") == ComparisonResult.orderedSame{
                        res_screenName = subcomponent[1]
                    }else if subcomponent[0].compare("x_auth_expires") == ComparisonResult.orderedSame{
                        guard subcomponent[1].compare("0") == ComparisonResult.orderedSame else{
                            completionHandler(nil,nil,nil,nil,OAuthError.oauth_x_auth_expires)
                            return
                        }
                    }
                }
            }
            completionHandler(res_oauthToken,res_oauthTokenSecret,res_userID,res_screenName,nil)
            
            
        })
        task.resume()
    }
    
    
    
    func useAPI(apiName: String,
                consumerKey: String,
                consumerSecret: String,
                method: String,
                apiURL: String,
                body: String,
                oauthToken : String,
                oauthTokenSecret : String ,
                other: Dictionary<String,String>?,
                completionHandler: @escaping (Data?, Error?) -> Void){
        
        print("Start API: \(apiName)")
        var param = Dictionary<String, String>()
        param["oauth_version"] = "1.0"
        param["oauth_signature_method"] = "HMAC-SHA1"
        param["oauth_consumer_key"] = consumerKey
        param["oauth_timestamp"] = getTimeStamp()
        param["oauth_nonce"] = getNonce()
        param["oauth_token"] = oauthToken
        if(other != nil){
            for(key,value) in other!{
                param[key] = value
            }
        }
        param["oauth_signature"] = self.getOauthSignature(method: method,
                                                          url: URL(string:apiURL)!,
                                                          parameters: param,
                                                          consumerSecret: consumerSecret,
                                                          oauthTokenSecret: oauthTokenSecret)
        
        let headerComponents = makeHeader(param: param)
        var request = URLRequest(url: URL(string: apiURL)!);
        request.httpMethod = method
        request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
        request.setValue("OAuth \(headerComponents.joined(separator: ","))", forHTTPHeaderField: "Authorization")
        request.httpBody = body.data(using: .utf8)
        // print(request)
        
        let task = URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            if(error != nil){
                print("Error occur \(error!)")
                completionHandler(nil,OAuthError.api_Error)
                return
            }
            let result = String(data: data!, encoding: .utf8)!
            print("API Result: \(result)")
            completionHandler(data,nil)
        })
        task.resume()
    }
    
    
    private func makeHeader(param : Dictionary<String,String>)->[String]{
        var authorizationParameterComponents = urlEncodedQueryStringWithEncoding(params: param).components(separatedBy: "&")
        authorizationParameterComponents.sort { $0 < $1 }
        
        var headerComponents = [String]()
        for component in authorizationParameterComponents {
            let subcomponent = component.components(separatedBy: "=")
            
            if subcomponent.count == 2 {
                headerComponents.append("\(subcomponent[0])=\"\(subcomponent[1])\"")
            }
        }
      //  print("Header \(headerComponents)")
        return headerComponents
    }
    
    
    
    
    
    private func getOauthSignature(method: String,
                                         url: URL,
                                         parameters: Dictionary<String, String>,
                                         consumerSecret: String,
                                         oauthTokenSecret : String) -> String {
        let signingKey : String = "\(consumerSecret)&\(oauthTokenSecret)"
        
        var parameterComponents = urlEncodedQueryStringWithEncoding(params: parameters).components(separatedBy: "&")
        parameterComponents.sort { $0 < $1 }
        
        let parameterString = parameterComponents.joined(separator: "&")
        
        let encodedParameterString = urlEncodedStringWithEncoding(str: parameterString)
        
        let encodedURL = urlEncodedStringWithEncoding(str: url.absoluteString)
        
        let signatureBaseString = "\(method)&\(encodedURL)&\(encodedParameterString)"

        return SHA1DigestWithKey(base: signatureBaseString, key: signingKey).base64EncodedString()
    }
    
    private func urlEncodedQueryStringWithEncoding(params:Dictionary<String, String>) -> String {
        var parts = [String]()
        for (key, value) in params {
            let keyString = urlEncodedStringWithEncoding(str: key)
            let valueString = urlEncodedStringWithEncoding(str: value)
            let query = "\(keyString)=\(valueString)" as String
            parts.append(query)
        }
        
        return parts.joined(separator: "&")
    }
    
    private func urlEncodedStringWithEncoding(str: String) -> String {
        let charactersToBeEscaped = ":/?&=;+!@#$()',*"
        let result = str.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlHostAllowed.subtracting(CharacterSet(charactersIn: charactersToBeEscaped)))
        return result!
    }
    
    private func SHA1DigestWithKey(base: String, key: String) -> NSData {
        let str = base.cString(using: dataEncoding)
        let strLen = UInt(base.lengthOfBytes(using: dataEncoding))
        let digestLen = Int(CC_SHA1_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        let keyStr = key.cString(using: String.Encoding.utf8)
        let keyLen = UInt(key.lengthOfBytes(using: String.Encoding.utf8))
        CCHmac(CCHmacAlgorithm(kCCHmacAlgSHA1), keyStr!, Int(keyLen), str!, Int(strLen), result)
        return NSData(bytes: result, length: digestLen)
    }
    private func getNonce()->String{
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, keyData.count, $0)
        }
        if result == errSecSuccess {
            var result:String = ""
            for c in Array(keyData.base64EncodedString().unicodeScalars){
                if(CharacterSet.alphanumerics.contains(c)){
                    result.append(Character(c))
                }
            }
            return result
        } else {
            print("Problem generating random bytes")
            return ""
        }
    }
    private func getTimeStamp()->String{
        let timeInterval:TimeInterval = Date().timeIntervalSince1970
        let timeStamp = String(Int(timeInterval))
        return timeStamp
    }
}
