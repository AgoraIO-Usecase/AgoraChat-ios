//
//  AboutAgoraChatController.swift
//  AgoraChat-Swift
//
//  Created by 朱继超 on 2024/3/6.
//

import UIKit
import chat_uikit

final class AboutAgoraChatController: UIViewController {

    private let infos = [
        ["title":"Agora Chat Documentation".localized(),"content":"docs.agora.io/en/agora-chat","destination":"docs.agora.io/en/agora-chat"],
        ["title":"Contact Sales".localized(),"content":"agora.io/en/talk-to-us/","destination":"https://agora.io/en/talk-to-us/"],
        ["title":"Demo App Github Repo".localized(),"content":"github.com/AgoraIO-Usecase/AgoraChat-ios","destination":"https://github.com/AgoraIO-Usecase/AgoraChat-ios"],
        ["title":"More".localized(),"content":"agora.io","destination":"https://agora.io"]
    ]
    
    private lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight), textAlignment: .left, rightTitle: nil)
    }()
    
     private lazy var header: AboutAgoraChatHeader = {
        AboutAgoraChatHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 221))
    }()
    
    private lazy var menuList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: NavigationHeight, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), style: .plain).tableFooterView(UIView()).tableHeaderView(self.header).separatorStyle(.none).dataSource(self).delegate(self).rowHeight(54).backgroundColor(.clear)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubViews([self.navigation,self.menuList])
        self.navigation.title = "About".localized()
        self.navigation.clickClosure = { [weak self] _,_ in
            self?.navigationController?.popViewController(animated: true)
        }
        // Do any additional setup after loading the view.
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
    }
    
    

}

extension AboutAgoraChatController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.infos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "AboutAgoraChatCell") as? AboutAgoraChatCell
        if cell == nil {
            cell = AboutAgoraChatCell(style: .subtitle, reuseIdentifier: "AboutAgoraChatCell")
        }
        cell?.selectionStyle =  .none
        cell?.textLabel?.text = self.infos[safe:indexPath.row]?["title"]
        cell?.textLabel?.font = UIFont.theme.labelLarge
        cell?.detailTextLabel?.text = self.infos[safe:indexPath.row]?["content"]
        return cell ?? AboutAgoraChatCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let detail = self.infos[safe:indexPath.row]?["destination"] ?? ""
        self.openURL(urlString: detail)
    }
    
    private func openURL(urlString: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    
}

extension AboutAgoraChatController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.menuList.reloadData()
    }
}
