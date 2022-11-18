//
//  ACDModifyAvatarViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/13.
//

import UIKit

class ACDModifyAvatarViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var itemArray: [String] = []
    private var selectedIndexPath: IndexPath?
    
    var selectedHandle: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized, style: .plain, target: self, action: #selector(doneAction))
        
        let itemWidth = (UIScreen.main.bounds.width - 10) / 2
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.sectionInset = UIEdgeInsets.zero
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(UINib(nibName: "ACDAvatarCollectionCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        self.view.addSubview(self.collectionView)
        
        for i in 1..<8 {
            let imageName = "defatult_avatar_\(i)"
            self.itemArray.append(imageName)
        }
        self.collectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.collectionView.frame = self.view.bounds
        if let layout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            let itemWidth = (self.view.bounds.width - 10) / 2
            layout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc private func doneAction() {
        if let selectedIndexPath = self.selectedIndexPath, let selectedHandle = self.selectedHandle {
            let imageName = self.itemArray[selectedIndexPath.item]
            selectedHandle(imageName)
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension ACDModifyAvatarViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        if let cell = cell as? ACDAvatarCollectionCell {
            cell.iconImageView.image = UIImage(named: self.itemArray[indexPath.item])
            cell.isSelect = self.selectedIndexPath?.item == indexPath.item
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
        collectionView.reloadData()
    }
}
