//
//  ACDPublicGroupListViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/20.
//

import UIKit
import AgoraChat
import SnapKit

class ACDPublicGroupListViewController: ACDContainerSearchTableViewController<AgoraGroupModel> {

    private lazy var noDataPromptView: ACDNoDataPlaceHolderView = {
        let view = ACDNoDataPlaceHolderView()
        view.noDataImageView.image = UIImage(named: "no_search_result")
        view.prompt.text = "The Group Does Not Exist".localized
        self.view.addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalTo(self.searchBar.snp.bottom).offset(48.0)
            make.centerX.left.right.bottom.equalTo(self.view)
        }
        return view
    }()
    
    private var cursor: String?
    
    var selectedHandle: ((_ groupId: String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Public Groups".localized
        self.view.backgroundColor = .white
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "gray_goBack"), style: .plain, target: self, action: #selector(backAction))
        
        let cancelButton = UIButton(type: .custom)
        cancelButton.frame = CGRect(x: 0, y: 0, width: 50, height: 40)
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        cancelButton.setTitleColor(Color_154DFE, for: .normal)
        cancelButton.setTitle(LocalizedString.Cancel, for: .normal)
        cancelButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        rightSpace.width = -2
        self.navigationItem.rightBarButtonItems = [rightSpace, UIBarButtonItem(customView: cancelButton)]
    
        self.table.rowHeight = 54
        
        self.table.separatorStyle = .none
        self.table.keyboardDismissMode = .onDrag
        self.table.tableFooterView = UIView()
        self.table.register(UINib(nibName: "ACDGroupCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.searchResultHandle = { [unowned self] in
            self.noDataPromptView.isHidden = self.searchResults.count != 0
            self.table.reloadData()
        }
        self.searchCancelHandle = { [unowned self] in
            self.noDataPromptView.isHidden = true
        }
    
        self.searchBar.snp.remakeConstraints { make in
            make.top.equalTo(self.navigationController?.navigationBar.frame.height ?? 0)
            make.left.right.equalTo(self.view)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshGroupList(_:)), name: GroupListChangedNotification, object: nil)
        
        self.fetchPublicGroup(refresh: true)
    }
    
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func fetchPublicGroup(refresh: Bool) {
        if !refresh {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        AgoraChatClient.shared().groupManager?.getPublicGroupsFromServer(withCursor: self.cursor, pageSize: 20, completion: { result, error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error {
                self.showHint(error.errorDescription)
            } else if let list = result?.list {
                let groups = self.getGroupsWithResultList(list)
                if self.cursor == "" {
                    self.dataArray.removeAll()
                }
                self.dataArray.append(contentsOf: groups)
                self.cursor = result?.cursor
                self.searchSource = groups
                self.table.reloadData()
            }
        })
    }

    private func getGroupsWithResultList(_ list: [AgoraChatGroup]) -> [AgoraGroupModel] {
        var groups: [AgoraGroupModel] = []
        for i in list {
            let model = AgoraGroupModel(group: i)
            groups.append(model)
        }
        return groups
    }
    
    @objc private func refreshGroupList(_ notification: Notification) {
        let groupList = AgoraChatClient.shared().groupManager?.getJoinedGroups()
        self.dataArray.removeAll()
        self.searchSource.removeAll()
        if let groupList = groupList {
            for i in groupList {
                let model = AgoraGroupModel(group: i)
                self.dataArray.append(model)
                self.searchSource.append(model)
            }
        }
        self.table.reloadData()
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
