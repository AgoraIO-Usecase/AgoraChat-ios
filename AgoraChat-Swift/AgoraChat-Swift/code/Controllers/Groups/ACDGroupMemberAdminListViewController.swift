//
//  ACDGroupMemberAdminListViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/21.
//

import UIKit

class ACDGroupMemberAdminListViewController: ACDContainerSearchTableViewController<[AgoraUserModel]> {

    private var group: AgoraChatGroup
    
    init(group: AgoraChatGroup) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupMemberWithNotification(_:)), name: GroupMemberChangedNotification, object: nil)
        
        self.table.rowHeight = 54
        self.table.register(UINib(nibName: "ACDContactCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.buildAdmins()
    }
    
    private func buildAdmins() {
        var list: [String] = []
        list.append(self.group.owner)
        list.append(contentsOf: self.group.adminList)
        self.sortAndReloadContacts(list)
    }
    
    func updateUI() {
        AgoraChatClient.shared().groupManager?.getGroupSpecificationFromServer(withId: self.group.groupId, completion: { groupInfo, error in
            if let error = error {
                self.showHint(error.errorDescription)
            } else if let groupInfo = groupInfo {
                self.group = groupInfo
                self.buildAdmins()
            }
        })
    }
    
    @objc private func updateGroupMemberWithNotification(_ notification: Notification) {
        guard let dict = notification.object as? [String: Any] else {
            return
        }
        if self.group.groupId == dict["kACDGroupId"] as? String && dict["kACDGroupMemberListType"] as? ACDContainerSearchTableViewController<[AgoraUserModel]>.GroupMemberShowType == .admin {
            self.updateUI()
        }
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
                cell.tapCellHandle = { [unowned self] in
                    self.showActionSheet(userId: model.hyphenateId, showType: .all, group: self.group)
                }
            }
        }
        return cell
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
