//
//  AgoraChatThreadListNavgation.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/25.
//

import UIKit

class AgoraChatThreadListNavgation: UIView {

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var moreButton: UIButton!
    @IBOutlet private weak var titleLabelCenterYConstraint: NSLayoutConstraint!
    
    private var view: UIView?
    
    var backHandle: (() -> Void)?
    var moreHandle: (() -> Void)?
    
    var title: String? {
        didSet {
            self.titleLabel.text = title
            self.titleLabelCenterYConstraint.constant = self.detail?.count ?? 0 > 0 ? -12 : 0
        }
    }
    var detail: String? {
        didSet {
            self.detailLabel.text = detail
            self.titleLabelCenterYConstraint.constant = self.detail?.count ?? 0 > 0 ? -12 : 0
        }
    }
    var isMoreHidden = true {
        didSet {
            self.moreButton.isHidden = isMoreHidden
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        if let view = Bundle.main.loadNibNamed("AgoraChatThreadListNavgation", owner: self)?.first as? UIView {
            self.view = view
            self.addSubview(view)
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        if let view = Bundle.main.loadNibNamed("AgoraChatThreadListNavgation", owner: self)?.first as? UIView {
            self.view = view
            self.addSubview(view)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.view?.frame = self.bounds
    }
    
    @IBAction func backAction() {
        self.backHandle?()
    }
    
    @IBAction func moreAction() {
        self.moreHandle?()
    }
}
