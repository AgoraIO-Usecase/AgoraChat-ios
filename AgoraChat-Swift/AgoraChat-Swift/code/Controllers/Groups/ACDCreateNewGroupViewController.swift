//
//  ACDCreateNewGroupViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/20.
//

import UIKit
import AgoraChat

class ACDCreateNewGroupViewController: UIViewController {

    private let createBtn = UIButton(type: .custom)
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descTextView: UITextView!
    @IBOutlet weak var descPlaceholderLabel: UILabel!
    @IBOutlet weak var textCountLabel: UILabel!
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var authLabel: UILabel!
    @IBOutlet weak var publicSwitch: UISwitch!
    @IBOutlet weak var authSwitch: UISwitch!
    private var groupOptions = AgoraChatGroupOptions()
    private var invitees: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "New Group".localized
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "gray_goBack"), style: .plain, target: self, action: #selector(backAction))
        
        self.createBtn.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        self.createBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.createBtn.setTitleColor(Color_999999, for: .disabled)
        self.createBtn.setTitleColor(Color_154DFE, for: .normal)
        self.createBtn.setTitle("Next".localized, for: .normal)
        self.createBtn.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightSpace.width = -2
        self.navigationItem.rightBarButtonItems = [rightSpace, UIBarButtonItem(customView: self.createBtn)]
        self.createBtn.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChangeNotification), name: UITextField.textDidChangeNotification, object: self.nameTextField)
    }
    
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func nextButtonAction() {
        if let text = self.nameTextField.text, text.count == 0 {
            self.showHint(String(format: "%@ can't be null".localized, "Group Name".localized))
            return
        }
        if let text = self.countTextField.text, text.count > 0 {
            let max = Int(text) ?? 0
            if max < 3 || max > 3000 {
                self.showHint("Member quantity: 3 to 2000".localized)
                self.groupOptions.maxUsers = 200
                return
            }
            self.groupOptions.maxUsers = max
        }
        
        let vc = AgoraMemberSelectViewController(invitees: [], maxInviteCount: self.groupOptions.maxUsers)
        vc.style = .add
        vc.title = "Add Members".localized
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc @IBAction private func permissionSelectAction(_ sender: UISwitch) {
        if sender == self.publicSwitch {
            if sender.isOn {
                self.authLabel.text = "Authorized to join".localized
            } else {
                self.authLabel.text = "Allow members to invite".localized
            }
        }
    }
    
    @objc private func textDidChangeNotification() {
        self.createBtn.isEnabled = (self.nameTextField.text?.count ?? 0) > 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ACDCreateNewGroupViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.countTextField {
            if let text = textField.text, let max = Int(text) {
                self.groupOptions.maxUsers = max
            }
        }
    }
}

extension ACDCreateNewGroupViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.count
        self.descPlaceholderLabel.isHidden = count > 0
        if textView.markedTextRange == nil {
            if count > 500 {
                textView.text = textView.text?.subsring(to: 500)
            }
            self.textCountLabel.text = "\(count)/500"
        }
    }
}

extension ACDCreateNewGroupViewController: AgoraGroupUIProtocol {
    func addSelectOccupants(_ modelArray: [AgoraUserModel]) {
        for model in modelArray where !self.invitees.contains(model.hyphenateId) {
            self.invitees.append(model.hyphenateId)
        }
        if self.publicSwitch.isOn {
            self.groupOptions.style = self.authSwitch.isOn ? .publicJoinNeedApproval : .publicOpenJoin
        } else {
            self.groupOptions.style = self.authSwitch.isOn ? .privateMemberCanInvite : .privateOnlyOwnerInvite
        }
        
        guard let groupName = self.nameTextField.text else {
            return
        }
        let groupDesc = self.descTextView.text
        let message = String(format: "%@ invite you to join the group [%@]".localized, AgoraChatClient.shared().currentUsername!, groupName)
        AgoraChatClient.shared().groupManager?.createGroup(withSubject: groupName, description: groupDesc, invitees: self.invitees, message: message, setting: self.groupOptions, completion: { group, error in
            if error != nil {
                self.showAlert(message: "Operation failed".localized)
            } else if let group = group {
                NotificationCenter.default.post(name: GroupListChangedNotification, object: nil)
                NotificationCenter.default.post(name: GroupCreatedNotification, object: nil, userInfo: [
                    "group": group,
                    "invitees": self.invitees
                ])
                self.navigationController?.dismiss(animated: true)
            }
        })
    }
}
