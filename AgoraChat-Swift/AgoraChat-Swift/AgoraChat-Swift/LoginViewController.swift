//
//  ViewController.swift
//  AgoraChat-Swift
//
//  Created by 朱继超 on 2024/6/26.
//

import UIKit
import chat_uikit
import SwiftFFDBHotFix
import AgoraChatCallKit

let loginSuccessfulSwitchMainPage = "loginSuccessfulSwitchMainPage"
let backLoginPage = "backLoginPage"

final class LoginViewController: UIViewController {
    
    private let regular = "^((1[1-9][0-9])|(14[5|7])|(15([0-3]|[5-9]))|(17[013678])|(18[0,5-9]))d{8}$"
    
    private var code = ""
    
    @UserDefault("EaseChatDemoUserId", defaultValue: "") var userName
    
    @UserDefault("EaseChatDemoUserPassword", defaultValue: "") var password
            
    private lazy var background: UIImageView = {
        UIImageView(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: ScreenHeight)).contentMode(.scaleAspectFill)
    }()
    
    private lazy var appName: UILabel = {
        UILabel(frame: CGRect(x: 30, y: 187, width: ScreenWidth - 60, height: 35)).font(UIFont(name: "PingFangSC-Medium", size: 24)).text("Login".localized())
    }()
    
    lazy var sdkVersion: UILabel = {
        UILabel(frame: CGRect(x: self.view.frame.width-73.5, y: self.appName.frame.minY+8, width: 43, height: 18)).cornerRadius(Appearance.avatarRadius).font(UIFont.theme.bodyExtraSmall).textColor(UIColor.theme.neutralColor98).textAlignment(.center)
    }()
    
    private lazy var userNameField: UITextField = {
        UITextField(frame: CGRect(x: 30, y: self.appName.frame.maxY+22, width: ScreenWidth-60, height: 48)).delegate(self).tag(11).font(UIFont.theme.bodyLarge).placeholder("Username").leftView(UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 48)), .always).cornerRadius(Appearance.avatarRadius).clearButtonMode(.whileEditing)
    }()
    
    private lazy var passwordField: UITextField = {
        UITextField(frame: CGRect(x: 30, y: self.userNameField.frame.maxY+24, width: ScreenWidth-60, height: 48)).delegate(self).tag(12).font(UIFont.theme.bodyLarge).placeholder("Password").leftView(UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 48)), .always).cornerRadius(Appearance.avatarRadius).rightView(UIView {
            UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 48))
            self.right
        }, .always)
    }()
    
    private lazy var login: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 30, y: self.passwordField.frame.maxY+24, width: ScreenWidth - 60, height: 48)).cornerRadius(Appearance.avatarRadius).title("Login".localized(), .normal).textColor(.white, .normal).font(.systemFont(ofSize: 16, weight: .semibold)).addTargetFor(self, action: #selector(loginAction), for: .touchUpInside)
    }()
    
    private lazy var loginContainer: UIView = {
        UIView(frame: CGRect(x: 30, y: self.passwordField.frame.maxY+24, width: ScreenWidth - 60, height: 48)).backgroundColor(.white)
    }()
    
    private lazy var protocolContainer: UILabel = {
        UILabel(frame: CGRect(x: 74, y: self.login.frame.maxY+10, width: ScreenWidth-148, height: 58)).attributedText(self.protocolContent).backgroundColor(.clear).numberOfLines(0).textAlignment(.center)
    }()
    
    private lazy var right: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 0, y: 13, width: 22, height: 22)).image(UIImage(named: "eye_slash_fill"), .normal).image(UIImage(named: "eye_fill"), .selected).addTargetFor(self, action: #selector(showPassword), for: .touchUpInside).font(.systemFont(ofSize: 14, weight: .medium)).backgroundColor(.clear)
    }()
    
        
    private var protocolContent: NSAttributedString = NSAttributedString {
        ImageAttachment(UIImage(named: "login_alert"), bounds: CGRect(x: 0, y: -5, width: 16, height: 16))
        AttributedText(" "+"Login Alert".localized()).font(.systemFont(ofSize: 12, weight: .regular)).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor8:UIColor.theme.neutralColor3).lineSpacing(5)
    }
    
    public private(set) lazy var loadingView: LoadingView = {
        LoadingView(frame: self.view.bounds)
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.window?.backgroundColor = .white
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.background,self.appName,self.sdkVersion,self.userNameField,self.passwordField,self.loginContainer,self.login,self.protocolContainer,self.loadingView])
        self.loadingView.isHidden = true
        self.sdkVersion.text = "V\(ChatClient.shared().version)"
        self.setContainerShadow()
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    private func setContainerShadow() {
        self.loginContainer.layer.cornerRadius = CGFloat(Appearance.avatarRadius.rawValue)
        self.loginContainer.layer.shadowRadius = 8
        self.loginContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.loginContainer.layer.shadowColor = UIColor(red: 0, green: 0.55, blue: 0.98, alpha: 0.2).cgColor
        self.loginContainer.layer.shadowOpacity = 1
    }

}

