//
//  EaseChatBusinessApi.swift
//  AgoraChat-Swift
//
//  Created by 朱继超 on 2024/3/5.
//

import Foundation

public enum EaseChatBusinessApi {
    case login(Void)
    case fetchGroupAvatar(String)
    case fetchRTCToken(String,String,String)
    case mirrorCallUserIdToChatUserId(String,String)
}


