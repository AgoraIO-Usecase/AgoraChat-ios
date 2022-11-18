//
//  AgoraChatSearchResultController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/28.
//

import UIKit
import SnapKit

class AgoraChatSearchResultController: UIViewController {

    let searchBar = UISearchBar()
    var searchKeyword: String?
    weak var delegate: AgoraChatSearchControllerDelegate?
    
    let tableView = UITableView(frame: .zero, style: .plain)
    
    var dataArray: [Any] = []
    
    var cellForRowAtIndexPathCompletion: ((_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell)?
    var canEditRowAtIndexPath: ((_ tableView: UITableView, _ indexPath: IndexPath) -> Bool)?
    var trailingSwipeActionsConfigurationForRowAtIndexPath: ((_ tableView: UITableView, _ indexPath: IndexPath) -> UISwipeActionsConfiguration)?
    var didSelectRowAtIndexPathCompletion: ((_ tableView: UITableView, _ indexPath: IndexPath) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        self.edgesForExtendedLayout = []
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.searchBar.searchBarStyle = .minimal
        self.searchBar.backgroundColor = .white
        self.searchBar.returnKeyType = .done
        self.searchBar.setImage(UIImage(named: "deleteSearch"), for: .clear, state: .normal)
        if let searchField = self.searchBar.value(forKey: "searchField") as? UITextField {
            searchField.tintColor = Color_005FFF
            searchField.backgroundColor = .white
            searchField.layer.cornerRadius = 18.0
            searchField.layer.masksToBounds = true
        }
        let appearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
        appearance.tintColor = Color_114EFF
        appearance.setTitleTextAttributes([
            .font: UIFont(name: "PingFangSC-Medium", size: 16) ?? UIFont.systemFont(ofSize: 16)
        ], for: .normal)
        self.searchBar.delegate = self
        
        self.view.addSubview(self.searchBar)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.tableFooterView = UIView()
        self.tableView.estimatedSectionHeaderHeight = 0
        self.tableView.estimatedSectionFooterHeight = 0
        self.view.addSubview(self.tableView)
        
        self.searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.snp.top).offset(43)
            make.left.right.equalTo(self.view)
            make.height.equalTo(54)
        }
        self.tableView.snp.makeConstraints { make in
            make.top.equalTo(self.searchBar.snp.bottom)
            make.left.right.bottom.equalTo(self.view)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc private func keyBoardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyBoardBounds = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        let keyBoardHeight = keyBoardBounds?.height ?? 0
        let animationTime = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat
        self.tableView.snp.updateConstraints { make in
            make.bottom.equalTo(self.view).offset(-keyBoardHeight)
        }
        if let animationTime = animationTime, animationTime > 0 {
            UIView.animate(withDuration: animationTime) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @objc private func keyBoardWillHide(_ notification: Notification) {
        let userInfo = notification.userInfo
        let animationTime = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? CGFloat
        self.tableView.snp.updateConstraints { make in
            make.bottom.equalTo(self.view)
        }
        if let animationTime = animationTime, animationTime > 0 {
            UIView.animate(withDuration: animationTime) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

protocol AgoraChatSearchControllerDelegate: AnyObject {
    func searchBarWillBeginEditing(_ searchBar: UISearchBar)
    func searchBarCancelButtonAction(_ searchBar: UISearchBar)
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    func searchTextDidChange(_ text: String)
}

extension AgoraChatSearchResultController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = self.cellForRowAtIndexPathCompletion?(tableView, indexPath) {
            return cell
        }
        var cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "UITableViewCell")
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.canEditRowAtIndexPath?(tableView, indexPath) ?? false
    }
}

extension AgoraChatSearchResultController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return self.trailingSwipeActionsConfigurationForRowAtIndexPath?(tableView, indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.didSelectRowAtIndexPathCompletion?(tableView, indexPath)
    }
}

extension AgoraChatSearchResultController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        self.delegate?.searchBarWillBeginEditing(searchBar)
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            searchBar.resignFirstResponder()
            self.delegate?.searchBarSearchButtonClicked(searchBar)
            return false
        }
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.delegate?.searchTextDidChange(searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancelSearch()
        self.delegate?.searchBarCancelButtonAction(searchBar)
    }
    
    func cancelSearch() {
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.searchBar.showsCancelButton = false
        self.dismiss(animated: true)
    }
}
