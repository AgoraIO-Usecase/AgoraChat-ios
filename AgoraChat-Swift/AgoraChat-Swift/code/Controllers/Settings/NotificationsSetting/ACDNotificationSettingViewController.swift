//
//  ACDNotificationSettingViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/18.
//

import UIKit
import SnapKit

@objc enum AgoraNotificationSettingType: Int32 {
    case me
    case singleChat
    case group
    case thread
}

@objcMembers
class ACDNotificationSettingViewController: UITableViewController {
 
    private var silentModeItem: AgoraChatSilentModeResult?
    private let muteCell: ACDSubDetailCell = Bundle.main.loadNibNamed("ACDSubDetailCell", owner: nil)?.first as! ACDSubDetailCell
    private let remindTypeCell: ACDSubDetailCell = Bundle.main.loadNibNamed("ACDSubDetailCell", owner: nil)?.first as! ACDSubDetailCell
    private lazy var showPreTextCell: ACDNameSwitchCell = {
        let cell = ACDNameSwitchCell(style: .default, reuseIdentifier: nil)
        cell.title = "Show Preview Text".localized
        cell.switchActionHandle = { [unowned self] isOn in
            self.showPreTextAction()
        }
        return cell
    }()
    private lazy var soundCell: ACDNameSwitchCell = {
        let cell = ACDNameSwitchCell(style: .default, reuseIdentifier: nil)
        cell.title = "Alert Sound".localized
        cell.switchActionHandle = { isOn in
            ACDDemoOptions.shared.playNewMsgSound = isOn
        }
        return cell
    }()
    private lazy var vibrateCell: ACDNameSwitchCell = {
        let cell = ACDNameSwitchCell(style: .default, reuseIdentifier: nil)
        cell.title = "Vibrate".localized
        cell.switchActionHandle = { isOn in
            ACDDemoOptions.shared.playVibration = isOn
        }
        return cell
    }()
    
    var conversationID: String?
    var notificationType: AgoraNotificationSettingType = .me
    private var dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        
        var title: String
        var muteCellNameTitle: String
        var remindCellNameTitle: String
        switch self.notificationType {
        case .singleChat:
            title = "Contact Notifications".localized
            muteCellNameTitle = "Mute this Contact".localized
            remindCellNameTitle = "Notification Setting".localized
        case .group:
            title = "Group Notifications".localized
            muteCellNameTitle = "Mute this Group".localized
            remindCellNameTitle = "Frequency".localized
        case .thread:
            title = "Thread Notifications".localized
            muteCellNameTitle = "Mute this Thread".localized
            remindCellNameTitle = "Frequency".localized
        default:
            title = "Notifications".localized
            muteCellNameTitle = "Do Not Disturb".localized
            remindCellNameTitle = "Notification Setting".localized
        }
        
        self.navigationItem.leftBarButtonItem = ACDUtil.customLeftButtonItem(title: title, action: #selector(backAction), target: self)
        
        self.tableView.separatorStyle = .none
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.backgroundColor = .white
        self.tableView.rowHeight = 54.0
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0.0
        }
        
        self.muteCell.nameLabel.text = muteCellNameTitle
        self.muteCell.accessoryType = .disclosureIndicator
        self.muteCell.tapCellHandle = { [unowned self] in
            self.muteAction()
        }
        
        self.remindTypeCell.nameLabel.text = remindCellNameTitle
        self.remindTypeCell.accessoryType = .disclosureIndicator
        self.remindTypeCell.tapCellHandle = { [unowned self] in
            self.remindTypeAction()
        }
        
        self.dateFormatter.dateFormat = "MMM dd,yyyy, HH:mm".localized
        
