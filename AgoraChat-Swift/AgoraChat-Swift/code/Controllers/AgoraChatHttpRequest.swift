//
//  AgoraChatHttpRequest.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/11.
//

import UIKit

fileprivate let AppServerHost = "https://ea14-118-167-14-13.ngrok-free.app"

class AgoraChatHttpRequest: NSObject {

    static let shared = AgoraChatHttpRequest()
    
    private var session: URLSession!
    
    override init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 120
        super.init()
        self.session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }
    
    func registerToApperServer(username: String, password: String, completion: @escaping (_ statusCode: Int, _ responseData: Data?) -> Void) {
        guard let url = URL(string: "\(AppServerHost)/app/chat/user/register") else {
            return
        }
        guard let body = try? JSONSerialization.data(withJSONObject: [
            "userAccount": username,
            "userPassword": password
        ]) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        request.httpBody = body
        let task = self.session.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    completion(response.statusCode, data)
                }
            }
        }
        task.resume()
    }
    
    func loginToApperServer(username: String, password: String, completion: @escaping (_ statusCode: Int, _ responseData: Data?) -> Void) {
        guard let url = URL(string: "\(AppServerHost)/app/chat/user/login") else {
            return
        }
        guard let body = try? JSONSerialization.data(withJSONObject: [
            "userAccount": username,
            "userPassword": password
        ]) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        request.httpBody = body
        let task = self.session.dataTask(with: request) { data, response, error in
            if let response = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    completion(response.statusCode, data)
                }
            }
        }
        task.resume()
    }
}

extension AgoraChatHttpRequest: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
            let credential = URLCredential(trust: trust)
            completionHandler(.useCredential, credential)
        }
    }
}
