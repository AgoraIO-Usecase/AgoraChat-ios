//
//  ForwardTargetsViewController.swift
//  AgoraChat-Demo
//
//  Created by 朱继超 on 2023/7/28.
//  Copyright © 2023 easemob. All rights reserved.
//

import UIKit

@objc final class ForwardTargetsViewController: UIViewController {
    
    private var controllers: [UIViewController] = []
    
    private var indicators: [String] = []
    
    lazy var titleLabel: UILabel = {
        UILabel(frame: CGRect(x: 84, y: 11, width: ScreenWidth-168, height: 22)).font(.systemFont(ofSize: 20, weight: .semibold)).textAlignment(.center).textColor(.darkText)
    }()
        
    lazy var close: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: ScreenWidth - 84, y: 8, width: 76, height: 28)).addTargetFor(self, action: #selector(closePage), for: .touchUpInside).title("Close", .normal).textColor(UIColor(0x005FFF), .normal).font(.systemFont(ofSize: 16, weight: .medium))
    }()
    
    lazy var container: AgoraPageContainer = {
        AgoraPageContainer(frame: CGRect(x: 0, y: 44, width: ScreenWidth, height: ScreenHeight), viewControllers: self.controllers, indicators: self.indicators).backgroundColor(.white)
    }()
    
    @objc public convenience init(viewControllers: [UIViewController], indicators: [String]) {
        self.init()
        self.controllers = viewControllers
        self.indicators = indicators
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleLabel.text = "Forward to"
        self.view.backgroundColor = .white
        self.view.addSubViews([self.close,self.titleLabel,self.container])
        // Do any additional setup after loading the view.
    }
    
    @objc private func closePage() {
        if (self.navigationController != nil) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

}

