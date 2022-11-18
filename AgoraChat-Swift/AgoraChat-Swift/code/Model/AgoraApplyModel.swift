//
//  AgoraApplyModel.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/27.
//

import UIKit

class AgoraApplyModel: NSObject, NSCoding {
    enum ApplyType {
        case contact(userId: String)
        case joinGroup(userId: String, groupId: String)
        case inviteGroup(userId: String, groupId: String)
    }
    
    enum Status: Int32 {
        case unhandle
        case agreed
        case declined
        case expired
    }
    
    let type: ApplyType
    var applyNickname: String?
    var reason: String?
    var groupSubject: String?
    var groupMemberCount: Int32 = 0
    var status: Status = .unhandle
    
    init(type: ApplyType) {
        self.type = type
        super.init()
    }
    
    required init?(coder: NSCoder) {
        let type = coder.decodeInt32(forKey: "typeValue")
        guard let userId = coder.decodeObject(forKey: "userId") as? String else {
            return nil
        }
        let groupId = coder.decodeObject(forKey: "groupId") as? String
        
        switch type {
        case 1:
            self.type = .contact(userId: userId)
        case 2:
            if let groupId = groupId {
                self.type = .joinGroup(userId: userId, groupId: groupId)
            } else {
                return nil
            }
        case 3:
            if let groupId = groupId {
                self.type = .inviteGroup(userId: userId, groupId: groupId)
            } else {
                return nil
            }
        default:
            return nil
        }
        self.applyNickname = coder.decodeObject(forKey: "applyNickname") as? String
        self.reason = coder.decodeObject(forKey: "reason") as? String
        self.groupSubject = coder.decodeObject(forKey: "groupSubject") as? String
        self.groupMemberCount = coder.decodeInt32(forKey: "groupMemberCount")
        self.status = Status(rawValue: coder.decodeInt32(forKey: "status")) ?? .unhandle
        super.init()
    }
    
    func encode(with coder: NSCoder) {
        switch self.type {
        case .contact(userId: let userId):
            coder.encodeCInt(1, forKey: "typeValue")
            coder.encode(userId, forKey: "userId")
        case .joinGroup(userId: let userId, groupId: let groupId):
            coder.encodeCInt(2, forKey: "typeValue")
            coder.encode(userId, forKey: "userId")
            coder.encode(groupId, forKey: "groupId")
        case .inviteGroup(userId: let userId, groupId: let groupId):
            coder.encodeCInt(3, forKey: "typeValue")
            coder.encode(userId, forKey: "userId")
            coder.encode(groupId, forKey: "groupId")
        }
        
        coder.encode(self.applyNickname, forKey: "applyNickname")
        coder.encode(self.reason, forKey: "reason")
        coder.encode(self.groupSubject, forKey: "groupSubject")
        coder.encodeCInt(self.groupMemberCount, forKey: "groupMemberCount")
        coder.encodeCInt(self.status.rawValue, forKey: "status")
    }
    
    var userId: String {
        switch self.type {
        case .contact(userId: let userId), .joinGroup(userId: let userId, groupId: _), .inviteGroup(userId: let userId, groupId: _):
            return userId
        }
    }
}

extension AgoraApplyModel.ApplyType: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.contact(userId: let l), .contact(userId: let r)):
            return l == r
        case (.joinGroup(userId: let l1, groupId: let l2), .joinGroup(userId: let r1, groupId: let r2)):
            return l1 == r1 && l2 == r2
        case (.inviteGroup(userId: let l1, groupId: let l2), .inviteGroup(userId: let r1, groupId: let r2)):
            return l1 == r1 && l2 == r2
        default:
            return false
        }
    }
}
