//
//  ACDGroupMemberBlockListViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/21.
//

import UIKit

class ACDGroupMemberBlockListViewController: ACDContainerSearchTableViewController<[AgoraUserModel]> {

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
        
        self.useRefresh()
        if self.group.permissionType == .owner || self.group.permissionType == .admin {
            self.updateUI()
        }
    }
    
    func updateUI() {
        if self.group.permissionType == .owner || self.group.permissionType == .admin {
            self.fetchBlocks(isRefresh: true)
        }
    }
    
    private func fetchBlocks(isRefresh: Bool) {
        if isRefresh {
            self.page = 1
        } else {
            self.page += 1
        }
        AgoraChatClient.shared().groupManager?.getGroupBlacklistFromServer(withId: self.group.groupId, pageNumber: Int(self.page), pageSize: 20, completion: { list, error in
            self.endRefresh()
            if let error = error {
                self.showHint(error.errorDescription)
            } else if let list = list {
                if (isRefresh) {
                    self.members.removeAll()
                }
                self.members.append(contentsOf: list)
                self.sortAndReloadContacts(self.members)
            }
            if list?.count ?? 0 < 20 {
                self.endLoadMore()
            } else {
                self.useLoadMore()
            }
        })
    }
    
    @objc private func updateGroupMemberWithNotification(_ notification: Notification) {
        guard let dict = notification.object as? [String: Any] else {
            return
        }
        if self.group.groupId == dict["kACDGroupId"] as? String && dict["kACDGroupMemberListType"] as? ACDContainerSearchTableViewController<[AgoraUserModel]>.GroupMemberShowType == .block {
            self.updateUI()
        }
    }
    
    override func didStartRefresh() {
        self.fetchBlocks(isRefresh: true)
    }
    
    override func didStartLoadMore() {
        self.fetchBlocks(isRefresh: false)
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
                    self.showActionSheet(userId: model.hyphenateId, showType: .block, group: self.group)
                }
            }
        }
        return cell
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
