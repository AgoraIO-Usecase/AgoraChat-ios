//
//  AgoraLoginViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/10.
//

import UIKit
import AgoraChat

class AgoraLoginViewController: UIViewController {

    @IBOutlet weak var titleImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var operateTypeButton: UIButton!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var hintTitleLabel: UILabel!
    
    @IBOutlet weak var logoImageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var loginButtonTopContraint: NSLayoutConstraint!
    @IBOutlet weak var usernameTextFieldTopContraint: NSLayoutConstraint!
    
    let userIdRightView = EMRightViewToolView(type: .username)
    let pswdRightView = EMRightViewToolView(type: .password)
    let confirmPswdRightView = EMRightViewToolView(type: .password)
    
    var loadingAngle: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUsernameTextField()
        self.setupPasswordTextField()
        self.setupConfirmPasswordTextField()
        self.loginButtonTopContraint.constant = 20
        self.operateTypeButton.setAttributedTitle(self.attributeText(message: "No account? Register".localized, key: "Register".localized), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyBoardWillShow(_ notification: Notification) {
        // 获取用户信息
        let userInfo = notification.userInfo as? [String: Any]
        
        // 获取键盘高度
        let keyBoardHeight = (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
        var offset: CGFloat = 0
        if self.view.frame.size.height - keyBoardHeight <= self.loginButton.frame.maxY {
            offset = self.loginButton.frame.maxY - (self.view.frame.size.height - keyBoardHeight)
        } else {
            return
        }
        self.logoImageViewTopConstraint.constant = 134 - offset - 20
        if let animationTime = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.animate(withDuration: animationTime) {
                self.view.setNeedsLayout()
            }
        }
    }
    
    @objc private func keyBoardWillHide(_ notification: Notification) {
        self.logoImageViewTopConstraint.constant = 134
        let userInfo = notification.userInfo as? [String: Any]
        if let animationTime = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval {
            UIView.animate(withDuration: animationTime) {
                self.view.setNeedsLayout()
            }
        }
    }

    private func setupUsernameTextField() {
        self.usernameTextField.attributedPlaceholder = self.textFieldAttributeString(content: "AgoraID".localized)
        self.usernameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 0))
        self.usernameTextField.leftViewMode = .always
        self.usernameTextField.rightViewMode = .whileEditing
        self.userIdRightView.rightViewBtn.addTarget(self, action: #selector(clearUserIdAction), for: .touchUpInside)
        self.userIdRightView.isHidden = true
        self.usernameTextField.rightView = self.userIdRightView
    }
    
