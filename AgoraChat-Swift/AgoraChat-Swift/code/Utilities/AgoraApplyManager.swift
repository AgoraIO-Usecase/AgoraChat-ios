//
//  AgoraApplyManager.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/27.
//

import UIKit

class AgoraApplyManager: NSObject {
    
    static let shared = AgoraApplyManager()
    
    private var contactApplys: [AgoraApplyModel] = []
    private var groupApplys: [AgoraApplyModel] = []
    
    var unhandleApplysCount: Int {
        var count = 0
        for apply in self.contactApplys where apply.status == .unhandle {
            count += 1
        }
        for apply in self.groupApplys where apply.status == .unhandle {
            count += 1
        }
        return count
    }
    
    func isExistingRequest(_ type: AgoraApplyModel.ApplyType) -> Bool {
        switch type {
        case .contact:
            for i in self.contactApplys where i.type == type {
                return true
            }
        case .inviteGroup, .joinGroup:
            for i in self.groupApplys where i.type == type {
                return true
            }
        }
        return false
    }
    
    private var localContactApplysKey: String? {
        guard let user = AgoraChatClient.shared().currentUsername, user.count > 0 else {
            return nil
        }
        return "\(user)_contactApplys"
    }
    
    private var localGroupApplysKey: String? {
        guard let user = AgoraChatClient.shared().currentUsername, user.count > 0 else {
            return nil
        }
        return "\(user)_groupApplys"
    }
    
    @discardableResult func reloadContactApplys() -> [AgoraApplyModel] {
        self.contactApplys.removeAll()
        guard let key = self.localContactApplysKey else {
            return self.contactApplys
        }
        guard let data = UserDefaults.standard.object(forKey: key) as? Data, data.count > 0 else {
            return self.contactApplys
        }
        guard let list = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AgoraApplyModel] else {
            return self.contactApplys
        }
        self.contactApplys.append(contentsOf: list)
        return self.contactApplys
    }
    
    @discardableResult func reloadGroupApplys() -> [AgoraApplyModel] {
        self.groupApplys.removeAll()
        guard let key = self.localGroupApplysKey else {
            return self.groupApplys
        }
        guard let data = UserDefaults.standard.object(forKey: key) as? Data, data.count > 0 else {
            return self.groupApplys
        }
        guard let list = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AgoraApplyModel] else {
            return self.groupApplys
        }
        self.groupApplys.append(contentsOf: list)
        return self.groupApplys
    }
    
    func addOrUpdate(apply: AgoraApplyModel) {
        switch apply.type {
        case .contact:
            guard let key = self.localContactApplysKey else {
                return
            }
            var has = false
            for i in 0..<self.contactApplys.count where self.contactApplys[i].type == apply.type {
                self.contactApplys.remove(at: i)
                self.contactApplys.append(apply)
                has = true
                break
            }
            if !has {
                self.contactApplys.append(apply)
            }
            let data = NSKeyedArchiver.archivedData(withRootObject: self.contactApplys)
            UserDefaults.standard.set(data, forKey: key)
        default:
            guard let key = self.localGroupApplysKey else {
                return
            }
            var has = false
            for i in 0..<self.groupApplys.count where self.groupApplys[i].type == apply.type {
                self.groupApplys.remove(at: i)
                self.groupApplys.append(apply)
                has = true
                break
            }
            if !has {
                self.groupApplys.append(apply)
            }
            let data = NSKeyedArchiver.archivedData(withRootObject: self.groupApplys)
            UserDefaults.standard.set(data, forKey: key)
        }
        UserDefaults.standard.synchronize()
        AgoraChatDemoHelper.shared.setupUntreatedApplyCount()
    }
    
    func remove(apply: AgoraApplyModel) {
        switch apply.type {
        case .contact:
            guard let key = self.localContactApplysKey else {
                return
            }
            for i in 0..<self.contactApplys.count where self.contactApplys[i].type == apply.type {
                self.contactApplys.remove(at: i)
                break
            }
            let data = NSKeyedArchiver.archivedData(withRootObject: self.contactApplys)
            UserDefaults.standard.set(data, forKey: key)
        default:
            guard let key = self.localGroupApplysKey else {
                return
            }
            for i in 0..<self.groupApplys.count where self.groupApplys[i].type == apply.type {
                self.groupApplys.remove(at: i)
                break
            }
            let data = NSKeyedArchiver.archivedData(withRootObject: self.groupApplys)
            UserDefaults.standard.set(data, forKey: key)
        }
        UserDefaults.standard.synchronize()
        AgoraChatDemoHelper.shared.setupUntreatedApplyCount()
    }
}
