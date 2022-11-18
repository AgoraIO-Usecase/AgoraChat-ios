//
//  AgoraChatThreadEditViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/25.
//

import UIKit

class AgoraChatThreadEditViewController: UIViewController {

    @IBOutlet weak var navBar: AgoraChatThreadListNavgation!
    @IBOutlet weak var threadNameField: UITextField!
    
    private let threadId: String
    
    init(threadId: String) {
        self.threadId = threadId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBar.title = "Edit Thread".localized
        self.navBar.backHandle = { [unowned self] in
            self.navigationController?.popViewController(animated: true)
        }
        
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        let iconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 36, height: 36))
        iconImageView.image = UIImage(named: "groupThread")
        leftView.addSubview(iconImageView)
        self.threadNameField.leftView = leftView
        self.threadNameField.leftViewMode = .always
        self.threadNameField.clearButtonMode = .whileEditing
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func doneAction() {
        if self.threadNameField.text?.count ?? 0 <= 0 {
            self.showHint(String(format: "%@ can't be null".localized, "'Name'"))
            return
        }
        self.view.endEditing(true)
        AgoraChatClient.shared().threadManager?.updateChatThreadName(self.threadNameField.text!, threadId: self.threadId, completion: { error in
            if let error = error {
                self.showHint(error.errorDescription)
            } else {
                self.navigationController?.popViewController(animated: true)
            }
        })
    }
}
