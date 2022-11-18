//
//  ACDReportMessageViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/24.
//

import UIKit

class ACDReportMessageViewController: UIViewController {
    
    @IBOutlet weak var navigationView: ACDNormalNavigationView!
    @IBOutlet weak var tableView: UITableView!
    
    let reasonList = ["Adult".localized, "Racy".localized, "Other".localized]
    
    private let reportMessage: EaseMessageModel
    private var tagStr: String
    private var cellID: String?
    
    init(reportMessage: EaseMessageModel) {
        self.reportMessage = reportMessage
        self.tagStr = reasonList[0]
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        switch self.reportMessage.type {
        case .text:
            self.cellID = "ReportTextMessageCell"
        case .image, .video, .voice, .file:
            self.cellID = "ReportDocumentMessageCell"
        default:
            break
        }
        
        self.navigationView.leftLabel.text = "Message Report".localized
        self.navigationView.leftLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.navigationView.rightButton.setTitle("Done".localized, for: .normal)
        self.navigationView.rightButton.setTitleColor(UIColor.blue, for: .normal)
        self.navigationView.leftButtonHandle = { [unowned self] in
            self.backAction()
        }
        self.navigationView.rightButtonHandle = { [unowned self] in
            self.doneAction()
        }
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "ACDReportTextMessageCell", bundle: nil), forCellReuseIdentifier: "ReportTextMessageCell")
        self.tableView.register(UINib(nibName: "ACDReportDocumentMessageCell", bundle: nil), forCellReuseIdentifier: "ReportDocumentMessageCell")
        self.tableView.register(UINib(nibName: "ACDReportMessageTagCell", bundle: nil), forCellReuseIdentifier: "ReportMessageTagCell")
        self.tableView.register(UINib(nibName: "ACDReportMessageReasonCell", bundle: nil), forCellReuseIdentifier: "ReportMessageReasonCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func doneAction() {
        let vc = UIAlertController(title: "Confirm to Report?".localized, message: nil, preferredStyle: .alert)
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        vc.addAction(UIAlertAction(title: "Confirm".localized, style: .default, handler: { _ in
            self.reportAction()
        }))
        self.present(vc, animated: true)
    }

    private func reportAction() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        guard let cell = self.tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? ACDReportMessageReasonCell, let reason = cell.textView?.text else {
            return
        }
        AgoraChatClient.shared().chatManager?.reportMessage(withId: self.reportMessage.message.messageId, tag: self.tagStr, reason: reason, completion: { error in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let error = error {
                self.showHint(error.errorDescription)
            } else {
                let vc = ACDReportMessageSucceedViewController()
                vc.doneButtonHandle = {
                    self.dismiss(animated: true) {
                        self.backAction()
                    }
                }
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true) {
                    self.tableView.isHidden = true
                }
            }
        })
    }
    
    private func showTagsMenu() {
        self.view.endEditing(true)
        let vc = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for i in self.reasonList {
            vc.addAction(UIAlertAction(title: i, style: .default, handler: { _ in
                self.tagStr = i
                self.tableView.reloadData()
            }))
        }
        vc.addAction(UIAlertAction(title: LocalizedString.Cancel, style: .cancel))
        self.present(vc, animated: true)
    }
}

extension ACDReportMessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            if let cellID = self.cellID {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
                if let cell = cell as? ACDReportTextMessageCell {
                    cell.model = self.reportMessage
                } else if let cell = cell as? ACDReportDocumentMessageCell {
                    cell.model = self.reportMessage
                }
                return cell
            }
        } else if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReportMessageTagCell", for: indexPath)
            if let cell = cell as? ACDReportMessageTagCell {
                cell.tagLabel?.text = self.tagStr
            }
            return cell
        } else if indexPath.row == 2 {
            return tableView.dequeueReusableCell(withIdentifier: "ReportMessageReasonCell", for: indexPath)
        }
        return UITableViewCell()
    }
}

extension ACDReportMessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            self.showTagsMenu()
        }
    }
}
