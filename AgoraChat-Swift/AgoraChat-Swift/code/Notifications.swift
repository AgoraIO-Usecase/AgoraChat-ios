//
//  Notifications.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/11/7.
//

import Foundation

let UserInfoDidChangeNotification = Notification.Name(rawValue: "userinfo_update")
let GroupCreatedNotification = Notification.Name(rawValue: "createGroup")
let PresenceUpdateNotification = Notification.Name(rawValue: "PresenceUpdate")
let ConversationsUpdatedNotification = Notification.Name(rawValue: "UpdateConversations")
let GroupListChangedNotification = Notification.Name(rawValue: "refreshGroups_notification")
let GroupLeftNotification = Notification.Name(rawValue: "KAgora_GROUP_DESTORY_OR_KICKEDOFF")
let UnreadMessageCountChangeNotification = Notification.Name(rawValue: "setupUnreadMessageCount")
let GroupInfoChangedNotification = Notification.Name(rawValue: "UpdateGroupInfo_notification")
let GroupMemberChangedNotification = Notification.Name(rawValue: "KACD_REFRESH_GROUP_MEMBER")
let LoginStateChangedNotification = Notification.Name(rawValue: "loginStateChange")
let CallKitRecordMessageNotification = Notification.Name(rawValue: "AGORA_CHAT_CALL_KIT_COMMMUNICATE_RECORD")
let ContactsUpdatedNotification = Notification.Name("KACD_REFRESH_CONTACTS")
