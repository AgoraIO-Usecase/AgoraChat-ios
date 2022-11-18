//
//  ACDGroupMemberAllViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/21.
//

import UIKit

class ACDGroupMemberAllViewController: ACDContainerSearchTableViewController<[AgoraUserModel]> {
    
    private let group: AgoraChatGroup
    private var cursor: String?
    
    init(group: AgoraChatGroup) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupMember(_:)), name: GroupMemberChangedNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.table.rowHeight = 54
        self.table.register(UINib(nibName: "ACDContactCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.useRefresh()
        self.fetchMembers(isRefresh: true)
    }
    
    func updateUI() {
        self.fetchMembers(isRefresh: true)
    }
    
    @objc private func updateGroupMember(_ notification: Notification) {
        if let groupId = (notification.object as? [String: Any])?["kACDGroupId"] as? String {
            if groupId == self.group.groupId {
                self.updateUI()
            }
        }
    }
    
    private func fetchMembers(isRefresh: Bool) {
        if isRefresh {
            self.cursor = nil
        }
        AgoraChatClient.shared().groupManager?.getGroupMemberListFromServer(withId: self.group.groupId, cursor: self.cursor, pageSize: 20, completion: { result, error in
            self.cursor = result?.cursor
            self.endRefresh()
            if let error = error {
                self.showHint(error.errorDescription)
            } else if let members = result?.list as? [String] {
                if isRefresh {
                    self.members.removeAll()
                    if let owner = self.group.owner {
                        self.members.append(owner)
                    }
                    self.members.append(contentsOf: self.group.adminList)
                }
                self.members.append(contentsOf: members)
                self.sortAndReloadContacts(self.members)
            }
            
            if let list = result?.list, list.count >= 20 {
                self.useLoadMore()
            } else {
                self.endLoadMore()
                self.loadMoreCompleted()
            }
            self.table.reloadData()
        })
    }
    
    override func didStartRefresh() {
        self.fetchMembers(isRefresh: true)
    }
    
    override func didStartLoadMore() {
        self.fetchMembers(isRefresh: false)
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
                if model.hyphenateId == self.group.owner {
                    cell.detailLabel.text = "Owner".localized
                } else if self.group.adminList.contains(model.hyphenateId) {
                    cell.detailLabel.text = "Admin".localized
                } else {
                    cell.detailLabel.text = ""
                }
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
