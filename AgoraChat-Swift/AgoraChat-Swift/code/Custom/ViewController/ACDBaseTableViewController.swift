//
//  ACDBaseTableViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/28.
//

import UIKit

class ACDBaseTableViewController: UIViewController {

    let table = UITableView(frame: .zero, style: .plain)
    
    private var canRefresh = false
    private var isRefreshing = false
    private var isLoadingMore = false
    private var canLoadMore = false
    private var isDragging = false
    
    lazy var refreshView: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    lazy var loadFooterView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        view.backgroundColor = .clear
        
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "Loading".localized
        label.sizeToFit()
        
        label.center = CGPoint(x: view.frame.midX + 5 + activityIndicator.frame.width / 2, y: view.frame.midY)
        activityIndicator.center = CGPoint(x: label.frame.minX - 5 - activityIndicator.frame.width / 2, y: view.frame.midY)
        
        view.addSubview(activityIndicator)
        view.addSubview(label)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.table.separatorStyle = .none
        self.table.cellLayoutMarginsFollowReadableWidth = false
        self.table.dataSource = self
        self.table.delegate = self
        self.table.backgroundView = nil
        self.table.rowHeight = 44.0
        self.view.addSubview(self.table)
        self.table.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }
    
    func useRefresh() {
        self.canRefresh = true
        self.isRefreshing = false
        if self.refreshView.superview == nil {
            self.table.insertSubview(self.refreshView, at: 0)
        }
    }
    
    func useLoadMore() {
        self.canLoadMore = true
        self.isLoadingMore = false
        if self.table.tableFooterView == nil {
            self.table.tableFooterView = self.loadFooterView
        }
    }
    
    @objc private func refresh() {
        self.didStartRefresh()
        self.isRefreshing = true
    }
    
    func loadMore() {
        if self.isLoadingMore {
            return
        }
        self.isLoadingMore = true
        self.didStartLoadMore()
    }
    
    func endRefresh() {
        self.refreshView.endRefreshing()
        self.isRefreshing = false
    }
    
    func endLoadMore() {
        self.isLoadingMore = false
    }
    
    func didStartRefresh() {
        
    }
    
    func didStartLoadMore() {
        
    }
    
    func loadMoreCompleted() {
        self.isLoadingMore = false
        self.canLoadMore = false
        if self.table.tableFooterView == self.loadFooterView {
            self.table.tableFooterView = nil;
        }
    }
}

extension ACDBaseTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension ACDBaseTableViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !self.isDragging && !self.isRefreshing && !self.isLoadingMore && self.canLoadMore {
            let position = scrollView.contentSize.height - scrollView.frame.height - scrollView.contentOffset.y
            if position < 44 {
                self.loadMore()
            }
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.isRefreshing {
            return
        }
        self.isDragging = false
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isDragging = true
    }
}
