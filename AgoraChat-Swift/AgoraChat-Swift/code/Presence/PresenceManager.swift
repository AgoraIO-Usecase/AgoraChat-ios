//
//  PresenceManager.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/26.
//

import UIKit

class PresenceManager: NSObject {
    enum State: Int {
        case offline = 0
        case online = 1
        case busy = 100
        case doNotDisturb = 101
        case leave = 102
        case custom = 103
    }
    
    static let presenceImagesMap: [State: String] = [
        .offline: "Offline",
        .online: "Online",
        .busy: "Busy",
        .doNotDisturb: "Do not Disturb",
        .leave: "Leave",
        .custom: "custom"
    ]
    
    static let whiteStrokePresenceImagesMap: [State: String] = [
        .offline: "Offline_whitestroke",
        .online: "Online_whitestroke",
        .busy: "Busy_whitestroke",
        .doNotDisturb: "Do not Disturb_whitestroke",
        .leave: "Leave_whitestroke",
        .custom: "custom_whitestroke"
    ]
    
    static let showStatusMap: [State: String] = [
        .offline: "Offline".localized,
        .online: "Online".localized,
        .busy: "Busy".localized,
        .doNotDisturb: "Do Not Disturb".localized,
        .leave: "Leave".localized
    ]
    
    class func formatOfflineTimespace(presence: AgoraChatPresence?) -> String {
        guard let lastTime = presence?.lastTime else {
            return self.showStatusMap[.offline]!
        }
        let timeinterval = Int(Date().timeIntervalSince1970 - Double(lastTime))
        let timeStr: String
        if timeinterval < 60 {
            timeStr = "1 \("Minute".localized)"
        } else if timeinterval < 60 * 60 {
            timeStr = "\(timeinterval / 60) \("Minutes".localized)"
        } else if timeinterval < 60 * 60 * 24 {
            timeStr = "\(timeinterval / 60 / 60) \("Hours".localized)"
        } else if timeinterval < 60 * 60 * 24 * 7 {
            timeStr = "\(timeinterval / 60 / 60 / 24) \("Days".localized)"
        } else {
            timeStr = "\(timeinterval / 60 / 60 / 24 / 7) \("Weeks".localized)"
        }
        return String(format: "Online %@ ago".localized, timeStr)
    }
    
    static let shared = PresenceManager()
    
    class func fetchStatus(presence: AgoraChatPresence?) -> State {
        guard let presence = presence, let statusDetails = presence.statusDetails else {
            return .offline
        }
        if statusDetails.count <= 0 {
            return .offline
        }
        var state: State = .offline
        for i in statusDetails {
            if i.status == 1 {
                state = .online
                break
            }
        }
        
        if state != .offline, let statusDescription = presence.statusDescription, statusDescription.count > 0 {
            state = .custom
            for i in self.showStatusMap where statusDescription == i.value {
                state = i.key
                break
            }
        }
        return state
    }
    
    private var subscribedMembers: [String] = []
    var presences: [String: AgoraChatPresence] = [:]
    
    private override init() {
        super.init()
        AgoraChatClient.shared().presenceManager?.add(self, delegateQueue: nil)
        AgoraChatClient.shared().add(self, delegateQueue: nil)
    }
    
    func subscribe(members: [String], completion: ((_ presence: [AgoraChatPresence]?, _ error: AgoraChatError?) -> Void)?) {
        var index = 0
        var count = members.count
        while count > 0 {
            var range = NSRange(location: index * 100, length: 0)
            if count > 100 {
                range.length = 100
                index += 1
            } else {
                range.length = count
            }
            count -= range.length
            let array = Array(members[range.location..<range.location + range.length])
            AgoraChatClient.shared().presenceManager?.subscribe(array, expiry: 7 * 24 * 3600, completion: { presences, error in
                if let presences = presences {
                    self.subscribedMembers.append(contentsOf: array)
                    var users: [String] = []
                    for presence in presences {
                        if presence.publisher.count > 0 {
                            users.append(presence.publisher)
                            self.presences[presence.publisher] = presence
                        }
                    }
                    if presences.count > 0 {
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: PresenceUpdateNotification, object: users)
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion?(presences, error)
                }
            })
        }
    }

    func unsubscribe(members: [String], completion: ((_ error: AgoraChatError?) -> Void)?) {
        var index = 0
        var count = members.count
        while count > 0 {
            var range = NSRange(location: index * 100, length: 0)
            if count > 100 {
                range.length = 100
                index += 1
            } else {
                range.length = count
            }
            count -= range.length
            let array = Array(members[range.location..<range.location + range.length])
            AgoraChatClient.shared().presenceManager?.unsubscribe(array, completion: { error in
                if error == nil {
                    self.subscribedMembers.remove(elements: array)
                }
                completion?(error)
            })
        }
    }

    func publishPresence(description: String?, completion: ((_ error: AgoraChatError?) -> Void)?) {
        var description = description
        if description == PresenceManager.showStatusMap[.online] {
            description = nil
        }
        AgoraChatClient.shared().presenceManager?.publishPresence(withDescription: description, completion: { error in
            completion?(error)
        })
    }
}

extension PresenceManager: AgoraChatPresenceManagerDelegate {
    func presenceStatusDidChanged(_ presences: [AgoraChatPresence]) {
        var users: [String] = []
        for presence in presences {
            if presence.publisher.count > 0 {
                users.append(presence.publisher)
                self.presences[presence.publisher] = presence
            }
        }
        if presences.count > 0 {
            NotificationCenter.default.post(name: PresenceUpdateNotification, object: users)
        }
    }
}

extension PresenceManager: AgoraChatClientDelegate {
    func connectionStateDidChange(_ aConnectionState: AgoraChatConnectionState) {
        guard let currentUsername = AgoraChatClient.shared().currentUsername, let presence = self.presences[currentUsername], let statusDetails = presence.statusDetails else {
            return
        }
        if aConnectionState == .disconnected {
            for detail in statusDetails {
                detail.status = PresenceManager.State.offline.rawValue
            }
            NotificationCenter.default.post(name: PresenceUpdateNotification, object: [currentUsername])
        }
    }
}
