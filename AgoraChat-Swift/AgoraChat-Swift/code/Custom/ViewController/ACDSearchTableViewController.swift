//
//  ACDSearchTableViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/27.
//

import UIKit
import SnapKit

class ACDSearchTableViewController<T>: ACDBaseTableViewController, UISearchBarDelegate {

    let searchBar = UISearchBar()
    
    var isSearchState: Bool = false
    
    var searchResultHandle: (() -> Void)?
    var searchCancelHandle: (() -> Void)?
    
    var dataArray: [T] = []
    var searchSource: [IAgoraRealtimeSearch] = []
    var searchResults: [IAgoraRealtimeSearch] = []
    var page = 1
    var members: [String] = []
    var sectionTitles: [String] = []
    
    private let realtimeSearchUtil = AgoraRealtimeSearchUtils()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.backgroundColor = .white
        self.searchBar.placeholder = "Search".localized
        self.searchBar.delegate = self
        self.searchBar.showsCancelButton = false
        self.searchBar.searchFieldBackgroundPositionAdjustment = .zero
        if let textField = self.searchBar.value(forKey: "searchField") as? UITextField {
            if #available(iOS 13.0, *) {
                self.searchBar.searchTextField.backgroundColor = Color_F2F2F2
            } else {
                textField.backgroundColor = Color_F2F2F2
            }
            textField.layer.cornerRadius = 16
            textField.layer.masksToBounds = true
        }
        
        self.view.addSubview(self.searchBar)
        self.searchBar.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
        }
        self.table.snp.remakeConstraints { make in
            make.top.equalTo(self.searchBar.snp.bottom)
            make.left.right.equalTo(self.view)
            make.bottom.equalTo(self.view).offset(-5.0)
        }
    }
    
    func cancelSearchState() {
        self.searchBar.text = ""
        self.searchBar.setShowsCancelButton(false, animated: true)
        self.searchBar.resignFirstResponder()
        self.realtimeSearchUtil.cancel()
        self.isSearchState = false
        self.searchCancelHandle?()
        self.table.isScrollEnabled = !self.isSearchState
        self.table.reloadData()
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.isSearchState = true
        if self.searchBar.text == "" {
            self.table.isUserInteractionEnabled = false
            self.searchResults.removeAll()
            self.table.reloadData()
        } else {
            self.table.isUserInteractionEnabled = true
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.table.isUserInteractionEnabled = true
        self.searchBar.resignFirstResponder()
    }

    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.table.isUserInteractionEnabled = true
        self.searchResults.removeAll()
        if searchBar.text?.count ?? 0 <= 0 {
            self.table.reloadData()
            return
        }
        self.realtimeSearchUtil.realSearch(source: self.searchSource, keyword: searchText) { result in
            self.searchResults = result
            self.searchResultHandle?()
            self.table.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelSearchState()
    }
}

extension ACDSearchTableViewController where T == [AgoraUserModel] {
    func sortAndReloadContacts(_ contacts: [String], subscribe: Bool = false) {
        if contacts.count <= 0 {
            self.dataArray.removeAll()
            self.sectionTitles.removeAll()
            self.searchSource.removeAll()
            self.table.reloadData()
            return
        }
        ContactUtil.sortContacts(contacts) { result, sectionTitles, searchSource in
            self.dataArray = result
            self.sectionTitles = sectionTitles
            self.searchSource = searchSource
            self.table.reloadData()
        }
        if subscribe {
            PresenceManager.shared.subscribe(members: contacts, completion: nil)
        }
    }
}