extension LoginViewController: UITextFieldDelegate {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        
    }
    
    @objc private func loginAction() {
        self.view.endEditing(true)
        self.loginRequest()
    }
    
    @objc private func loginRequest() {
        guard let phone = self.userNameField.text,!phone.isEmpty else {
            self.showToast(toast: "PhoneError".localized())
            return
        }
        guard let code = self.passwordField.text,!code.isEmpty else {
            self.showToast(toast: "PinCodeError".localized())
            return
        }
        self.userName = phone
        self.password = code
        self.loadingView.startAnimating()
        EaseChatBusinessRequest.shared.sendPOSTRequest(api: .login(()), params: ["userAccount":phone,"userPassword":code]) { [weak self] result, error in
            if error == nil {
                if let userId = result?["chatUserName"] as? String,let token = result?["accessToken"] as? String {
                    let user = EaseChatProfile()
                    if let agoraUserId = result?["agoraUid"] as? String {
                        AgoraChatCallManager.shared().getAgoraChatCallConfig().agoraUid = UInt(agoraUserId) ?? 0
                    }
                    user.id = userId
                    user.avatarURL = (result?["avatarUrl"] as? String) ?? ""
                    self?.login(user: user, token: token)
                    user.insert()
                }
            } else {
                self?.loadingView.stopAnimating()
                self?.showToast(toast: "PhoneError".localized())
            }
        }
    }
    
    private func login(user: EaseProfileProtocol,token: String) {
        if let dbPath = FMDBConnection.databasePath,dbPath.isEmpty {
            FMDBConnection.databasePath = String.documentsPath+"/EaseChatDemo/"+"\(AppKey)/"+user.id+".db"
        }
        self.loadCache()
        EaseChatUIKitClient.shared.login(user: user, token: token) { [weak self] error in
            if error == nil {
                self?.loadingView.stopAnimating()
                if let profiles = EaseChatProfile.select(where: "id = '\(user.id)'") as? [EaseChatProfile] {
                    if profiles.first != nil {
                        if let profile = profiles.first {
                            (user as? EaseChatProfile)?.update()
                            EaseChatUIKitContext.shared?.currentUser = profiles.first
                            EaseChatUIKitContext.shared?.userCache?[profile.id] = profile
                        }
                    }
                } else {
                    EaseChatUIKitContext.shared?.currentUser = user
                    EaseChatUIKitContext.shared?.userCache?[user.id] = user
                }
                self?.fillCache()
                self?.entryHome()
            } else {
                self?.showToast(toast: error?.errorDescription ?? "")
            }
        }
    }
    
    private func loadCache() {
        if let profiles = EaseChatProfile.select(where: nil) as? [EaseChatProfile] {
            for profile in profiles {
                if let conversation = ChatClient.shared().chatManager?.getConversationWithConvId(profile.id) {
                    if conversation.type == .chat {
                        EaseChatUIKitContext.shared?.userCache?[profile.id] = profile
                    }
                }
                if profile.id == ChatClient.shared().currentUsername ?? "" {
                    EaseChatUIKitContext.shared?.currentUser = profile
                    EaseChatUIKitContext.shared?.userCache?[profile.id] = profile
                }
            }
        }
        
    }
    
    private func fillCache() {

        if let groups = ChatClient.shared().groupManager?.getJoinedGroups() {
            var profiles = [EaseChatProfile]()
            for group in groups {
                let profile = EaseChatProfile()
                profile.id = group.groupId
                profile.nickname = group.groupName
                profile.avatarURL = group.settings.ext
                profiles.append(profile)
            }
            EaseChatUIKitContext.shared?.updateCaches(type: .group, profiles: profiles)
        }
        if let users = EaseChatUIKitContext.shared?.userCache {
            for user in users.values {
                EaseChatUIKitContext.shared?.userCache?[user.id]?.remark = ChatClient.shared().contactManager?.getContact(user.id)?.remark ?? ""
            }
        }
    }
    
    
    @objc private func showPassword() {
        self.right.isSelected = !self.right.isSelected
        self.passwordField.isSecureTextEntry = !self.right.isSelected
    }
    
    @objc private func agreeAction(sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func entryHome() {
        NotificationCenter.default.post(name: NSNotification.Name(loginSuccessfulSwitchMainPage), object: nil)
    }
    
}

