//
//  ACDGeneralViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/13.
//

import UIKit

class ACDGeneralViewController: UITableViewController {
    
    @IBOutlet weak var showTypingSwitch: UISwitch!
    @IBOutlet weak var autoAcceptGroupInviteSwitch: UISwitch!
    @IBOutlet weak var deleteChatSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = ACDUtil.customLeftButtonItem(title: "General".localized, action: #selector(back), target: self)
        
        self.showTypingSwitch.isOn = ACDDemoOptions.shared.isChatTyping
        self.autoAcceptGroupInviteSwitch.isOn = ACDDemoOptions.shared.isAutoAcceptGroupInvitation
        self.deleteChatSwitch.isOn = ACDDemoOptions.shared.deleteMessagesOnLeaveGroup
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc private func back() {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func switchValueChange(_ sender: UISwitch) {
        if sender == self.showTypingSwitch {
            ACDDemoOptions.shared.isChatTyping = sender.isOn
        } else if sender == self.autoAcceptGroupInviteSwitch {
            AgoraChatClient.shared.options.autoAcceptGroupInvitation = sender.isOn
            ACDDemoOptions.shared.isAutoAcceptGroupInvitation = sender.isOn
        } else if sender == self.deleteChatSwitch {
            AgoraChatClient.shared.options.deleteMessagesOnLeaveGroup = sender.isOn
            ACDDemoOptions.shared.deleteMessagesOnLeaveGroup = sender.isOn
        }
        ACDDemoOptions.shared.archive()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