        self.getDataFromSever()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func getDataFromSever() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        if self.notificationType == AgoraNotificationSettingType.me {
            AgoraChatClient.shared().pushManager?.getSilentModeForAll(completion: { result, error in
                MBProgressHUD.hide(for: self.view, animated: true)
                if let error = error {
                    self.showHint(error.errorDescription)
                } else {
                    self.silentModeItem = result
                    self.tableView.reloadData()
                }
            })
        } else if let conversationID = self.conversationID {
            let chatType: AgoraChatConversationType = self.notificationType == .singleChat ? .chat : .groupChat
            AgoraChatClient.shared().pushManager?.getSilentMode(forConversation: conversationID, conversationType: chatType, completion: { result, error in
                MBProgressHUD.hide(for: self.view, animated: true)
                if let error = error {
                    self.showHint(error.errorDescription)
                } else {
                    self.silentModeItem = result
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func remindTypeDefault() {
        guard let conversationID = self.conversationID else {
            return
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let type: AgoraChatConversationType = self.notificationType == .singleChat ? .chat : .groupChat
        AgoraChatClient.shared().pushManager?.clearRemindType(forConversation: conversationID, conversationType: type, completion: { result, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error {
                self.showHint(error.errorDescription)
            } else {
                self.silentModeItem = result
                self.tableView.reloadData()
            }
        })
    }
    
    private func remindTypeChange(type: AgoraChatPushRemindType) {
        let param = AgoraChatSilentModeParam(paramType: .remindType)
        param.remindType = type
        self.silentModeChange(param: param)
    }
    
    private func silentModeChange(param: AgoraChatSilentModeParam) {
        if self.notificationType == .me {
            AgoraChatClient.shared().pushManager?.setSilentModeForAll(param, completion: { result, error in
                if let error = error {
                    self.showHint(error.errorDescription)
                } else {
                    self.silentModeItem = result
                    self.tableView.reloadData()
                }
            })
        } else if let conversationID = self.conversationID {
            let type: AgoraChatConversationType = self.notificationType == .singleChat ? .chat : .groupChat
            AgoraChatClient.shared().pushManager?.setSilentModeForConversation(conversationID, conversationType: type, params: param, completion: { result, error in
                if let error = error {
                    self.showHint(error.errorDescription)
                } else {
                    self.silentModeItem = result
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    private func remindTypeAction() {
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if self.notificationType != .me {
            let action = UIAlertAction(title: "Default".localized, style: .default) { _ in
                self.remindTypeDefault()
            }
            action.setValue(UIColor.black, forKey: "titleTextColor")
            vc.addAction(action)
        }
        let allAction = UIAlertAction(title: "All Messages".localized, style: .default) { _ in
            self.remindTypeChange(type: .all)
        }
        allAction.setValue(UIColor.black, forKey: "titleTextColor")
        vc.addAction(allAction)
        
        if self.notificationType != .singleChat {
            let action = UIAlertAction(title: "Only @Metions".localized, style: .default) { _ in
                self.remindTypeChange(type: .mentionOnly)
            }
            action.setValue(UIColor.black, forKey: "titleTextColor")
            vc.addAction(action)
        }
        
        let noneAction = UIAlertAction(title: "Nothing".localized, style: .default) { _ in
            self.remindTypeChange(type: .none)
        }
        noneAction.setValue(UIColor.black, forKey: "titleTextColor")
        vc.addAction(noneAction)
            
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        
        self.present(vc, animated: true)
    }

    private func muteAction() {
        if let expireTimestamp = self.silentModeItem?.expireTimestamp, expireTimestamp > Date().timeIntervalSince1970 * 1000 {
            let mute = self.muteCell.subDetailLabel.text ?? ""
            var titleStr = "Turn off Do Not Disturb?".localized
            var infoStr = String(format: "You have set Do Not Disturb until \n %@".localized, mute)
            if self.notificationType != .me {
                if self.notificationType == .group {
                    titleStr = "Mute this Group".localized
                    infoStr = String(format: "You have muted this Group until \n %@".localized, mute)

                } else {
                    titleStr = "Mute this Thread".localized
                    infoStr = String(format: "You have muted this Thread until \n %@".localized, mute)
                }
            }
            let vc = UIAlertController(title: titleStr, message: infoStr, preferredStyle: .alert)
            vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
            vc.addAction(UIAlertAction(title: LocalizedString.Ok, style: .default) { _ in
                self.closeMute()
            })
            self.present(vc, animated: true)
        } else {
            let vc = ACDSilentModeSetViewController(conversationID: self.conversationID, notificationType: self.notificationType) { item in
                self.silentModeItem = item
                self.tableView.reloadData()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func closeMute() {
        let param = AgoraChatSilentModeParam(paramType: .duration)
        param.silentModeDuration = 0
        self.silentModeChange(param: param)
    }

    private func showPreTextAction() {
        let style: AgoraChatPushDisplayStyle = self.showPreTextCell.switch.isOn ? .messageSummary : .simpleBanner
        AgoraChatClient.shared().pushManager?.update(style) { error in
//            let error: AgoraChatError? = error
//            if let error = error {
//                self.showHint(error.errorDescription)
//            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.notificationType == .me ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.notificationType == .me) {
            if section == 0 {
                return 2
            }
            return 2
        } else if (self.notificationType == .singleChat) {
            return 2
        } else {
            return 2
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.notificationType == .me ? 30 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if (self.notificationType != .me) {
            return UIView()
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .gray
        label.textAlignment = .left
        label.text = section == 0 ? "Push Notifications".localized : "In-App Notifications".localized
        
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.centerY.equalTo(view)
            make.left.equalTo(16)
        }
        return view
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.changeMuteCell()
                return self.muteCell
            } else if indexPath.row == 1 {
                self.changeRemindCell()
                return self.remindTypeCell
            } else {
                self.showPreTextCell.isOn = AgoraChatClient.shared().pushManager?.pushOptions?.displayStyle == .messageSummary
                return self.showPreTextCell
            }
        } else {
            if indexPath.row == 0 {
                self.soundCell.isOn = ACDDemoOptions.shared.playNewMsgSound
                return self.soundCell
            } else {
                self.vibrateCell.isOn = ACDDemoOptions.shared.playVibration
                return self.vibrateCell
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return self.muteCell.height
        }
        return 54
    }
    
    private func changeMuteCell() {
        if let expireTimestamp = self.silentModeItem?.expireTimestamp, expireTimestamp > Date().timeIntervalSince1970 * 1000 {
            self.muteCell.detailLabel.text = self.notificationType == .me ? "Turn Off".localized : "Unmute".localized
            
            let date = Date(timeIntervalSince1970: expireTimestamp / 1000)
            self.muteCell.subDetailLabel.text = self.dateFormatter.string(from: date)
            self.muteCell.showSubDetailLabel = true
        } else {
            self.muteCell.detailLabel.text = self.notificationType == .me ? "Turn On".localized : "Mute".localized
            self.muteCell.subDetailLabel.text = ""
            self.muteCell.showSubDetailLabel = false
        }
    }
    
    private func changeRemindCell() {
        var typeStr: String
        switch self.silentModeItem?.remindType {
        case .all:
            typeStr = "All Messages".localized
        case .mentionOnly:
            typeStr = "Only @Metions".localized
        default:
            typeStr = "Nothing".localized
        }
        if self.notificationType != .me {
            if self.silentModeItem?.isConversationRemindTypeEnabled != true {
                typeStr = "Default".localized
            }
        }
        self.remindTypeCell.detailLabel.text = typeStr
    }
}
