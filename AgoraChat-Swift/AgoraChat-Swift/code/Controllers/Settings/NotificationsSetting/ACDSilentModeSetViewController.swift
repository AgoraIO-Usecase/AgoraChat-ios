//
//  ACDSilentModeSetViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/18.
//

import UIKit
import AgoraChat

class ACDSilentModeSetViewController: UITableViewController {
    
    private let conversationID: String?
    private let notificationType: AgoraNotificationSettingType
    private let doneBlock: (_ item: AgoraChatSilentModeResult) -> Void
    
    private var selecIndex: Int?
    private let dataArray = ["15 \("Minutes".localized)", "1 \("Hour".localized)", "8 \("Hours".localized)", "24 \("Hours".localized)", "Until 8:00 AM Tomorow".localized]
    
    init(conversationID: String?, notificationType: AgoraNotificationSettingType, doneBlock: @escaping (_ item:  AgoraChatSilentModeResult) -> Void) {
        self.conversationID = conversationID
        self.notificationType = notificationType
        self.doneBlock = doneBlock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavBar()
        self.tableView.register(UINib(nibName: "ACDSilentModeSetCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.tableView.separatorStyle = .none
        self.tableView.keyboardDismissMode = .onDrag
        self.tableView.backgroundColor = .white
        self.tableView.rowHeight = 54.0
    }
    
    private func setupNavBar() {
        let navTitle: String
        switch self.notificationType {
        case .me:
            navTitle = "Notifications".localized
        case .singleChat:
            navTitle = "Contact Notifications".localized
        case .group:
            navTitle = "Group Notifications".localized
        case .thread:
            navTitle = "Thread Notifications".localized
        default:
            navTitle = ""
        }
        
        self.navigationItem.leftBarButtonItem = ACDUtil.customLeftButtonItem(title: navTitle, action: #selector(backAction), target: self)
        
        let doneButton = UIButton(type: .custom)
        doneButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        doneButton.setTitle("Done".localized, for: .normal)
        doneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        doneButton.setTitleColor(Color_154DFE, for: .normal)
        doneButton.addTarget(self, action: #selector(selectDoneAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
    }
    
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func selectDoneAction() {
        guard let selecIndex = selecIndex else {
            self.showHint("You haven't made a choice yet!".localized)
            return
        }
        let last = self.distanceToTomorowEightAM()
        let list = [12, 60, 8 * 60, 24 * 60, last]
        let durationMinutes = list[selecIndex]
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let param = AgoraChatSilentModeParam(paramType: .duration)
        param.silentModeDuration = Int32(durationMinutes)
        if self.notificationType == .me {
            AgoraChatClient.shared().pushManager?.setSilentModeForAll(param, completion: { result, error in
                MBProgressHUD.hide(for: self.view, animated: true)
                if let error = error {
                    self.showHint(error.errorDescription)
                } else if let result = result {
                    self.doneBlock(result)
                    self.backAction()
                }
            })
        } else if let conversationID = self.conversationID {
            let type: AgoraChatConversationType = self.notificationType == .singleChat ? .chat : .groupChat
            AgoraChatClient.shared().pushManager?.setSilentModeForConversation(conversationID, conversationType: type, params: param, completion: { result, error in
                MBProgressHUD.hide(for: self.view, animated: true)
                if let error = error {
                    self.showHint(error.errorDescription)
                } else if let result = result {
                    self.doneBlock(result)
                    self.backAction()
                }
            })
        }
    }
    
    private func distanceToTomorowEightAM() -> Int {
        let dateComponents = Calendar.current.dateComponents(in: .current, from: Date())
        if let hour = dateComponents.hour, let minute = dateComponents.minute {
            return (23 - hour + 8) * 60 + 60 - minute
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDSilentModeSetCell {
            cell.title = self.dataArray[indexPath.row]
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selecIndex = indexPath.row
    }
}
