//
//  AgoraAboutViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/12.
//

import UIKit

class AgoraAboutViewController: UITableViewController {

    @IBOutlet weak var versionLabel: UILabel!
    
    @IBOutlet weak var sdkVersionLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButton = UIButton(frame: CGRect(x: 0, y: 0, width: 8, height: 15))
        backButton.setImage(UIImage(named: "black_goBack"), for: .normal)
        backButton.setTitle("About".localized, for: .normal)
        backButton.setTitleColor(.black, for: .normal)
        backButton.addTarget(self, action: #selector(back), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        let ver = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        self.versionLabel.text = "AgoraChat v:\(ver)"
        
        let sdkVer = "AgoraChat v:\(AgoraChatClient.shared().version)"
        self.sdkVersionLabel.text = sdkVer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc private func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 2 {
            if let webVC = ACDWebViewController(urlString: "https://www.agora.io/en") {
                self.navigationController?.pushViewController(webVC, animated: true)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
}
