//
//  ForwardTargetsViewController.swift
//  AgoraChat-Demo
//
//  Created by 朱继超 on 2023/7/28.
//  Copyright © 2023 easemob. All rights reserved.
//

import UIKit

@objc final class AgoraPageContainer: UIView, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    private var controllers: [UIViewController]?

    private var nextViewController: UIViewController?
    
    private var indicators: [String] = []

    var index = 0 {
        didSet {
            DispatchQueue.main.async {
                if let vc = self.controllers?[self.index] {
                    self.pageController.setViewControllers([vc], direction: .forward, animated: false)
                }
            }
        }
    }
    
    private lazy var toolBar: PageContainerToolBar = {
        PageContainerToolBar(frame: CGRect(x: 0, y: 0, width: ScreenWidth, height: 44), choices: self.indicators) { [weak self] in
            self?.index = $0
        }.backgroundColor(.white)
    }()

    private lazy var pageController: UIPageViewController = {
        let page = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        page.view.backgroundColor = .clear
        page.dataSource = self
        page.delegate = self
        return page
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    @objc convenience init(frame: CGRect, viewControllers: [UIViewController],indicators: [String]) {
        self.init(frame: frame)
        self.indicators = indicators
        self.controllers = viewControllers
        self.pageController.setViewControllers([viewControllers[0]], direction: .forward, animated: false)
        self.addSubViews([self.toolBar,self.pageController.view])
        self.toolBar.translatesAutoresizingMaskIntoConstraints = false
        self.toolBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
        self.toolBar.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.toolBar.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        self.toolBar.topAnchor.constraint(equalTo: topAnchor).isActive = true
        
        self.pageController.view.translatesAutoresizingMaskIntoConstraints = false
        self.pageController.view.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        self.pageController.view.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        self.pageController.view.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        self.pageController.view.topAnchor.constraint(equalTo: topAnchor,constant: 44).isActive = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


}

extension AgoraPageContainer {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        self.controllers?[safe:self.index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        self.controllers?[safe:self.index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished, self.controllers?.count ?? 0 > 0 {
            for (idx, vc) in self.controllers!.enumerated() {
                if vc == self.nextViewController {
                    self.index = idx
                    break
                }
            }
            self.toolBar.scrollIndicator(to: self.index)
        } else {
            self.nextViewController = previousViewControllers.first
        }
    }

    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        self.nextViewController = pendingViewControllers.first
    }
}

extension Array {
    ///数组越界防护
    subscript(safe idx: Index) -> Element? {
        if idx < 0 { return nil }
        return idx < self.endIndex ? self[idx] : nil
    }
    
    subscript(safe range: Range<Int>) -> ArraySlice<Element>? {
        if range.startIndex < 0 { return nil }
        return range.endIndex <= self.endIndex ? self[range.startIndex...range.endIndex]:nil
    }
}
