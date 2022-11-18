//
//  ACDWebViewController.swift
//  AgoraChat-Swift
//
//  Created by 冯钊 on 2022/10/13.
//

import WebKit

class ACDWebViewController: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webView: WKWebView!
    
    private let request: URLRequest
    
    init(url: URL) {
        self.request = URLRequest(url: url)
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init?(urlString: String) {
        if let url = URL(string: urlString) {
            self.init(url: url)
        } else {
            return nil
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webView.navigationDelegate = self
        self.webView.addObserver(self, forKeyPath: "estimatedProgress", context: nil)
        self.webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        self.webView.load(self.request)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            self.progressView.progress = Float(webView.estimatedProgress)
            if webView.estimatedProgress >= 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
                    self.progressView.progress = 0
                }
            }
        } else if keyPath == "title" {
            self.navigationItem.title = webView.title
        }
    }
    
    deinit {
        self.webView.removeObserver(self, forKeyPath: "estimatedProgress")
        self.webView.removeObserver(self, forKeyPath: "title")
    }
}

extension ACDWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.progressView.progress = 0
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.progressView.progress = 0
    }
}
