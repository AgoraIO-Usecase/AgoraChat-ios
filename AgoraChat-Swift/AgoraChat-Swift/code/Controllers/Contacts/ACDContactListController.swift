//
//  ACDContactListController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/17.
//

import UIKit

class ACDContactListController: ACDContainerSearchTableViewController<[AgoraUserModel]> {

    private var contacts: [String]?
    
    var selectedBlock: ((_ contactId: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(presencesUpdated(_:)), name: PresenceUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(contactListDidChange), name: ContactsUpdatedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRecvUserInfoDidChangeNotification(_:)), name: UserInfoDidChangeNotification, object: nil)
        
        self.table.separatorStyle = .none
        self.table.keyboardDismissMode = .onDrag
        self.table.rowHeight = 54
        self.table.sectionIndexColor = Color_353535
        self.table.sectionIndexBackgroundColor = .clear
        self.table.register(UINib(nibName: "ACDContactCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.useRefresh()
        self.didStartRefresh()
    }
    
    override func didStartRefresh() {
        if self.isSearchState {
            self.endRefresh()
            return
        }
        AgoraChatClient.shared().contactManager?.getContactsFromServer(completion: { list, error in
            if let list = list {
                UserInfoStore.shared.fetchUserInfosFromServer(userIds: list) {
                    self.table.reloadData()
                }
                self.updateContacts(bubbyList: list)
            }
            self.endRefresh()
        })
    }
    
    @objc private func presencesUpdated(_ notification: Notification) {
        guard let array = notification.object as? [String], let contacts = self.contacts else {
            return
        }
        for item in array where contacts.contains(item) {
            self.table.reloadData()
            break
        }
    }
    
    @objc private func contactListDidChange() {
        self.reloadContacts()
    }
    
    @objc private func didRecvUserInfoDidChangeNotification(_ notification: Notification) {
        guard let list = notification.userInfo?["userinfo_list"] as? [AgoraChatUserInfo], let contacts = self.contacts else {
            return
        }
        for item in list {
            if let userId = item.userId, contacts.contains(userId) {
                self.table.reloadData()
                break
            }
        }
    }
    
    private func updateContacts(bubbyList: [String]?) {
        self.contacts = bubbyList
        let blackList = AgoraChatClient.shared().contactManager?.getBlackList()
        var contacts: [String] = bubbyList == nil ? [] : Array(bubbyList!)
        if bubbyList != nil, let blackList = blackList {
            for blackId in blackList {
                for i in 0..<contacts.count where contacts[i] == blackId {
                    contacts.remove(at: i)
                    break
                }
            }
        }
        self.sortAndReloadContacts(contacts, subscribe: true)
    }
    
    func reloadContacts() {
        let bubbyList = AgoraChatClient.shared().contactManager?.getContacts()
        self.updateContacts(bubbyList: bubbyList)
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
        let cell = table.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDContactCell {
            var model: AgoraUserModel?
            if self.isSearchState {
                model = self.searchResults[indexPath.row] as? AgoraUserModel
            } else {
                model = self.dataArray[indexPath.section][indexPath.row]
            }
            cell.model = model!
            if let hyphenateId = model?.hyphenateId {
                let presence = PresenceManager.shared.presences[hyphenateId]
                let status = PresenceManager.fetchStatus(presence: presence)
                if let imageName = PresenceManager.whiteStrokePresenceImagesMap[status] {
                    cell.iconImageView.presenceImage = UIImage(named: imageName)
                }
                if status != .offline, let statusDescription = presence?.statusDescription, statusDescription.count > 0 {
                    cell.detailLabel.text = statusDescription
                } else {
                    let showStatus = status == .offline ? PresenceManager.formatOfflineTimespace(presence: presence) : PresenceManager.showStatusMap[status]
                    cell.detailLabel.text = showStatus
                }
            }
            cell.tapCellHandle = {
                if let hyphenateId = model?.hyphenateId {
                    self.selectedBlock?(hyphenateId)
                }
            }
        }
        return cell
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
