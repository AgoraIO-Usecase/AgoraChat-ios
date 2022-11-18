//
//  ACDAddContactViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/17.
//

import UIKit
import AgoraChat

@objcMembers
class ACDAddContactViewController: UIViewController {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var contactInfoHeaderView: ACDInfoHeaderView!
    
    private var model: AgoraUserModel
    
    init(model: AgoraUserModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.updatePresenceStatus()
        self.loadContactInfo()
    }
    
    private func updatePresenceStatus() {
        AgoraChatClient.shared().presenceManager?.fetchPresenceStatus([self.model.hyphenateId], completion: { presences, error in
            let status = PresenceManager.fetchStatus(presence: presences?.first)
            if let imageName = PresenceManager.whiteStrokePresenceImagesMap[status] {
                DispatchQueue.main.async {
                    self.contactInfoHeaderView.avatarImageView.presenceImage = UIImage(named: imageName)
                }
            }
        })
    }
    
    private func loadContactInfo() {
        self.contactInfoHeaderView.userIdLabel.text = "\("AgoraID".localized): \(self.model.hyphenateId)"
        self.contactInfoHeaderView.nameLabel.text = self.model.showName
        self.contactInfoHeaderView.avatarImageView.image = self.model.defaultAvatarImage
        self.contactInfoHeaderView.avatarImageView.image = self.model.defaultAvatarImage
        self.contactInfoHeaderView.avatarImageView.setImage(withUrl: self.model.avatarURLPath)
    }

    @IBAction func displayAction() {
        self.dismiss(animated: true)
    }
    
    @IBAction func applyContactAction() {
        AgoraChatClient.shared().contactManager?.addContact(self.model.hyphenateId, message: nil, completion: { username, error in
            if let error = error {
                self.showAlert(message: error.errorDescription)
                self.addButton.isEnabled = true
            } else {
                self.addButton.isEnabled = false
            }
        })
    }
}
