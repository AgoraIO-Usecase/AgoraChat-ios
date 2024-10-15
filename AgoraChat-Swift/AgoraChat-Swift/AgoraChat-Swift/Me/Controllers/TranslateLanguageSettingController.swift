//
//  TranslateLanguageSettingController.swift
//  AgoraChat-Swift
//
//  Created by 朱继超 on 2024/6/11.
//

import UIKit
import chat_uikit


final class TranslateLanguageSettingController: UIViewController {

    @UserDefault("EaseChatDemoTranslateTargetLanguage", defaultValue: "zh-Hans") var language: String

    private var infos = [MessageTranslateTargetLanguage]()
    
    
    private lazy var navigation: EaseChatNavigationBar = {
        EaseChatNavigationBar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: NavigationHeight),textAlignment: .left)
    }()
    
    private lazy var infoList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), style: .plain).separatorStyle(.none).tableFooterView(UIView()).backgroundColor(.clear).delegate(self).dataSource(self).rowHeight(54)
    }()
    
    public private(set) lazy var loadingView: LoadingView = {
        LoadingView(frame: self.view.bounds)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubViews([self.navigation,self.infoList,self.loadingView])
        self.navigation.title = "translate_language_setting".localized()
        self.navigation.clickClosure = { [weak self] in
            consoleLogInfo("\($1?.row ?? 0)", type: .debug)
            switch $0 {
            case .back:
                self?.navigationController?.popViewController(animated: true)
            default:
                break
            }
            
        }
        // Do any additional setup after loading the view.
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.requestTranslateLanguage()
    }

    private func requestTranslateLanguage() {
        self.loadingView.startAnimating()
        ChatClient.shared().chatManager?.fetchSupportedLanguages({ [weak self] (languages, error) in
            if let languages = languages {
                DispatchQueue.main.async {
                    self?.loadingView.stopAnimating()
                    self?.infos = languages
                    self?.infoList.reloadData()
                }
            }
        })
    }
}

extension TranslateLanguageSettingController: UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.infos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "LanguageCell") as? LanguageCell
        if cell == nil {
            cell = LanguageCell(style: .default, reuseIdentifier: "LanguageCell")
        }
        if let title = self.infos[safe:indexPath.row] {
            cell?.content.text = title.languageNativeName
            if self.language == title.languageCode {
                cell?.checkbox.isSelected = true
            } else {
                cell?.checkbox.isSelected = false
            }
        }
        cell?.accessoryType = .none
        cell?.selectionStyle = .none
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let selectedLanguage = self.infos[safe:indexPath.row] {
            self.language = selectedLanguage.languageCode
            Appearance.chat.targetLanguage = LanguageType(rawValue: selectedLanguage.languageCode) ?? Appearance.chat.targetLanguage
        }
        self.infoList.reloadData()
    }
}

extension TranslateLanguageSettingController: ThemeSwitchProtocol {
    func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor(style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98)
    }
}
