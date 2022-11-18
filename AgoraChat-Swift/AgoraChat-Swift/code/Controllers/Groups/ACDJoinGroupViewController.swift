//
//  ACDJoinGroupViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/21.
//

import UIKit

class ACDJoinGroupViewController: ACDSearchTableViewController<String> {

    var isSearchGroup: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.isSearchGroup {
            self.title = "Join a Group".localized
        } else {
            self.title = "Add Contacts".localized
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "gray_goBack"), style: .plain, target: self, action: #selector(backAction))

        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 8, height: 15))
        btn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        btn.setTitle(LocalizedString.Cancel, for: .normal)
        btn.setTitleColor(Color_154DFE, for: .normal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btn)
        
        self.table.rowHeight = 54
        self.table.register(UINib(nibName: "ACDSearchJoinCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.searchBar.snp.remakeConstraints { make in
            make.top.equalTo(self.navigationController?.navigationBar.frame.height ?? 0)
            make.left.right.equalTo(self.view)
        }
    }

    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }

    private func joinToPublicGroup(groupId: String) {
        self.cancelSearchState()
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().groupManager?.request(toJoinPublicGroup: groupId, message: "", completion: { group, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error {
                self.showHint(error.errorDescription)
            }
        })
    }
    
    private func sendAddContact(to contact: String) {
        if contact.count <= 0 {
            self.showHint(String(format: "%@ can't be null".localized, "Contact Name"))
            return
        }
        if self.isContainInMyContacts(contact) {
            self.searchBar.text = ""
            self.showHint("This contact has been added".localized)
            return
        }
        if contact.uppercased() == AgoraChatClient.shared().currentUsername?.uppercased() {
            self.searchBar.text = ""
            self.showHint("Not allowed to send their own friends to apply for".localized)
            return
        }
        self.cancelSearchState()
        
        let msg = String(format: "%@ add you as a friend".localized, AgoraChatClient.shared().currentUsername!)
        MBProgressHUD.showAdded(to: self.view, animated: true)
        AgoraChatClient.shared().contactManager?.addContact(contact, message: msg, completion: { username, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error {
                self.showAlert(message: error.errorDescription)
            } else {
                self.showAlert(message: "Operation succeeded".localized)
            }
        })
    }
    
    private func isContainInMyContacts(_ contact: String) -> Bool {
        if let contacts = AgoraChatClient.shared().contactManager?.getContacts() {
            return contacts.contains(contact)
        }
        return false
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDSearchJoinCell, let text = self.searchSource[0] as? String {
            cell.isSearchGroup = self.isSearchGroup
            cell.searchName = self.isSearchGroup ? "\("GroupID".localized)：\(text)" : "\("AgoraID".localized)：\(text)"
            cell.addGroupHandle = { [unowned self] in
                if self.isSearchGroup {
                    self.joinToPublicGroup(groupId: text)
                } else {
                    self.sendAddContact(to: text)
                }
            }
        }
        return cell
    }
    
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.dataArray = [searchText]
        self.searchSource = self.dataArray
        self.table.reloadData()
    }
    
    override func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.searchSource = []
        self.table.reloadData()
    }
}
