//
//  EaseChatBusinessRequest.swift
//  AgoraChat-Swift
//
//  Created by 朱继超 on 2024/3/5.
//

import Foundation
import chat_uikit
import KakaJSON


public class EaseChatError: Error,Convertible {
    
    var code: String?
    var message: String?
    
    required public init() {
        
    }
    
    public func kj_modelKey(from property: Property) -> ModelPropertyKey {
        property.name
    }
}

@objc public class EaseChatBusinessRequest: NSObject {
        
    @objc public static let shared = EaseChatBusinessRequest()
        
    /// Description send a request contain generic
    /// - Parameters:
    ///   - method: ``EaseChatRequestHTTPMethod``
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    public func sendRequest<T:Convertible>(
        method: EaseChatRequestHTTPMethod,
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((T?,Error?) -> Void)) -> URLSessionTask? {
        print(params)

        let headers = ["Accept":"application/json","Content-Type":"application/json"]
        let task = EaseChatRequest.shared.constructRequest(method: method, uri: uri, params: params, headers: headers) { data, response, error in
            DispatchQueue.main.async {
                if error == nil,response?.statusCode ?? 0 == 200 {
                    callBack(model(from: data?.chat.toDictionary() ?? [:], type: T.self) as? T,error)
                } else {
                    if error == nil {
                        let errorMap = data?.chat.toDictionary() ?? [:]
                        let someError = model(from: errorMap, type: EaseChatError.self) as? Error
                        if let code = errorMap["code"] as? String,code == "401" {
                            NotificationCenter.default.post(name: NSNotification.Name("BackLogin"), object: nil)
                        }
                        callBack(nil,someError)
                    } else {
                        callBack(nil,error)
                    }
                }
            }
        }
        return task
    }
    /// Description send a request
    /// - Parameters:
    ///   - method: ``EaseChatRequestHTTPMethod``
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of dictionary and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    public func sendRequest(
        method: EaseChatRequestHTTPMethod,
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String,Any>?,Error?) -> Void)) -> URLSessionTask? {
        let headers = ["Accept":"application/json","Content-Type":"application/json"]
        let task = EaseChatRequest.shared.constructRequest(method: method, uri: uri, params: params, headers: headers) { data, response, error in
            if error == nil,response?.statusCode ?? 0 == 200 {
                callBack(data?.chat.toDictionary(),nil)
            } else {
                if error == nil,let data = data,!data.isEmpty {
                    let errorMap = data.chat.toDictionary() ?? [:]
                    let someError = model(from: errorMap, type: EaseChatError.self) as? Error
                    if let code = errorMap["code"] as? String,code == "401" {
                        NotificationCenter.default.post(name: Notification.Name("BackLogin"), object: nil)
                    }
                } else {
                    let someError = EaseChatError()
                    someError.message = error?.localizedDescription
                    someError.code = "\((error as? NSError)?.code ?? 400)"
                    callBack(nil,error)
                }
            }
        }
        return task
    }

}

//MARK: - rest request
public extension EaseChatBusinessRequest {
    
    //MARK: - generic uri request
    
    /// Description send a get request contain generic
    /// - Parameters:
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendGETRequest<U:Convertible>(
        uri: String,
        params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .get, uri: uri, params: params, callBack: callBack)
    }
    
    /// Description send a post request contain generic
    /// - Parameters:
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPOSTRequest<U:Convertible>(
        uri: String,params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .post, uri: uri, params: params, callBack: callBack)
    }
    
    /// Description send a put request contain generic
    /// - Parameters:
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPUTRequest<U:Convertible>(
        uri: String,params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .put, uri: uri, params: params, callBack: callBack)
    }
    
    /// Description send a delete request contain generic
    /// - Parameters:
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendDELETERequest<U:Convertible>(
        uri: String,params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .delete, uri: uri, params: params, callBack: callBack)
    }
    
    //MARK: - generic api request
    /// Description send a get request contain generic
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with ``EaseChatBusinessApi``.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendGETRequest<U:Convertible>(
        api: EaseChatBusinessApi,
        params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .get, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a post request contain generic
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with ``EaseChatBusinessApi``.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPOSTRequest<U:Convertible>(
        api: EaseChatBusinessApi,
        params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .post, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a put request contain generic
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with ``EaseChatBusinessApi``.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPUTRequest<U:Convertible>(
        api: EaseChatBusinessApi,
        params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .put, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a delete request contain generic
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with ``EaseChatBusinessApi``.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendDELETERequest<U:Convertible>(
        api: EaseChatBusinessApi,
        params: Dictionary<String, Any>,classType:U.Type,
        callBack:@escaping ((U?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .delete, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    //MARK: - no generic uri request
    /// Description send a get request
    /// - Parameters:
    ///   - method: ``EaseChatRequestHTTPMethod``
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of dictionary and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    @objc
    func sendGETRequest(
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .get, uri: uri, params: params, callBack: callBack)
    }
    /// Description send a post request
    /// - Parameters:
    ///   - method: ``EaseChatRequestHTTPMethod``
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of dictionary and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    @objc
    func sendPOSTRequest(
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .post, uri: uri, params: params, callBack: callBack)
    }
    /// Description send a put request
    /// - Parameters:
    ///   - method: ``EaseChatRequestHTTPMethod``
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of dictionary and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    @objc
    func sendPUTRequest(
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .put, uri: uri, params: params, callBack: callBack)
    }
    /// Description send a delete request
    /// - Parameters:
    ///   - method: ``EaseChatRequestHTTPMethod``
    ///   - uri: The part spliced after the host.For example,"/xxx/xxx"
    ///   - params: body params
    ///   - callBack: response callback the tuple that made of dictionary and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    @objc
    func sendDELETERequest(
        uri: String,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .delete, uri: uri, params: params, callBack: callBack)
    }
    
    //MARK: - no generic api request
    /// Description send a get request
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with ``EaseChatBusinessApi``.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendGETRequest(
        api: EaseChatBusinessApi,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .get, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a post request
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with ``EaseChatBusinessApi``.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPOSTRequest(
        api: EaseChatBusinessApi,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .post, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a put request
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with ``EaseChatBusinessApi``.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendPUTRequest(
        api: EaseChatBusinessApi,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .put, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description send a delete request
    /// - Parameters:
    ///   - api: The part spliced after the host.For example,"/xxx/xxx".Package with ``EaseChatBusinessApi``.
    ///   - params:  body params
    ///   - callBack: response callback the tuple that made of generic and error.
    /// - Returns: Request task,what if you can determine its status or cancel it .
    @discardableResult
    func sendDELETERequest(
        api: EaseChatBusinessApi,
        params: Dictionary<String, Any>,
        callBack:@escaping ((Dictionary<String, Any>?,Error?) -> Void)) -> URLSessionTask? {
        self.sendRequest(method: .delete, uri: self.convertApi(api: api), params: params, callBack: callBack)
    }
    
    /// Description convert api to uri
    /// - Parameter api: ``EaseChatBusinessApi``
    /// - Returns: uri string
    func convertApi(api: EaseChatBusinessApi) -> String {
        var uri = "/app/chat/"
        switch api {
        case .login(_):
            uri += "user/login"
        case .fetchGroupAvatar(let groupId):
            uri += "group/\(groupId)/avatarurl"
        case .fetchRTCToken(let channelId,let userId):
            uri += "token/rtc/channel/\(channelId)?userAccount=\(userId)"
        case .mirrorCallUserIdToChatUserId(let channelId,let userId):
            uri += "agora/channel/mapper?channelName=\(channelId)&userAccount=\(userId)"
        }
        return uri
    }
}


