//
//  ACDBlockListViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/18.
//

import UIKit
import SnapKit

class ACDBlockListViewController: ACDContainerSearchTableViewController<[AgoraUserModel]> {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItem = ACDUtil.customLeftButtonItem(title: "Blocked List".localized, action: #selector(back), target: self)
        
        self.table.separatorStyle = .none
        self.table.keyboardDismissMode = .onDrag
        self.table.clipsToBounds = true
        self.table.rowHeight = 54.0
        self.table.sectionIndexColor = Color_353535
        self.table.sectionIndexBackgroundColor = .clear
        self.table.register(UINib(nibName: "ACDContactCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.searchBar.snp.remakeConstraints { make in
            make.top.equalTo(self.navigationController?.navigationBar.frame.maxY ?? 0)
            make.left.right.equalTo(self.view)
        }
        
        self.useRefresh()
        self.tableDidTriggerHeaderRefresh()
    }
    
    @objc private func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func updateContacts(bubbyList: [String]) {
        self.sortAndReloadContacts(bubbyList)
    }
    
    override func didStartRefresh() {
        self.tableDidTriggerHeaderRefresh()
    }
    
    private func loadBlockContactsFromServer() {
        self.tableDidTriggerHeaderRefresh()
    }
    
    private func reloadBlockContacts() {
        if let list = AgoraChatClient.shared().contactManager?.getBlackList() {
            self.updateContacts(bubbyList: list)
        }
    }
    
    private func viewDidAppearForIndex(_ index: Int) {
        self.reloadBlockContacts()
    }
    
    private func tableDidTriggerHeaderRefresh() {
        if self.isSearchState {
            self.endRefresh()
            return
        }
        AgoraChatClient.shared().contactManager?.getBlackListFromServer(completion: { list, error in
            if let list = list {
                self.updateContacts(bubbyList: list)
            }
            self.endRefresh()
        })
    }

    private func tapAction(userId: String) {
        let vc = UIAlertController(title: userId, message: nil, preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "Unblock".localized, iconImage: UIImage(named: "blocked"), textColor: .black, alignment: .left, completion: { _ in
            self.unBlockAction(userId: userId)
        }))
        vc.addAction(UIAlertAction(title: "Delete Contact".localized, iconImage: UIImage(named: "remove"), textColor: Color_FF14CC, alignment: .left, completion: { _ in
            self.deleteAction(userId: userId)
        }))
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        self.present(vc, animated: true)
    }
    
    private func unBlockAction(userId: String) {
        AgoraChatClient.shared().contactManager?.removeUser(fromBlackList: userId, completion: { username, error in
            if error == nil {
                self.tableDidTriggerHeaderRefresh()
                NotificationCenter.default.post(name: ContactsUpdatedNotification, object: nil)
            } else {
                self.showAlert(message: "Operation failed".localized)
            }
        })
    }
    
    private func deleteAction(userId: String) {
        let vc = UIAlertController(title: "Delete this contact now?".localized, message: "Delete this contact and associated Chats.".localized, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        let deleteAction = UIAlertAction(title: "Delete".localized, style: .default, handler: { _ in
            self.deleteContact(userId: userId)
        })
        deleteAction.setValue(Color_FF14CC, forKey: "titleTextColor")
        vc.addAction(deleteAction)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
    
    private func deleteContact(userId: String) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().contactManager?.deleteContact(userId, isDeleteConversation: true, completion: { username, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if error == nil {
                self.tableDidTriggerHeaderRefresh()
                NotificationCenter.default.post(name: ContactsUpdatedNotification, object: nil)
            } else {
                self.showAlert(message: "Operation failed".localized)
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.isSearchState ? 1 : self.sectionTitles.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitles
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSearchState ? self.searchResults.count : self.dataArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDContactCell {
            var model: AgoraUserModel?
            if self.isSearchState {
                model = self.searchResults[indexPath.row] as? AgoraUserModel
            } else {
                model = self.dataArray[indexPath.section][indexPath.row]
            }
            if let model = model {
                cell.model = model
            }
            cell.tapCellHandle = {
                if let hyphenateId = model?.hyphenateId {
                    self.tapAction(userId: hyphenateId)
                }
            }
        }
        return cell
    }
}