    private func setupPasswordTextField() {
        self.passwordTextField.attributedPlaceholder = self.textFieldAttributeString(content: "Password".localized)
        self.passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 0))
        self.passwordTextField.leftViewMode = .always
        self.passwordTextField.rightViewMode = .whileEditing
        self.pswdRightView.rightViewBtn.addTarget(self, action: #selector(pswdSecureAction(_:)), for: .touchUpInside)
        self.pswdRightView.isHidden = true
        self.passwordTextField.rightView = self.pswdRightView
    }
    
    private func setupConfirmPasswordTextField() {
        self.passwordConfirmTextField.attributedPlaceholder = self.textFieldAttributeString(content: "Password".localized)
        self.passwordConfirmTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 18, height: 0))
        self.passwordConfirmTextField.leftViewMode = .always
        self.passwordConfirmTextField.rightViewMode = .whileEditing
        self.confirmPswdRightView.rightViewBtn.addTarget(self, action: #selector(confirmPswdSecureAction(_:)), for: .touchUpInside)
        self.confirmPswdRightView.isHidden = true
        self.passwordConfirmTextField.rightView = self.confirmPswdRightView
        self.passwordConfirmTextField.isHidden = true
    }
    
    @objc private func clearUserIdAction() {
        self.usernameTextField.text = nil
        self.userIdRightView.isHidden = true
    }
    
    @objc private func pswdSecureAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
    }
    
    @objc private func confirmPswdSecureAction(_ button: UIButton) {
        button.isSelected = !button.isSelected
        self.passwordConfirmTextField.isSecureTextEntry = !self.passwordConfirmTextField.isSecureTextEntry
    }
    
    private func textFieldAttributeString(content: String) -> NSAttributedString {
        return NSAttributedString(string: content, attributes: [
            .foregroundColor: Color_999999,
            .font: UIFont(name: "PingFang SC", size: 14)!
        ])
    }
    
    private func attributeText(message: String, key: String) -> NSAttributedString {
        let attributeString = NSMutableAttributedString(string: message)
        attributeString.addAttributes([
            .font: UIFont.systemFont(ofSize: 16, weight: .medium),
            .foregroundColor: Color_999999
        ], range: NSRange(location: 0, length: message.count))
        if key.count > 0 {
            attributeString.addAttributes([
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: Color_114EFF
            ], range: (message as NSString).range(of: key))
        }
        return attributeString
    }
    
    @IBAction func changeOperate(_ sender: UIButton) {
        self.hintView.isHidden = true
        self.hintTitleLabel.text = nil
        if sender.tag == 0 {
            self.titleImageView.image = UIImage(named: "register_agoraChat")
            
            self.usernameTextFieldTopContraint.constant = 65
            
            self.passwordConfirmTextField.isHidden = false
            self.loginButtonTopContraint.constant = 88
            
            sender.tag = 1
            self.loginButton.setTitle("Set Up", for: .normal)
            self.operateTypeButton.setAttributedTitle(self.attributeText(message: "Back to Login".localized, key: "Back to Login".localized), for: .normal)
        } else {
            self.titleImageView.image = UIImage(named: "login_agoraChat")
            
            self.usernameTextFieldTopContraint.constant = 95
            
            self.passwordConfirmTextField.isHidden = true
            self.loginButtonTopContraint.constant = 20
            
            sender.tag = 0
            self.loginButton.setTitle("Log in".localized, for: .normal)
            self.operateTypeButton.setAttributedTitle(self.attributeText(message: "No account? Register".localized, key: "Register".localized), for: .normal)
        }
    }
    
    private func isEmpty() -> Bool {
        if let username = self.usernameTextField.text, let password = self.passwordTextField.text, username.count > 0, password.count > 0 {
            let regex = "^[A-Za-z0-9]+$"
            let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
            let result = predicate.evaluate(with: username)
            if result {
                return false
            } else {
                self.hintView.isHidden = false
                self.hintTitleLabel.text = "Latin letters and numbers only.".localized
                return true
            }
        } else {
            self.hintView.isHidden = false
            self.hintTitleLabel.text = "Please enter username and nickname.".localized
            return true
        }
    }
    
    private func startAnimation() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0
        animation.byValue = CGFloat.pi
        animation.toValue = CGFloat.pi * 2
        animation.repeatCount = Float.infinity
        animation.duration = 1.2
        self.loadingImageView.layer.add(animation, forKey: "rotation")
    }
    
    private func updateLoginStateWithStart(start: Bool) {
        if start {
            self.loginButton.setTitle(nil, for: .normal)
            self.loadingImageView.isHidden = false
            self.startAnimation()
        } else {
            if self.operateTypeButton.tag == 0 {
                self.loginButton.setTitle("Log in".localized, for: .normal)
            } else {
                self.loginButton.setTitle("Register".localized, for: .normal)
            }
            self.loadingImageView.isHidden = true
            self.loadingImageView.layer.removeAllAnimations()
        }
    }
    
    private func doRegister() {
        guard let username = self.usernameTextField.text, let password = self.passwordTextField.text, username.count > 0, password.count > 0 else {
            return
        }
        AgoraChatHttpRequest.shared.registerToApperServer(username: username.lowercased(), password: password) { statusCode, responseData in
            var alertStr: String?
            var isRegisterSuccess = false
            if let responseData = responseData, responseData.count > 0 {
                if let responsedict = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any] {
                    let result = responsedict["code"] as? String
                    if result == "RES_OK" {
                        isRegisterSuccess = true
                        alertStr = "Register success".localized
                    } else {
                        alertStr = "Register failed".localized
                    }
                }
            } else {
                alertStr = "Register failed".localized
            }
            self.updateLoginStateWithStart(start: false)
            if !isRegisterSuccess {
                self.hintView.isHidden = false
                self.hintTitleLabel.text = alertStr
            }
            
            let alertVc = UIAlertController(title: nil, message: alertStr, preferredStyle: .alert)
            alertVc.addAction(UIAlertAction(title: LocalizedString.Ok, style: .default))
            self.present(alertVc, animated: true)
        }
    }
    
    @IBAction private func doLogin() {
//        if self.isEmpty() {
//            return
//        }
        if self.operateTypeButton.tag == 1 {
            if self.passwordTextField.text != self.passwordConfirmTextField.text {
                self.hintView.isHidden = false
                self.hintTitleLabel.text = "Please enter the same password".localized
                return
            }
        }
        self.view.endEditing(true)
        self.updateLoginStateWithStart(start: true)
        self.hintView.isHidden = true
        self.hintTitleLabel.text = nil
        
        if self.operateTypeButton.tag == 1 {
            self.doRegister()
            return
        }
        
        let finishClosure: (String, String?, Int, AgoraChatError?) -> Void = { username, nickname, agoraUid, error in
            if let error = error {
                var errorDes = "Login failed".localized
                switch error.code {
                case .serverNotReachable:
                    errorDes = "Connect to the server failed!".localized
                case .networkUnavailable:
                    errorDes = "No network connection!".localized
                case .serverTimeout:
                    errorDes = "Connect to the server timed out!".localized
                case .userAlreadyExist:
                    errorDes = "Username is already taken".localized
                default:
                    break;
                }
                
                let alertVc = UIAlertController(title: nil, message: errorDes, preferredStyle: .alert)
                alertVc.addAction(UIAlertAction(title: LocalizedString.Ok, style: .default))
                self.present(alertVc, animated: true)
                
                self.hintView.isHidden = false
                self.hintTitleLabel.text = errorDes
                self.updateLoginStateWithStart(start: false)
                return
            }
            if let nickname = nickname {
                AgoraChatClient.shared().userInfoManager?.updateOwnUserInfo(nickname, with: .nickName, completion: { userInfo, error in
                    if let userInfo = userInfo {
                        DispatchQueue.main.async {
                            self.updateLoginStateWithStart(start: false)
                            UserInfoStore.shared.setUserInfo(userInfo, userId: username)
                            NotificationCenter.default.post(name: UserInfoDidChangeNotification, object: nil, userInfo: [
                                "userinfo_list": [userInfo]
                            ])
                        }
                    }
                })
                if error?.code == .userNotFound, let password = self.passwordTextField.text {
                    AgoraChatClient.shared().register(withUsername: username, password: password)
                }
            }
            
            let userDefaults = UserDefaults.standard
            userDefaults.set(username, forKey: "user_name")
            userDefaults.set(nickname, forKey: "nick_name")
            userDefaults.set(agoraUid, forKey: "user_agora_uid")
            userDefaults.set(self.passwordTextField.text, forKey: "user_pwd")
            userDefaults.synchronize()
            
            self.hintView.isHidden = true
            self.hintTitleLabel.text = nil
            AgoraChatCallKitManager.shared.update(agoraUid: UInt(agoraUid))
            self.updateLoginStateWithStart(start: false)
            
            NotificationCenter.default.post(name: LoginStateChangedNotification, object: true, userInfo: [
                "userName": username,
                "nickName": nickname ?? ""
            ])
        }
        
        guard let username = self.usernameTextField.text?.lowercased(), let password = self.passwordTextField.text else {
            return
        }
        AgoraChatHttpRequest.shared.loginToApperServer(username: username, password: password) { statusCode, responseData in
            DispatchQueue.main.async {
                var alertStr: String?
                if let responseData = responseData {
                    let responsedict = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any]
                    let token = responsedict?["accessToken"] as? String
                    let loginName = responsedict?["chatUserName"] as? String
                    let nickname = responsedict?["chatUserNickname"] as? String
                    var agoraUid = 0
                    if let v = responsedict?["agoraUid"] as? String {
                        agoraUid = Int(v) ?? 0
                    }
                    
                    if let token = token, token.count > 0, let loginName = loginName {
                        AgoraChatClient.shared().login(withUsername: loginName.lowercased(), agoraToken: token) { username, error in
                            DispatchQueue.main.async {
                                finishClosure(username, nickname, agoraUid, error)
                            }
                        }
                        return
                    } else {
                        alertStr = "Login analysis token failure".localized
                        finishClosure(username, nil, 0, AgoraChatError(description: alertStr, code: .general))
                    }
                } else {
                    alertStr = "Login failed".localized
                    finishClosure(username, nil, 0, AgoraChatError(description: alertStr, code: .general))
                }
                self.updateLoginStateWithStart(start: false)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AgoraLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.usernameTextField, let text = self.usernameTextField.text, text.count > 0 {
            self.userIdRightView.isHidden = true
        }
        if textField == self.passwordTextField, let text = self.passwordTextField.text, text.count > 0 {
            self.pswdRightView.isHidden = true
        }
        if textField == self.passwordConfirmTextField, let text = self.passwordConfirmTextField.text, text.count > 0 {
            self.confirmPswdRightView.isHidden = true
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            return false
        }
        
        if textField == self.usernameTextField {
            if let text = self.usernameTextField.text, text.count <= 1, string == "" {
                self.userIdRightView.isHidden = true
            } else {
                self.userIdRightView.isHidden = false
            }
        }
        if textField == self.passwordTextField, let text = textField.text {
            let updatedString = (text as NSString).replacingCharacters(in: range, with: string)
            textField.text = updatedString
            self.pswdRightView.isHidden = false
            if text.count <= 0, string == "" {
                self.pswdRightView.isHidden = true
                self.passwordTextField.isSecureTextEntry = true
                self.pswdRightView.rightViewBtn.isSelected = false
            }
            return false
        }
        if textField == self.passwordConfirmTextField, let text = textField.text {
            let updatedString = (text as NSString).replacingCharacters(in: range, with: string)
            textField.text = updatedString
            self.confirmPswdRightView.isHidden = false
            if text.count <= 0, string == "" {
                self.confirmPswdRightView.isHidden = true
                self.passwordConfirmTextField.isSecureTextEntry = true
                self.confirmPswdRightView.rightViewBtn.isSelected = false
            }
            return false
        }
        return true
    }
}
