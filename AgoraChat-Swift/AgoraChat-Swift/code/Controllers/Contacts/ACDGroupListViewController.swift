//
//  ACDGroupListViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/19.
//

import UIKit

class ACDGroupListViewController: ACDContainerSearchTableViewController<AgoraGroupModel> {

    var selectedHandle: ((_ groupId: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.table.separatorStyle = .none
        self.table.keyboardDismissMode = .onDrag
        self.table.rowHeight = 54.0
        self.table.tableFooterView = UIView()
        self.table.register(UINib(nibName: "ACDGroupCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshGroupList(_:)), name: GroupListChangedNotification, object: nil)
        self.loadGroupsFromServer()
    }
    
    private func loadGroupsFromServer() {
        self.useRefresh()
        self.didStartRefresh()
    }
    
    @objc private func refreshGroupList(_ notification: Notification) {
        let groups = AgoraChatClient.shared().groupManager?.getJoinedGroups()
        self.dataArray.removeAll()
        self.searchSource.removeAll()
        if let groups = groups {
            for group in groups {
                let model = AgoraGroupModel(group: group)
                self.dataArray.append(model)
                self.searchSource.append(model)
            }
        }
        self.table.reloadData()
    }
    
    private func tableViewDidTriggerFooterRefresh() {
        self.page += 1
        self.fetchJoinedGroup(page: self.page)
    }
    
    private func fetchJoinedGroup(page: Int) {
        if page != 0 {
            if let view = UIWindow.keyWindow {
                MBProgressHUD.showAdded(to: view, animated: true)
            }
        }
        let pageSize = 20
        AgoraChatClient.shared().groupManager?.getJoinedGroupsFromServer(withPage: Int(page), pageSize: pageSize, needMemberCount: false, needRole: false, completion: { groups, error in
            if let view = UIWindow.keyWindow {
                MBProgressHUD.hide(for: view, animated: true)
            }
            self.endRefresh()
            if let groups = groups, groups.count > 0 {
                if page == 0 {
                    self.dataArray.removeAll()
                    self.searchSource.removeAll()
                }
                for group in groups {
                    let model = AgoraGroupModel(group: group)
                    self.dataArray.append(model)
                    self.searchSource.append(model)
                }
                if groups.count <= pageSize {
                    self.useLoadMore()
                } else {
                    self.endLoadMore()
                }
                DispatchQueue.main.async {
                    self.table.reloadData()
                }
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSearchState ? self.searchResults.count : self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDGroupCell {
            if let model = (self.isSearchState ? self.searchResults : self.dataArray)[indexPath.row] as? AgoraGroupModel {
                cell.model = model
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let model = (self.isSearchState ? self.searchResults : self.dataArray)[indexPath.row] as? AgoraGroupModel {
            self.selectedHandle?(model.group.groupId)
        }
    }
    
    override func didStartRefresh() {
        if self.isSearchState {
            self.endRefresh()
            return
        }
        self.page = 0
        self.fetchJoinedGroup(page: self.page)
    }
    
    override func didStartLoadMore() {
        self.tableViewDidTriggerFooterRefresh()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
