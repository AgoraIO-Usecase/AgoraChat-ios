//
//  AgoraMemberSelectViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/21.
//

import UIKit

enum AgoraContactSelectStyle {
    case add
    case invite
}

class AgoraMemberSelectViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var selectCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    private let doneBtn = UIButton(type: .custom)
    
    private let maxInviteCount: Int
    private var selectContacts: [AgoraUserModel] = []
    private var unselectedContacts: [[AgoraUserModel]] = []
    private var hasInvitees: [String]
    
    private var sectionTitles: [String] = []
    private var searchSource: [AgoraUserModel] = []
    private var searchResults: [AgoraUserModel] = []
    private var isSearchState = false
    
    private let realtimeSearchUtil = AgoraRealtimeSearchUtils()
    
    var style: AgoraContactSelectStyle?
    weak var delegate: AgoraGroupUIProtocol?
    
    init(invitees: [String], maxInviteCount: Int) {
        self.hasInvitees = invitees
        self.maxInviteCount = maxInviteCount
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavBar()
        self.setupSearchBar()
        
        self.selectCollectionView.backgroundColor = .white
        self.selectCollectionView.register(UINib(nibName: "ACDMemberCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundColor = .white
        self.tableView.sectionIndexColor = Color_353535
        self.tableView.sectionIndexBackgroundColor = .clear
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib(nibName: "AgoraGroupMemberCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.updateHeaderView(isAdd: false)
        
        self.loadUnSelectContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func setupNavBar() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "black_goBack"), style: .plain, target: self, action: #selector(backAction))
        
        self.doneBtn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        
        if self.style == .invite {
            self.doneBtn.setTitle("Done".localized, for: .normal)
            self.doneBtn.isEnabled = false
        } else {
            self.doneBtn.setTitle("Create".localized, for: .normal)
        }
        self.doneBtn.setTitleColor(Color_154DFE, for: .normal)
        self.doneBtn.setTitleColor(Color_ADB9C1, for: .disabled)
        self.doneBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        self.doneBtn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.doneBtn)
    }
    
    private func setupSearchBar() {
        self.searchBar.placeholder = "Search".localized
        self.searchBar.showsCancelButton = false
        self.searchBar.backgroundColor = .white
        self.searchBar.searchFieldBackgroundPositionAdjustment = UIOffset.zero
        self.searchBar.tintColor = Color_0C1218
        if let textField = self.searchBar.value(forKey: "searchField") as? UITextField {
            if #available(iOS 13.0, *) {
                self.searchBar.searchTextField.backgroundColor = Color_F2F2F2
            } else {
                textField.backgroundColor = Color_F2F2F2
            }
            textField.layer.cornerRadius = textField.bounds.height / 2
            textField.layer.masksToBounds = true
        }
    }
    
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func doneAction() {
        self.delegate?.addSelectOccupants(self.selectContacts)
        self.backAction()
    }
    
    private func loadUnSelectContacts() {
        guard var contacts = AgoraChatClient.shared().contactManager?.getContacts() else {
            return
        }
        if let blockList = AgoraChatClient.shared().contactManager?.getBlackList() {
            contacts.remove(elements: blockList)
        }
        contacts.remove(elements: self.hasInvitees)
        self.hasInvitees.removeAll()
        
        ContactUtil.sortContacts(contacts) { result, sectionTitles, searchSource in
            self.unselectedContacts = result
            self.sectionTitles = sectionTitles
            self.searchSource = searchSource
            self.tableView.reloadData()
        }
    }
    
    private func updateHeaderView(isAdd: Bool) {
        self.collectionViewHeightConstraint.constant = self.selectContacts.count > 0 ? 90 : 0
        self.view.layoutIfNeeded()
        self.selectCollectionView.reloadData()
        if isAdd {
            let indexPath = IndexPath(item: self.selectContacts.count - 1, section: 0)
            self.selectCollectionView.insertItems(at: [indexPath])
        }
    }
    
    private func addOccupant(model: AgoraUserModel) {
        if self.hasInvitees.count + 1 > self.maxInviteCount {
            self.showHint("Member quantity: 3 to 2000".localized)
            return
        }
        
        self.selectContacts.append(model)
        self.hasInvitees.append(model.hyphenateId)
        self.doneBtn.isEnabled = true
        self.updateHeaderView(isAdd: true)
    }
    
    private func removeOccupantsFromDataSource(models: [AgoraUserModel]) {
        var indexPaths: [IndexPath] = []
        for model in models {
            if let index = self.selectContacts.firstIndex(of: model) {
                let indexPath = IndexPath(item: index, section: 0)
                indexPaths.append(indexPath)
                self.hasInvitees.remove(element: model.hyphenateId)
                self.selectContacts.remove(elements: models)
            }
        }
        DispatchQueue.main.async {
            if indexPaths.count > 0 {
                self.selectCollectionView.deleteItems(at: indexPaths)
            }
            if self.selectContacts.count <= 0 {
                self.doneBtn.isEnabled = false
            }
            self.updateHeaderView(isAdd: false)
        }
    }
}

extension AgoraMemberSelectViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.isSearchState ? 1 : self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isSearchState ? self.searchResults.count : self.unselectedContacts[section].count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.isSearchState ? [] : self.sectionTitles
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let cell = cell as? AgoraGroupMemberCell {
            let model = self.isSearchState ? self.searchResults[indexPath.row] : self.unselectedContacts[indexPath.section][indexPath.row]
            cell.isSelect = self.hasInvitees.contains(model.hyphenateId)
            cell.model = model
        }
        return cell
    }
}

extension AgoraMemberSelectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = self.isSearchState ? self.searchResults[indexPath.row] : self.unselectedContacts[indexPath.section][indexPath.row]
        if self.hasInvitees.contains(model.hyphenateId) {
            self.removeOccupantsFromDataSource(models: [model])
        } else {
            self.addOccupant(model: model)
        }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

extension AgoraMemberSelectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.selectContacts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDMemberCollectionCell {
            cell.model = self.selectContacts[indexPath.row]
        }
        return cell
    }
}

extension AgoraMemberSelectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.selectContacts[indexPath.row]
        self.removeOccupantsFromDataSource(models: [model])
        self.tableView.reloadData()
    }
}


extension AgoraMemberSelectViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        self.isSearchState = true
        self.tableView.isScrollEnabled = false
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        self.tableView.isScrollEnabled = true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count ?? 0 <= 0 {
            self.isSearchState = false
            self.tableView.isScrollEnabled = false
            self.searchResults.removeAll()
            self.tableView.reloadData()
            return
        }
        self.isSearchState = true
        self.realtimeSearchUtil.realSearch(source: self.searchSource, keyword: searchText) { result in
            if let result = result as? [AgoraUserModel] {
                self.searchResults = result
            }
            self.tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.tableView.isScrollEnabled = true
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        self.realtimeSearchUtil.cancel()
        self.isSearchState = false
        self.tableView.isScrollEnabled = true
        self.tableView.reloadData()
    }
}
