//
//  ForwardTargetsToolBar.swift
//  AgoraChat-Demo
//
//  Created by 朱继超 on 2023/7/28.
//  Copyright © 2023 easemob. All rights reserved.
//

import UIKit

@objc final class PageContainerToolBar: UIView {
    
    var datas: [String] = []
    
    var chooseClosure: ((Int)->())?
    
    lazy var indicator: UIView = {
        UIView(frame: CGRect(x: 16, y: 8, width: 114, height: self.frame.height-16)).cornerRadius(14).backgroundColor(UIColor(0xD8D8D8))
    }()
    
    lazy var layout: UICollectionViewFlowLayout = {
        let flow = UICollectionViewFlowLayout()
        flow.scrollDirection = .horizontal
        flow.itemSize = CGSize(width: 114, height: self.frame.height-16)
        flow.minimumInteritemSpacing = 0
        flow.minimumLineSpacing = 0
        return flow
    }()
    
    lazy var choicesBar: UICollectionView = {
        UICollectionView(frame: CGRect(x: 16, y: 8, width: self.frame.width-32, height: self.frame.height-16), collectionViewLayout: self.layout).dataSource(self).delegate(self).registerCell(ForwardChoiceBarCell.self, forCellReuseIdentifier: "ForwardChoiceBarCell").showsHorizontalScrollIndicator(false).backgroundColor(.clear)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @objc public convenience init(frame: CGRect, choices: [String], selectedClosure: @escaping (Int)->()) {
        self.init(frame: frame)
        self.chooseClosure = selectedClosure
        self.datas = choices
        self.addSubViews([self.indicator,self.choicesBar])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PageContainerToolBar: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.datas.count
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForwardChoiceBarCell", for: indexPath) as? ForwardChoiceBarCell else {
            return ForwardChoiceBarCell()
        }
        cell.refresh(text: self.datas[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.25) {
            self.indicator.frame = CGRect(x: 16+CGFloat(indexPath.row)*114, y: 8, width: 114, height: (self.frame.height-16))
        }
        self.chooseClosure?(indexPath.row)
    }
    
    @objc public func scrollIndicator(to index: Int) {
        UIView.animate(withDuration: 0.25) {
            self.indicator.frame = CGRect(x: 16+CGFloat(index)*114, y: 8, width: 114, height: (self.frame.height-16))
        }
    }


}




@objc final class ForwardChoiceBarCell: UICollectionViewCell {
    
    lazy var content: UILabel = {
        UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)).textAlignment(.center).textColor(.darkText).font(.systemFont(ofSize: 14, weight: .semibold)).backgroundColor(.clear)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        self.contentView.addSubview(self.content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.content.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)
    }
    
    func refresh(text: String) {
        self.content.text = text
    }
}