extension LoginViewController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.background.image = style == .dark ? UIImage(named: "login_bg_dark") : UIImage(named: "login_bg")
        self.appName.textColor = style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
        self.sdkVersion.backgroundColor = style == .dark ? UIColor.theme.barrageDarkColor2:UIColor.theme.barrageLightColor2
        self.userNameField.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.passwordField.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.userNameField.textColor = style == .dark ? UIColor.theme.neutralColor98 : UIColor.theme.neutralColor1
        self.passwordField.textColor =  style == .dark ? UIColor.theme.neutralColor98 : UIColor.theme.neutralColor1
        if style == .dark {
            self.login.setGradient([UIColor(red: 0.2, green: 0.696, blue: 1, alpha: 1),UIColor(red: 0.4, green: 0.47, blue: 1, alpha: 1)],[ CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 1)])
        } else {
            self.login.setGradient([UIColor(red: 0, green: 0.62, blue: 1, alpha: 1),UIColor(red: 0.2, green: 0.293, blue: 1, alpha: 1)], [ CGPoint(x: 0, y: 0),CGPoint(x: 0, y: 1)])
        }
    }
}


extension String {
    public func localized() -> String {
        return DemoLanguage.localValue(key: self)
    }
}

extension UIView {
    
    @discardableResult
    func setGradient(_ colors: [UIColor],_ points: [CGPoint]) -> Self {
        let gradientColors: [CGColor] = colors.map { $0.cgColor }
        let startPoint = points[0]
        let endPoint = points[1]
        let gradientLayer: CAGradientLayer = CAGradientLayer().colors(gradientColors).startPoint(startPoint).endPoint(endPoint).frame(self.bounds).backgroundColor(UIColor.clear.cgColor)
        self.layer.insertSublayer(gradientLayer, at: 0)
        return self
    }
    
}

final class EaseChatProfile:NSObject, EaseProfileProtocol, FFObject {
    
    static func ignoreProperties() -> [String]? {
        ["selected"]
    }
    
    static func customColumnsType() -> [String : String]? {
        nil
    }
    
    static func customColumns() -> [String : String]? {
        nil
    }
    
    static func primaryKeyColumn() -> String {
        "primaryId"
    }
    
    var primaryId: Int = 0

    var id: String = ""
    
    var remark: String = ""
    
    var selected: Bool = false
    
    var nickname: String = ""
    
    var avatarURL: String = ""
    
    public func toJsonObject() -> Dictionary<String, Any>? {
        ["ease_chat_uikit_user_info":["nickname":self.nickname,"avatarURL":self.avatarURL,"userId":self.id,"remark":""]]
    }
    
    override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case remark
        case nickname
        case avatarURL
        case selected
    }
    
    override init() {
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        remark = try container.decode(String.self, forKey: .remark)
        nickname = try container.decode(String.self, forKey: .nickname)
        avatarURL = try container.decode(String.self, forKey: .avatarURL)
        selected = try container.decodeIfPresent(Bool.self, forKey: .selected) ?? false
    }
    
}

