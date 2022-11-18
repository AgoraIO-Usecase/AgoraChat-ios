//
//  AgoraCDDeviceManager.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/28.
//

import UIKit

func AgoraSystemSoundFinishedPlayingCallback(soundId: SystemSoundID, user_data: UnsafeMutableRawPointer?)
{
    AudioServicesDisposeSystemSoundID(soundId)
}

class AgoraCDDeviceManager: NSObject {
    @discardableResult class func playNewMessageSound() -> SystemSoundID? {
        let path = "/System/Library/Audio/UISounds/sms-received1.caf"
        guard let url = URL(string: path) else {
            return nil
        }
        var soundId: SystemSoundID = 0
        let soundIdPtr = withUnsafePointer(to: &soundId) { UnsafeMutablePointer(mutating: $0)}

        AudioServicesCreateSystemSoundID(url as CFURL, soundIdPtr)
        AudioServicesAddSystemSoundCompletion(soundId, nil, nil, AgoraSystemSoundFinishedPlayingCallback, nil)
        AudioServicesPlaySystemSound(soundId)
        return soundId
    }
    
    class func playVibration() {
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, nil, nil, AgoraSystemSoundFinishedPlayingCallback, nil)
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
}
