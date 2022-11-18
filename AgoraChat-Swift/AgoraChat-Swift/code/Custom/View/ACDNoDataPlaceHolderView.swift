//
//  ACDNoDataPlaceHolderView.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/28.
//

import UIKit
import SnapKit

class ACDNoDataPlaceHolderView: UIView {

    let noDataImageView = UIImageView()
    let prompt = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.noDataImageView.contentMode = .scaleAspectFit
        
        self.prompt.textColor = Color_C9C9C9
        self.prompt.font = UIFont.systemFont(ofSize: 14)
        self.prompt.textAlignment = .center
        self.prompt.text = "No Data".localized
        
        self.addSubview(self.noDataImageView)
        self.addSubview(self.prompt)
        
        self.noDataImageView.snp.makeConstraints { make in
            make.top.equalTo(self).offset(5.0)
            make.centerX.equalTo(self)
        }
        
        self.prompt.snp.makeConstraints { make in
            make.top.equalTo(self.noDataImageView.snp.bottom).offset(30.0)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(14.0)
            make.bottom.equalTo(self)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
