//
//  ACDPresenceSettingViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/13.
//

import UIKit

class ACDPresenceSettingViewController: UITableViewController {

    private var customStateDesc: String?
    private var currentPresence = PresenceManager.State.online
    private let dataArray: [PresenceManager.State] = [.online, .busy, .doNotDisturb, .leave, .custom]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Presence Setting".localized
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized, style: .plain, target: self, action: #selector(completeAction))
        self.view.backgroundColor = Color_F9F9F9
        self.tableView.rowHeight = 50
        self.tableView.tableFooterView = UIView()

        let minePresence = PresenceManager.shared.presences[AgoraChatClient.shared().currentUsername!]
        self.currentPresence = PresenceManager.fetchStatus(presence: minePresence)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc private func completeAction() {
        let presence = PresenceManager.shared.presences[AgoraChatClient.shared().currentUsername!]
        if PresenceManager.fetchStatus(presence: presence) == .custom {
            var toStateDesc: String!
            if self.currentPresence != .custom {
                toStateDesc = PresenceManager.showStatusMap[self.currentPresence]
            } else {
                toStateDesc = self.customStateDesc
            }
            if toStateDesc?.count ?? 0 <= 0 {
                toStateDesc = PresenceManager.showStatusMap[.online]
            }
            let message = String(format: "Clear your '%@',change to \'%@\'".localized, presence!.statusDescription!, toStateDesc)
            
            let alertController = UIAlertController(title: "Change your Custom Status".localized, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel, handler: { _ in
                self.navigationController?.popViewController(animated: true)
            }))
            alertController.addAction(UIAlertAction(title: LocalizedString.Ok, style: .default, handler: { _ in
                PresenceManager.shared.publishPresence(description: toStateDesc, completion: nil)
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertController, animated: true)
        } else {
            if let toStateDesc = PresenceManager.showStatusMap[self.currentPresence] {
                PresenceManager.shared.publishPresence(description: toStateDesc, completion: nil)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func updateCustomStatus() {
        let alertController = UIAlertController(title: "Custom Status".localized, message: nil, preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Input custom status".localized
            textField.delegate = self
        }
        alertController.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        alertController.addAction(UIAlertAction(title: LocalizedString.Ok, style: .default, handler: { [unowned alertController] _ in
            if let text = alertController.textFields?.first?.text, text.count > 0 {
                self.customStateDesc = text
                self.currentPresence = .custom
                self.tableView.reloadData()
            }
        }))
        self.present(alertController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
            cell.selectionStyle = .none
        }
        if self.dataArray[indexPath.row] == self.currentPresence {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        if self.currentPresence == .custom {
            cell.textLabel?.text = self.customStateDesc
        } else {
            cell.textLabel?.text = PresenceManager.showStatusMap[self.dataArray[indexPath.row]]
        }
        if let imageName = PresenceManager.presenceImagesMap[self.dataArray[indexPath.row]] {
            cell.imageView?.image = UIImage(named: imageName)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.dataArray[indexPath.row] == .custom {
            self.updateCustomStatus()
        } else {
            self.currentPresence = self.dataArray[indexPath.row]
            self.tableView.reloadData()
        }
    }
}

extension ACDPresenceSettingViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = (textField.text as? NSString)?.replacingCharacters(in: range, with: string)
        return (str?.count ?? 0) <= 64
    }
}
