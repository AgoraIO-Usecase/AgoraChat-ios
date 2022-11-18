//
//  AgoraChatThreadMembersViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/25.
//

import UIKit

class AgoraChatThreadMembersViewController: UIViewController {

    private let threadId: String
    private let group: AgoraChatGroup
    private var dataArray: [AgoraUserModel] = []
    private let navView = AgoraChatThreadListNavgation()
    private let tableView = UITableView(frame: CGRect.zero, style: .plain)
    
    private var cursor: String?
    private var loadMoreFinished = true
    private var haveMoreData = true
    
    init(threadId: String, group: AgoraChatGroup) {
        self.threadId = threadId
        self.group = group
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateGroupMember(_:)), name: GroupMemberChangedNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navView.backHandle = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        self.navView.title = "Thread Members".localized
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorStyle = .none
        self.tableView.scrollsToTop = false
        self.tableView.rowHeight = 54
        self.tableView.register(UINib(nibName: "ACDContactCell", bundle: nil), forCellReuseIdentifier: "cell")
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        refreshControl.attributedTitle = NSAttributedString(string: "Pull Down Refresh".localized)
        self.tableView.refreshControl = refreshControl
        self.tableView.refreshControl?.addTarget(self, action: #selector(didStartRefresh), for: .valueChanged)
        
        self.view.addSubview(self.navView)
        self.view.addSubview(self.tableView)
        
        self.fetchMembers(refresh: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.navView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44 + self.view.safeAreaInsets.top)
        self.tableView.frame = CGRect(x: 0, y: 44 + self.view.safeAreaInsets.top, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 44 - self.view.safeAreaInsets.top)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc private func didStartRefresh() {
        self.fetchMembers(refresh: true)
    }
    
    private func fetchMembers(refresh: Bool) {
        if refresh {
            self.cursor = nil
            self.dataArray.removeAll()
        }
        self.loadMoreFinished = false
        AgoraChatClient.shared().threadManager?.getChatThreadMemberListFromServer(withId: self.threadId, cursor: self.cursor ?? "", pageSize: 20, completion: { result, error in
            self.cursor = result?.cursor
            self.loadMoreFinished = true
            if error != nil {
                self.showHint("Failed to get the Thread Members, please try again later".localized)
            } else if let list = result?.list as? [String] {
                self.tableView.refreshControl?.endRefreshing()
                for i in list {
                    let model = AgoraUserModel(hyphenateId: i)
                    self.dataArray.append(model)
                }
                UserInfoStore.shared.fetchUserInfosFromServer(userIds: list, refresh: false) {
                    self.tableView.reloadData()
                }
                self.haveMoreData = list.count >= 20
                self.tableView.reloadData()
            }
        })
    }
    
    @objc private func updateGroupMember(_ notification: Notification) {
        guard let threadId = (notification.object as? [String: Any])?["kACDThreadId"] as? String else {
            return
        }
        if threadId == self.threadId {
            self.fetchMembers(refresh: true)
        }
    }
    
    private func leaveThread(member: String) {
        var list: [String] = []
        if let admins = self.group.adminList {
            list.append(contentsOf: admins)
        }
        list.append(self.group.owner)
        if let currentUser = AgoraChatClient.shared().currentUsername, list.contains(currentUser) {
            let vc = UIAlertController(title: member, message: nil, preferredStyle: .actionSheet)
            vc.addAction(UIAlertAction(title: "Remove from Thread".localized, iconImage: UIImage(named: "remove"), textColor: Color_FF14CC, alignment: .left, completion: { _ in
                MBProgressHUD.showAdded(to: self.view, animated: true)
                AgoraChatClient.shared().threadManager?.removeMember(fromChatThread: member, threadId: self.threadId, completion: { error in
                    MBProgressHUD.hide(for: self.view, animated: true)
                    if error == nil {
                        for i in 0..<self.dataArray.count {
                            if self.dataArray[i].hyphenateId == member {
                                self.dataArray.remove(at: i)
                                self.tableView.reloadData()
                                break
                            }
                        }
                    }
                })
            }))
            vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
            self.present(vc, animated: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension AgoraChatThreadMembersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDContactCell {
            cell.model = self.dataArray[indexPath.row]
            cell.tapCellHandle = { [unowned self] in
                self.leaveThread(member: self.dataArray[indexPath.row].hyphenateId)
            }
        }
        return cell
    }
}

extension AgoraChatThreadMembersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.dataArray.count - 2 && self.loadMoreFinished && self.haveMoreData {
            self.fetchMembers(refresh: false)
        }
    }
}
