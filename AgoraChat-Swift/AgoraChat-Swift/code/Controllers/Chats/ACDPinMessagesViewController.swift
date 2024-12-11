//
//  ACDPinMessagesViewController.swift
//  AgoraChat-Swift
//
//  Created by li xiaoming on 2024/3/15.
//

import UIKit

class ACDPinMessagesViewController: UIViewController {
    var selectMessageCompletion: ((String) -> Void)?
    var unpinMessageCompletion: ((String) -> Void)?
    var pinMessages: [AgoraChatMessage]? {
        didSet {
            self.pinText.text = pinMessages?.count == 1 ? "1 Pin Message" : "\(pinMessages?.count ?? 0) Pin messages"
            tableView.reloadData()
            moveMainView(pinMessages?.count ?? 0 == 0 )
        }
    }
    private let bgView = UIView()
    private let mainView = UIView()
    private let tableView = UITableView()
    private let pinIcon = UIImageView()
    private let pinText = UILabel()
    private let paddingView = UIView()
    private var isMin = true
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupSubViews()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapAction(_:)))
        bgView.addGestureRecognizer(tap)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePanAction(_:)))
        mainView.addGestureRecognizer(pan)

    }

    func setupSubViews() {
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        self.bgView.backgroundColor = UIColor.clear
        self.mainView.backgroundColor = UIColor.white
        self.pinIcon.image = UIImage(named: "pin")
        self.pinText.text = "1 pin Messages"
        self.paddingView.backgroundColor = .gray
        self.paddingView.layer.cornerRadius = 4
        tableView.separatorStyle = .none
        self.view.addSubview(bgView)
        self.view.addSubview(mainView)
        mainView.addSubview(pinIcon)
        mainView.addSubview(pinText)
        mainView.addSubview(tableView)
        mainView.addSubview(paddingView)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        bgView.frame = self.view.frame
        mainView.frame = CGRect(x: 0, y: 0, width: bgView.frame.width, height: 150)
        pinIcon.frame = CGRect(x: 20, y: 20, width: 20, height: 20)
        pinText.frame = CGRect(x: 50, y: 20, width: 200, height: 20)
        
        moveMainView(false)
    }
    override func viewDidLayoutSubviews() {
        tableView.frame = CGRect(x: 0, y: 50, width: mainView.frame.width, height: mainView.frame.height - 80)
        paddingView.frame = CGRect(x: (mainView.frame.width/2 - 30),y:mainView.frame.height - 15, width: 60 ,height:8)
    }
    
    func setPinMessages(messages: [AgoraChatMessage]) {
        self.pinMessages = messages
        let count = self.pinMessages?.count ?? 0
        self.pinText.text = count > 1 ? "\(count) pin Messages" : "1 pin Message"
        self.tableView.reloadData()
    }
    
    func unpinMessageAction(_ message: AgoraChatMessage) {
        let alertController = UIAlertController(title: "Confirm to remove pinned message?", message: nil, preferredStyle: .alert)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        let confirmAction = UIAlertAction(title: "Remove", style: .default) { [weak self] (_) in
            AgoraChatClient.shared().chatManager?.unpinMessage(message.messageId) { [weak self] (message, error) in
                if error == nil, let message = message {
                    self?.showHint("remove pinned message success")
                    self?.pinMessages?.removeAll(where: { msg in
                        msg.messageId == message.messageId
                    })
                    self?.tableView.reloadData()
                    if self?.mainView.frame.height != 60 + 90 {
                        self?.moveMainView(true)
                    }
                    self?.unpinMessageCompletion?(message.messageId)
                } else {
                    self?.showHint("remove pinned message failed, \(error?.errorDescription ?? "")")
                }
            }
    }

    alertController.addAction(confirmAction)

    self.present(alertController, animated: true, completion: nil)
    }
    
    func moveMainView(_ max: Bool) {
        var contentHeight: CGFloat = 0
        guard let pinMessages = self.pinMessages else {
            return
        }
        for message in pinMessages {
            contentHeight += message.contentHeight
        }
        let maxHeight: CGFloat = 400
        UIView.animate(withDuration: 0.25) { [weak self] in
            if max {
                self?.mainView.setHeight((contentHeight > maxHeight ? maxHeight : contentHeight) + 90)
            } else {
                self?.mainView.setHeight(60 + 90)
            }
        } completion: { (finished) in
        }
    }
    
    func exit() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
    
    @objc func handleTapAction(_ tap: UITapGestureRecognizer) {
        exit()
    }
    
    @objc func handlePanAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: mainView)
        if gestureRecognizer.state == .ended {
            if translation.y > 0 {
                if (self.pinMessages?.count ?? 0) > 1 {
                    self.isMin = false
                    moveMainView(true)
                }
            } else {
                if self.pinMessages?.count ?? 0 > 1 {
                    if self.isMin {
                        self.exit()
                    } else {
                        self.isMin = true
                        self.moveMainView(false)
                    }
                } else {
                    self.exit()
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ACDPinMessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.pinMessages?[indexPath.row].contentHeight ?? 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let message = pinMessages?[indexPath.row],
           let selectMessageCompletion = self.selectMessageCompletion {
            selectMessageCompletion(message.messageId)
        }
        exit()
    }
}

extension ACDPinMessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pinMessages?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: ACDPinMessageCell? = tableView.dequeueReusableCell(withIdentifier: "ACDPinMessageCell") as? ACDPinMessageCell
        if cell == nil {
            cell = ACDPinMessageCell(style: .default, reuseIdentifier: "ACDPinMessageCell")
        }
        if let message = self.pinMessages?[indexPath.row] {
            cell!.setMessage(message)
        }
        cell!.delegate = self
        return cell!
    }
}

extension ACDPinMessagesViewController: ACDPinMessageDelegate {
    func unpinMessage(_ message: AgoraChatMessage) {
        unpinMessageAction(message)
    }
}

extension AgoraChatMessage {
    var contentHeight: CGFloat {
        switch body.type {
        case .text,.combine,.voice,.file,.location:
            return 60
        case .image,.video:
            return 150
        default:
            return 60
        }
    }
}

extension UIView {
    func setHeight(_ height: CGFloat) {
        var frame2 = self.frame
        frame2.size.height = height
        self.frame = frame2
    }
}
