//
//  ACDPrivacyViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/13.
//

import UIKit
import SnapKit

class ACDPrivacyViewController: ACDBaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.leftBarButtonItem = ACDUtil.customLeftButtonItem(title: "Privacy".localized, action: #selector(back), target: self)
        
        self.view.backgroundColor = Color_F9F9F9

        self.table.isScrollEnabled = false
        self.table.rowHeight = 54
        self.table.tableFooterView = UIView()
        self.table.backgroundColor = .white
        self.table.separatorStyle = .none
        self.table.snp.remakeConstraints { make in
            make.top.left.right.bottom.equalTo(self.view)
        }
        self.table.register(UINib(nibName: "ACDSubDetailCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func goBlockListPage() {
        let vc = ACDBlockListViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        if let cell = cell as? ACDSubDetailCell {
            cell.showSubDetailLabel = false
            cell.nameLabel.text = "Blocked List".localized
            cell.tapCellHandle = { [unowned self] in
                self.goBlockListPage()
            }
        }
        
        return cell
    }
}
