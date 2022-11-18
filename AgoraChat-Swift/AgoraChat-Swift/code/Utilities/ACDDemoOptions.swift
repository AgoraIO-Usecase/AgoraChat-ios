//
//  ACDDemoOptions.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/25.
//

import UIKit

private let Appkey = "41117440#383391"

@objcMembers
class ACDDemoOptions: NSObject, NSCoding, NSSecureCoding {

    private static var _shared: ACDDemoOptions!
    
    class var shared: ACDDemoOptions {
        get {
            if self._shared == nil {
                let fileName = "emdemo_options.data"
                if let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first {
                    let file = path + "/" + fileName
                    let url = URL(fileURLWithPath: file)
                    if let data = try? Data(contentsOf: url) {
                        do {
                            if let model = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [ACDDemoOptions.self], from: data) as? ACDDemoOptions {
                                self._shared = model
                                return model
                            }
                        } catch {
                            print(error)
                        }
                    }
                }
                let model = ACDDemoOptions()
                model.archive()
                self._shared = model
                return model
            }
            return self._shared
        }
    }
    
    var appkey: String?
    var apnsCertName: String?
    var usingHttpsOnly: Bool = false
    var specifyServer: Bool = false
    var chatPort: Int32 = 0
    var chatServer: String?
    var restServer: String?
    var isAutoAcceptGroupInvitation = true
    var deleteMessagesOnLeaveGroup = true
    var isAutoTransferMessageAttachments = true
    var isAutoDownloadThumbnail = true
    var isSortMessageByServerTime = true
    var isPriorityGetMsgFromServer = false
    var isAutoLogin = true
    var loggedInUsername: String?
    var loggedInPassword: String?
    var isChatTyping = false
    var isAutoDeliveryAck = false
    var isOfflineHangup = false
    var isShowCallInfo = true
    var isUseBackCamera = false
    var isReceiveNewMsgNotice = true
    var willRecord = false
    var willMergeStrem = false
    var enableConsoleLog = true
    var enableCustomAudioData = false
    var customAudioDataSamples = 48000
    var isSupportWechatMiniProgram = false
    var isCustomServer = false
    var isFirstLaunch = false
    var locationAppkeyArray: [String]?
    var language: String?
    var playVibration = true
    var playNewMsgSound = true
    
    private override init() {
        super.init()
        self.initServerOptions()
    }
    
    required init?(coder: NSCoder) {
        super.init()
        self.mj_decode(coder)
        if self.locationAppkeyArray?.count ?? 0 <= 0 {
            self.locationAppkeyArray = [Appkey]
        }
        if self.appkey?.count ?? 0 <= 0 {
            self.appkey = self.locationAppkeyArray?.first
        }
    }
    
    func encode(with coder: NSCoder) {
        self.mj_encode(coder)
    }
    
    static var supportsSecureCoding: Bool {
        return true
    }
    
    private func initServerOptions() {
        self.appkey = Appkey
        #if DEBUG
        self.apnsCertName = "ChatDemoDevPush"
        #else
        self.apnsCertName = "ChatDemoProPush"
        #endif
        #if TFRELEASE
        self.apnsCertName = "ChatDemoPro"
        #endif
        self.usingHttpsOnly = true
        //self.specifyServer = YES;
        self.specifyServer = false

        self.isAutoLogin = true
    }
    
    func archive() {
        let fileName = "emdemo_options.data"
        if let path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first {
            let file = path + "/" + fileName
            NSKeyedArchiver.archiveRootObject(self, toFile: file)
        }
    }
    
    func toOptions() -> AgoraChatOptions {
        let opt = AgoraChatOptions(appkey: self.appkey ?? "")
        opt.apnsCertName = self.apnsCertName
        opt.usingHttpsOnly = self.usingHttpsOnly

        //self.specifyServer = YES;
        if self.specifyServer {
            opt.enableDnsConfig = false
            opt.chatPort = self.chatPort
            opt.chatServer = self.chatServer
            opt.restServer = self.restServer
        }
        
        self.isAutoLogin = true
        opt.isAutoLogin = self.isAutoLogin
        opt.autoAcceptGroupInvitation = self.isAutoAcceptGroupInvitation
        opt.deleteMessagesOnLeaveGroup = self.deleteMessagesOnLeaveGroup
        opt.isAutoTransferMessageAttachments = self.isAutoTransferMessageAttachments
        opt.autoDownloadThumbnail = self.isAutoDownloadThumbnail
        opt.sortMessageByServerTime = self.isSortMessageByServerTime
        #if DEBUG
        opt.apnsCertName = "ChatDemoDevPush"
        opt.pushKitCertName = "com.easemob.enterprise.demo.ui.voip"
        #else
        opt.apnsCertName = "ChatDemoProPush"
        opt.pushKitCertName = "com.easemob.enterprise.demo.ui.pro.voip"
        #endif
        #if TFRELEASE
        opt.apnsCertName = "ChatDemoPro"
        opt.pushKitCertName = "io.agora.chat.demo.pro.voip"
        #endif
        opt.enableDeliveryAck = self.isAutoDeliveryAck
        opt.enableConsoleLog = true
        opt.enableFpa = true
        return opt
    }
}
