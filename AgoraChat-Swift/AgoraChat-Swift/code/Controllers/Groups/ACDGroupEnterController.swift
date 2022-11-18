//
//  ACDGroupEnterController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/19.
//

import UIKit
import SnapKit

class ACDGroupEnterController: ACDSearchTableViewController<[AgoraUserModel]> {

    enum AccessType {
        case contact
        case chat
    }
    
    var accessType: AccessType = .contact
    
    private enum CellType {
        case addContact
        case newGroup
        case joinGroup
        case publicGroup
    }
    
    private var cellTypeMap: [CellType: (String, String, () -> Void)]!
    private let chatCellTypes: [CellType] = [.newGroup, .joinGroup, .publicGroup, .addContact]
    private let contactCellTypes: [CellType] = [.addContact, .joinGroup, .publicGroup]
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.cellTypeMap = [
            .addContact: ("add_contact", "Add Contacts".localized, { [unowned self] in
                self.goAddContact()
            }),
            .newGroup: ("new_group", "New Group".localized, { [unowned self] in
                let vc = ACDCreateNewGroupViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }),
            .joinGroup: ("join_group", "Join a Group".localized, { [unowned self] in
                self.joinPublicGroup()
            }),
            .publicGroup: ("public_group", "Public Groups".localized, { [unowned self] in
                self.goPublicGroupList()
            })
        ]
    }
                          
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
                          
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Options".localized
        
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 8, height: 15))
        btn.addTarget(self, action: #selector(back), for: .touchUpInside)
        btn.setTitle(LocalizedString.Cancel, for: .normal)
        btn.setTitleColor(Color_154DFE, for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
        self.table.rowHeight = 54
        self.table.separatorStyle = .none
        self.table.keyboardDismissMode = .onDrag
        self.table.backgroundColor = .white
        self.table.sectionIndexColor = Color_353535
        self.table.sectionIndexBackgroundColor = .clear
        self.table.register(UINib(nibName: "ACDContactCell", bundle: nil), forCellReuseIdentifier: "cell")
                
        if self.accessType == .chat {
            self.searchBar.isHidden = false
            self.fetchAllContactsFromServer()
            self.searchBar.snp.remakeConstraints { make in
                make.top.equalTo(self.navigationController?.navigationBar.frame.maxY ?? 0)
                make.left.equalTo(self.view).offset(12.0)
                make.right.equalTo(self.view).offset(-12.0)
                make.height.equalTo(40.0)
            }
            self.table.snp.remakeConstraints { make in
                make.top.equalTo(self.searchBar.snp.bottom)
                make.left.right.bottom.equalTo(self.view)
            }
        } else {
            self.searchBar.isHidden = true
            self.table.reloadData()
            self.table.snp.remakeConstraints { make in
                make.edges.equalTo(0)
            }
        }
    }

    @objc private func back() {
        self.dismiss(animated: true)
    }
    
    private func fetchAllContactsFromServer() {
        AgoraChatClient.shared().contactManager?.getContactsFromServer(completion: { list, error in
            if let list = list {
                self.updateContacts(contacts: list)
            }
        })
    }
    
    private func updateContacts(contacts: [String]) {
        var result = Array(contacts)
        if let blackList = AgoraChatClient.shared().contactManager?.getBlackList() {
            for i in blackList {
                result.remove(element: i)
            }
        }
        self.sortAndReloadContacts(result)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (self.accessType == .chat && section == 1) ? 30 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.accessType == .chat && section == 1 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.textColor = Color_999999
            label.text = "Contacts".localized
            label.textAlignment = .left
            view.addSubview(label)
            label.snp.makeConstraints { make in
                make.centerY.equalTo(view)
                make.left.equalTo(16)
            }
            return view
        }
        return nil
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if self.accessType == .chat {
            if self.isSearchState {
                return 1
            } else {
                return self.sectionTitles.count + 1
            }
        }
        return 1
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.accessType == .chat ? self.sectionTitles : []
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.accessType == .chat {
            if self.isSearchState {
                return self.searchResults.count
            } else {
                if section == 0 {
                    return 4
                } else {
                    return self.dataArray[section - 1].count
                }
            }
        }
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDContactCell {
            if accessType == .chat {
                if self.isSearchState {
                    if let model = self.searchResults[indexPath.row] as? AgoraUserModel {
                        cell.model = model
                        cell.tapCellHandle = { [unowned self] in
                            self.goContactInfoPage(userId: model.hyphenateId)
                        }
                    }
                } else {
                    if indexPath.section == 0 {
                        let cellType = self.chatCellTypes[indexPath.row]
                        if let value = self.cellTypeMap[cellType] {
                            cell.iconImageView.image = UIImage(named: value.0)
                            cell.nameLabel.text = value.1
                            cell.tapCellHandle = value.2
                        }
                    } else {
                        let model = self.dataArray[indexPath.section - 1][indexPath.row]
                        cell.model = model
                        cell.tapCellHandle = {
                            self.goContactInfoPage(userId: model.hyphenateId)
                        }
                    }
                }
            } else {
                let cellType = self.contactCellTypes[indexPath.row]
                if let value = self.cellTypeMap[cellType] {
                    cell.iconImageView.image = UIImage(named: value.0)
                    cell.nameLabel.text = value.1
                    cell.tapCellHandle = value.2
                }
            }
        }
        return cell
    }

    private func goPublicGroupList() {
        let vc = ACDPublicGroupListViewController()
        vc.selectedHandle = { groupId in
            let vc = ACDGroupInfoViewController(groupId: groupId, accessType: .search)
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func goAddContact() {
        let vc = ACDJoinGroupViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    private func goContactInfoPage(userId: String) {
        let vc = ACDContactInfoViewController(userId: userId)
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func joinPublicGroup() {
        let vc = ACDJoinGroupViewController()
        vc.isSearchGroup = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
