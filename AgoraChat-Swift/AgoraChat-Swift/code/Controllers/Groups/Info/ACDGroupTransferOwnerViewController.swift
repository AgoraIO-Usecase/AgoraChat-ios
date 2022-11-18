//
//  ACDGroupTransferOwnerViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/27.
//

import UIKit

class ACDGroupTransferOwnerViewController: ACDSearchTableViewController<String> {

    private let group: AgoraChatGroup
    private let isLeaveGroup: Bool
    private var cursor: String?
    
    init(group: AgoraChatGroup, isLeaveGroup: Bool = false) {
        self.group = group
        self.isLeaveGroup = isLeaveGroup
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.rowHeight = 54
        self.table.register(UINib(nibName: "ACDInfoDetailCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.fetchMembers(refresh: true)
    }
    
    private func fetchMembers(refresh: Bool) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().groupManager?.getGroupMemberListFromServer(withId: self.group.groupId, cursor: refresh ? "" : self.cursor, pageSize: 20, completion: { result, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error {
                self.showHint(error.errorDescription)
            } else if let result = result {
                self.cursor = result.cursor
                if (refresh) {
                    self.dataArray.removeAll()
                    if let owner = self.group.owner {
                        self.dataArray.append(owner)
                    }
                    self.dataArray.append(contentsOf: self.group.adminList)
                }
                if let list = result.list as? [String] {
                    self.dataArray.append(contentsOf: list)
                }
                self.searchSource = self.dataArray
                self.table.reloadData()
            }
        })
    }
    
    private func transferAlert(user: String) {
        let title: String
        if self.isLeaveGroup {
            title = String(format: "Transfer Ownership to %@ and Leave this Group?".localized, user)
        } else {
            title = String(format: "Transfer Ownership to %@ ".localized, user)
        }
        let vc = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        vc.addAction(UIAlertAction(title: LocalizedString.Yes, style: .default, handler: { _ in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            AgoraChatClient.shared().groupManager?.updateGroupOwner(self.group.groupId, newOwner: user, completion: { group, error in
                MBProgressHUD.hide(for: self.view, animated: true)
                if error != nil {
                    self.showHint("Operation failed".localized)
                } else {
                    if self.isLeaveGroup {
                        MBProgressHUD.showAdded(to: self.view, animated: true)
                        AgoraChatClient.shared().groupManager?.leaveGroup(self.group.groupId, completion: { error in
                            MBProgressHUD.hide(for: self.view, animated: true)
                            if error != nil {
                                self.showHint("Operation failed".localized)
                            } else {
                                NotificationCenter.default.post(name: GroupListChangedNotification, object: nil)
                                self.navigationController?.popViewController(animated: true)
                            }
                        })
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
        }))
        self.present(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSearchState ? self.searchResults.count : self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDInfoDetailCell {
            let name = (self.isSearchState ? self.searchResults : self.dataArray)[indexPath.row] as! String
            cell.iconImageView.image = UIImage(named: "default_avatar")
            cell.nameLabel.text = name

            if name == self.group.owner {
                cell.detailLabel.text = "Owner".localized
            } else if self.group.adminList.contains(name) {
                cell.detailLabel.text = "Admin".localized
            } else {
                cell.detailLabel.text = ""
            }
            cell.tapCellHandle = { [unowned self] in
                if self.group.owner == name {
                    return
                }
                self.transferAlert(user: name)
            }
        }
        return cell
    }
}
