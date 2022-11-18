//
//  ConfInviteUsersViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/18.
//

import UIKit

@objcMembers
class ConfInviteUsersViewController: UIViewController {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var searchTableView: UITableView!
    
    private let excludeUsers: [String]
    private let groupId: String
    private var inGroupArray: [String]
    private var userModelMap: [String: AgoraUserModel] = [:]
    private var dataArray: [String] = []
    private var searchDataArray: [String] = []
    private var inviteUsers: [String] = []
    private var isSearching = false
    private var cursor: String?
    
    private let realtimeSearchUtil = AgoraRealtimeSearchUtils()
    
    var didSelectedUserListHandle: ((_ users: [String]) -> Void)?
    
    init(groupId: String, excludeUsers: [String]) {
        self.groupId = groupId
        self.excludeUsers = excludeUsers
        self.inGroupArray = Array(excludeUsers)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: UserInfoDidChangeNotification, object: nil)
     
        self.collectionView.register(UINib(nibName: "ACDMemberCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        let nib = UINib(nibName: "AgoraGroupMemberCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "cell")
        self.searchTableView.register(nib, forCellReuseIdentifier: "cell")
        self.fetchGroupMembers(refresh: true)
    }

    @IBAction func confirmAction() {
        self.didSelectedUserListHandle?(self.inviteUsers)
        self.dismiss(animated: true)
    }
    
    @objc private func refreshTableView() {
        self.tableView.reloadData()
    }
    
    private func fetchGroupMembers(refresh: Bool) {
        let pageSize = 20
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().groupManager?.getGroupMemberListFromServer(withId: self.groupId, cursor: self.cursor, pageSize: pageSize, completion: { result, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableView.mj_header?.endRefreshing()
            self.tableView.mj_footer?.endRefreshing()
            if let error = error {
                self.showHint(error.errorDescription)
                return
            }
            self.cursor = result?.cursor
            var allList: [String] = []
            if refresh {
                self.dataArray.removeAll()
                if let group = AgoraChatClient.shared().groupManager?.getGroupSpecificationFromServer(withId: self.groupId, error: nil) {
                    if let owner = group.owner {
                        allList.append(owner)
                    }
                    if let admin = group.adminList {
                        allList.append(contentsOf: admin)
                    }
                }
                self.loadUserInfo(userIds: self.dataArray)
            }
            if let list = result?.list as? [String] {
                allList.append(contentsOf: list)
            }
            self.loadUserInfo(userIds: allList)
            let resultList = self.getInvitableUsers(users: allList)
            self.dataArray.append(contentsOf: resultList)
            self.tableView.reloadData()
        })
    }
    
    private func loadUserInfo(userIds: [String]) {
        UserInfoStore.shared.fetchUserInfosFromServer(userIds: userIds) {
            for userId in userIds {
                let model = AgoraUserModel(hyphenateId: userId)
                if let userInfo = UserInfoStore.shared.getUserInfo(userId: userId) {
                    model.setUserInfo(userInfo)
                }
                self.userModelMap[userId] = model
            }
            self.tableView.reloadData()
            self.collectionView.reloadData()
        }
    }

    private func getInvitableUsers(users: [String]) -> [String] {
        var retNames = Array(users)
        if let loginName = AgoraChatClient.shared().currentUsername?.lowercased() {
            for i in 0..<retNames.count where retNames[i] == loginName {
                retNames.remove(at: i)
                break
            }
        }
        for name in self.excludeUsers {
            for i in 0..<retNames.count where retNames[i] == name {
                retNames.remove(at: i)
                break
            }
        }
        return retNames
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension ConfInviteUsersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSearching ? self.searchDataArray.count : self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? AgoraGroupMemberCell {
            let username = (self.isSearching ? self.searchDataArray : self.dataArray)[indexPath.row]
//            if let item = self.userModelMap[username] {
//                cell.nameLabel.text = item.showName
//                cell.iconImageView.setImage(withUrl: item.avatarURLPath, placeholder: item.defaultAvatar)
//            } else {
//                cell.nameLabel.text = username
//                cell.iconImageView.image = UIImage(named: "defaultAvatar")
//            }
            cell.isSelect = self.inviteUsers.contains(username)
            cell.model = self.userModelMap[username]
//            cell.selectImageView.image =
//            cell.isChecked = self.inviteUsers.contains(username)
        }
        return cell
    }
}

extension ConfInviteUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let username = (self.isSearching ? self.searchDataArray : self.dataArray)[indexPath.row]
        let cell = tableView.cellForRow(at: indexPath) as? AgoraGroupMemberCell
        if self.inviteUsers.count + self.excludeUsers.count >= 3, cell?.isSelect != true {
            self.showHint("There can only be 3 people in the channel".localized)
            return
        }
        let isChecked = self.inviteUsers.contains(username)
        if isChecked {
            for i in 0..<self.inviteUsers.count where self.inviteUsers[i] == username {
                self.inviteUsers.remove(at: i)
                break
            }
            for i in 0..<self.inGroupArray.count where self.inGroupArray[i] == username {
                self.inGroupArray.remove(at: i)
                break
            }
        } else {
            self.inviteUsers.append(username)
            self.inGroupArray.append(username)
        }
        cell?.isSelect = !isChecked
        let count = self.inviteUsers.count
        let title = "Select Members".localized
        self.titleLabel.text = count == 0 ? title : "\(title)(\(count))"
        self.collectionView.reloadData()
    }
}

extension ConfInviteUsersViewController: UISearchBarDelegate {
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !self.isSearching {
            self.isSearching = true
            self.searchTableView.isHidden = false
        }
        self.realtimeSearchUtil.realSearch(source: self.dataArray, keyword: searchBar.text ?? "") { result in
            self.searchDataArray.removeAll()
            if let result = result as? [String] {
                self.searchDataArray.append(contentsOf: result)
            }
            self.searchTableView.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            searchBar.resignFirstResponder()
            return false
        }
        return true
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.realtimeSearchUtil.cancel()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        
        self.isSearching = false
        self.searchDataArray.removeAll()
        self.searchTableView.isHidden = true
        self.searchTableView.reloadData()
        self.tableView.reloadData()
    }
}

extension ConfInviteUsersViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.inGroupArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDMemberCollectionCell {
            let username = self.inGroupArray[indexPath.item]
            cell.username = username
            cell.model = self.userModelMap[username]
            cell.deleteEnable = !self.excludeUsers.contains(self.inGroupArray[indexPath.item])
        }
        return cell
    }
}

extension ConfInviteUsersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let username = self.inGroupArray[indexPath.item]
        if excludeUsers.contains(username) {
            return
        }
        for i in 0..<self.inviteUsers.count where self.inviteUsers[i] == username {
            self.inviteUsers.remove(at: i)
            break
        }
        for i in 0..<self.inGroupArray.count where self.inGroupArray[i] == username {
            self.inGroupArray.remove(at: i)
            break
        }
        self.tableView.reloadData()
        self.collectionView.reloadData()
    }
}
