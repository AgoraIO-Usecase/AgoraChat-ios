# chat_uikit for iOS

This guide introduce for chat_uikit(V2.0.0).The new chat_uikit is committed to providing developers with an efficient, plug-and-play, and highly customized UI component library, helping to build comprehensive, beautifully designed IM applications that can easily meet most instant messaging scenarios. Please download the sample to experience it.。

# Demo

If you want to experience the functions of chat_uikit, you can scan the following QR code to try the demo.

![Demo](./AgoraChat-Swift/Documentation/demo.png)

# chat_uikit Guide

## Introduction

This guide introduces the overview and usage examples of the chat_uikit framework in iOS development, and describes the various components and functions of this UIKit, so that developers can have a good understanding of UIKit and use it effectively.

## Table of contents

- [Development Environment](#development-environment)
- [Installation](#installation)
- [Structure](#structure)
- [Quick Start](#quick-start)
- [Advance Usage](#advance-usage)
- [Customize](#customize)
- [Theme](#theme)
- [Design Guide](#design-guide)
- [Documentation](#documentation)
- [Contribution](#dontribution)
- [LICENSE](#license)

# Development-Environment

- Xcode 15.0 and above. The reason is that some audio detection AVAudioApplication api is used in UIKit to adapt to iOS17 and above.
- Minimum supported system: iOS 13.0
- Please make sure that your project has set a valid developer signature

# Installation

You can install chat_uikit as a dependency of your Xcode project using CocoaPods.

## CocoaPods

Add the following dependencies to podfile

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'

target 'YourTarget' do
  use_frameworks!

  pod 'chat_uikit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
```

Then run ``cd`` command to the folder where the podfile is located in the terminal and execute

```
    pod install
```

>⚠️Xcode15 new project compilation error ```Sandbox: rsync.samba(47334) deny(1) file-write-create...```

> Solution: Search for ```ENABLE_USER_SCRIPT_SANDBOXING``` in Build Setting and change ```User Script Sandboxing``` to ```NO```


# Structure

### Basic project structure of chat_uikit.

```
Classes
├─ Service // Basic service component.
│ ├─ Client // chat_uikit user main initialization, login, cache and other APIs.
│ ├─ Protocol // Business protocol.
│ │ ├─ ConversationService // Conversation protocol. Including various processing operations on the conversation.
│ │ ├─ ContactService // Contact protocol. Including subsequent contact addition and deletion operations.
│ │ ├─ ChatService // Chat protocol. Including various processing operations on messages.
│ │ ├─ UserService // User login protocol. Including user login and socket connection status change.
│ │ ├─ MultiService // Multi-device notification protocol. Including single group chat, conversation, contact, member change, etc.
│ │ └─ GroupService // Implement group chat management protocol. Including joining and leaving the group and editing group information, etc.
│ └─ Implement // Implementation components of the above corresponding protocols.
│
└─ UI // Basic UI components, without business.
├─ Resource // Images or localization files.
├─ Component // UI modules containing specific business. Some functional UI components in single group chat UIKit.
│ ├─ Chat // Container for all chat views.
│ ├─ Contact // Container for contacts, groups and their details.
│ └─ Conversation // Container for conversation list.
└─ Core
├─ UIKit // Some common UIKit components and custom components and some UI-related tool classes.
├─ Foundation // Logs and some audio conversion tool classes.
├─ Theme // Theme-related components, including colors, fonts, skinning protocols and their components.
└─ Extension // Some convenient system class extensions.
```

# Quick Start

Refer to the following steps to create an iOS app in Xcode, and set up the following:

* Fill in chat_uikitQuickStart as the Product Name.

* Set Organization Identifier to your identifier.

* Select Storyboard as the User Interface.

* Select your favorite development language as the Language.

* Add permissions Add relevant permissions in the project's `info.plist`:

Add related privileges in the `info.plist` project:

```
Privacy - Photo Library Usage Description //相册权限    Album privileges.
Privacy - Microphone Usage Description //麦克风权限     Microphone privileges.
Privacy - Camera Usage Description //相机权限    Camera privileges.
```

### First Step：Initialize chat_uikit

```Swift
import chat_uikit

@UIApplicationMain
class AppDelegate：UIResponder，UIApplicationDelegate {

     var window：UIWindow？

     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         // 您可以在应用程序加载时或使用之前初始化 chat_uikit。
         // 需要传入App Key。
         // 获取App Key，请访问
         // https://docs-im-beta.easemob.com/product/enable_and_configure_IM.html#%E8%8E%B7%E5%8F%96%E7%8E%AF%E4%BF%A1%E5%8D%B3%E6%97%B6%E9%80%9A%E8%AE%AF-im-%E7%9A%84%E4%BF%A1%E6%81%AF
         let error = EaseChatUIKitClient.shared.setup(appKey: "Appkey")
     }
}
```

### 第2步：登录

``` Swift
public final class YourAppUser: NSObject, EaseProfileProtocol {

    var id: String = ""
    
    var remark: String = ""
    
    var selected: Bool = false
    
    var nickname: String = ""
    
    var avatarURL: String = ""
    
    public func toJsonObject() -> Dictionary<String, Any>? {
        ["ease_chat_uikit_user_info":["nickname":self.nickname,"avatarURL":self.avatarURL,"userId":self.id]]
    }

}
// 使用当前用户对象符合`EaseProfileProtocol`协议的用户信息登录chat_uikit。
// token生成参见快速开始中登录步骤中链接。
// 需要从您的应用服务器获取token。 您也可以使用控制台生成的临时Token登录。
// 在控制台生成用户和临时用户 token，请参见
// https://docs-im-beta.easemob.com/product/enable_and_configure_IM.html#%E5%88%9B%E5%BB%BA-im-%E7%94%A8%E6%88%B7。
  EaseChatUIKitClient.shared.login(user: YourAppUser(), token: ExampleRequiredConfig.chatToken) { error in 
 }
```

### 第三步：创建聊天页面

```Swift
        // 在Console中创建一个新用户，将这个用id复制后传入下面构造方法参数中，跳转页面即可。
        let vc = ComponentsRegister.shared.MessageViewController.init(conversationId: <#用户id#>, chatType: .chat)
        //或者push或者present都可
        vc.modalPresentationStyle = .fullScreen
        ControllerStack.toDestination(vc: vc)

```

# Advance Usage

以下是进阶用法的部分示例。会话列表页面、消息列表页、联系人列表均可分开使用。

## 1.初始化单群聊UIKit
相比于上面快速开始的单群聊UIKit初始化这里多了ChatOptions的参数，主要是对SDK中是否打印log以及是否自动登录，是否默认使用用户属性的开关配置。ChatOptions即IMSDK的Option类，内中有诸多开关属性可参见环信官网IMSDK文档
```Swift
let error = EaseChatUIKitClient.shared.setup(option: ChatOptions(appkey: appKey))
```

## 2.登录

```Swift
public final class YourAppUser: NSObject, EaseProfileProtocol {

            public func toJsonObject() -> Dictionary<String, Any>? {
        ["ease_chat_uikit_user_info":["nickname":self.nickname,"avatarURL":self.avatarURL,"userId":self.id]]
    }
    
    
    public var id: String = ""
        
    public var nickname: String = ""
        
    public var selected: Bool = false
    
    public override func setValue(_ value: Any?, forUndefinedKey key: String) {
        
    }

    public var avatarURL: String = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_1.png"

}
// 使用当前用户对象符合`EaseProfileProtocol`协议的用户信息登录chat_uikit。
// token生成参见快速开始中登录步骤中链接。
 EaseChatUIKitClient.shared.login(user: YourAppUser(), token: ExampleRequiredConfig.chatToken) { error in 
 }
```

## 3.chat_uikitContext中的Provider

- 注: 仅用于会话列表以及联系人列表,在只是用快速开始进入聊天页面时不需要实现Provider

Provider是一个数据提供者，当会话列表展示并且滑动减速时候，chat_uikit会向你请求一些当前屏幕上要显示会话的展示信息例如头像昵称等。下面是Provider的具体示例以及用法。

```Swift
    private func setupDataProvider() {
        //userProfileProvider为用户数据的提供者，使用协程实现与userProfileProviderOC不能同时存在userProfileProviderOC使用闭包实现
        EaseChatUIKitContext.shared?.userProfileProvider = self
        EaseChatUIKitContext.shared?.userProfileProviderOC = nil
        //groupProvider原理同上
        EaseChatUIKitContext.shared?.groupProfileProvider = self
        EaseChatUIKitContext.shared?.groupProfileProviderOC = nil
    }
        //继承注册后的自定义类还可以调用ViewModel的registerEventsListener方法监听相关事件

//MARK: - EaseProfileProvider for conversations&contacts usage.
//For example using conversations controller,as follows.
extension MainViewController: EaseProfileProvider,EaseGroupProfileProvider {
    //MARK: - EaseProfileProvider
    func fetchProfiles(profileIds: [String]) async -> [any chat_uikit.EaseProfileProtocol] {
        return await withTaskGroup(of: [chat_uikit.EaseProfileProtocol].self, returning: [chat_uikit.EaseProfileProtocol].self) { group in
            var resultProfiles: [chat_uikit.EaseProfileProtocol] = []
            group.addTask {
                var resultProfiles: [chat_uikit.EaseProfileProtocol] = []
                let result = await self.requestUserInfos(profileIds: profileIds)
                if let infos = result {
                    resultProfiles.append(contentsOf: infos)
                }
                return resultProfiles
            }
            //Await all task were executed.Return values.
            for await result in group {
                resultProfiles.append(contentsOf: result)
            }
            return resultProfiles
        }
    }
    //MARK: - EaseGroupProfileProvider
    func fetchGroupProfiles(profileIds: [String]) async -> [any chat_uikit.EaseProfileProtocol] {
        
        return await withTaskGroup(of: [chat_uikit.EaseProfileProtocol].self, returning: [chat_uikit.EaseProfileProtocol].self) { group in
            var resultProfiles: [chat_uikit.EaseProfileProtocol] = []
            group.addTask {
                var resultProfiles: [chat_uikit.EaseProfileProtocol] = []
                let result = await self.requestGroupsInfo(groupIds: profileIds)
                if let infos = result {
                    resultProfiles.append(contentsOf: infos)
                }
                return resultProfiles
            }
            //Await all task were executed.Return values.
            for await result in group {
                resultProfiles.append(contentsOf: result)
            }
            return resultProfiles
        }
    }
    
    private func requestUserInfos(profileIds: [String]) async -> [EaseProfileProtocol]? {
        var unknownIds = [String]()
        var resultProfiles = [EaseProfileProtocol]()
        for profileId in profileIds {
            if let profile = chat_uikitContext.shared?.userCache?[profileId] {
                if profile.nickname.isEmpty {
                    unknownIds.append(profile.id)
                } else {
                    resultProfiles.append(profile)
                }
            } else {
                unknownIds.append(profileId)
            }
        }
        if unknownIds.isEmpty {
            return resultProfiles
        }
        let result = await ChatClient.shared().userInfoManager?.fetchUserInfo(byId: unknownIds)
        if result?.1 == nil,let infoMap = result?.0 {
            for (userId,info) in infoMap {
                let profile = EaseChatProfile()
                let nickname = info.nickname ?? ""
                profile.id = userId
                profile.nickname = nickname
                if let remark = ChatClient.shared().contactManager?.getContact(userId)?.remark {
                    profile.remark = remark
                }
                profile.avatarURL = info.avatarUrl ?? ""
                resultProfiles.append(profile)
                if (chat_uikitContext.shared?.userCache?[userId]) != nil {
                    profile.updateFFDB()
                } else {
                    profile.insert()
                }
                chat_uikitContext.shared?.userCache?[userId] = profile
            }
            return resultProfiles
        }
        return []
    }
    
    private func requestGroupsInfo(groupIds: [String]) async -> [EaseProfileProtocol]? {
        var resultProfiles = [EaseProfileProtocol]()
        let groups = ChatClient.shared().groupManager?.getJoinedGroups() ?? []
        for groupId in groupIds {
            if let group = groups.first(where: { $0.groupId == groupId }) {
                let profile = EaseChatProfile()
                profile.id = groupId
                profile.nickname = group.groupName
                profile.avatarURL = group.settings.ext
                resultProfiles.append(profile)
                chat_uikitContext.shared?.groupCache?[groupId] = profile
            }

        }
        return resultProfiles
    }
}
```

## 4.初始化聊天页面

聊天页面中大部分对消息的处理以及页面处理逻辑均可override、当然也包括ViewModel

```Swift
        // 在Console中创建一个新用户，将这个用id复制后传入下面构造方法参数中，跳转页面即可。
        let vc = ComponentsRegister.shared.MessageViewController.init(conversationId: <#刚创建用户的id#>, chatType: .chat)
        //继承注册后的自定义类还可以调用ViewModel的registerEventsListener方法监听相关事件
        //或者push或者present都可
        vc.modalPresentationStyle = .fullScreen
        ControllerStack.toDestination(vc: vc)
```

## 5.集成会话列表页面
```Swift
        let vc = ConversationListController()
        vc.modalPresentationStyle = .fullScreen
        ControllerStack.toDestination(vc: vc)
```

## 5.集成联系人列表页面
```Swift
        let vc = ContactViewController()
        vc.modalPresentationStyle = .fullScreen
        ControllerStack.toDestination(vc: vc)
```

## 7.监听chat_uikit事件和错误

您可以调用`registerUserStateListener`方法来监听 chat_uikit中用户相关以及链接状态变更的事件和错误。

```Swift
EaseChatUIKitClient.shared.unregisterUserStateListener(self)
```

# Customize

## 1.修改可配置项

下面示例展示如何更改消息内容显示

```Swift
        // 可以通过增减显示内容数组中的项，改变消息样式某一部分的显示隐藏。
        Appearance.chat.contentStyle = [.withReply,.withAvatar,.withNickName,.withDateAndTime]
        // 创建ChatroomView，传入布局参数、底部工具栏扩展按钮模型协议数组等参数。
        let vc = ComponentsRegister.shared.MessageViewController.init(conversationId: <#在Console中创建用户的id#>, chatType: .chat)
        vc.modalPresentationStyle = .fullScreen
        ControllerStack.toDestination(vc: vc)
```

详情请参见[Appearance](./Documentation/Appearance.md)。

## 2.自定义组件

- 下面展示如何自定义位置消息cell。

```Swift
class CustomLocationMessageCell: LocationMessageCell {
    //创建返回你想展示的view即可，气泡会包裹住您的view
    @objc open override func createContent() -> UIView {
        UIView(frame: .zero).backgroundColor(.clear).tag(bubbleTag)
    }
}
//在chat_uikit中注册继承原有类的自定义类来替换原来的类。
//在创建消息页面或使用其他UI组件之前调用此方法。
ComponentsRegister.shared.ChatLocationCell = CustomLocationMessageCell.self
```

- 下面展示如何继承注册基础的消息类型以及消息样式

```Swift
    ComponentsRegister.shared.registerCustomizeCellClass(cellType: YourMessageCell.self)
    class YourMessageCell: MessageCell {
        override func createAvatar() -> ImageView {
            ImageView(frame: .zero)
        }
    }
```

详情请参见[ComponentsRegister](./Documentation/ComponentsRegister.md)

## 3.拦截原有组件点击事件

注：拦截后原有点击事件相关业务均由用户自行处理

```Swift
        
        ComponentViewsActionHooker.shared.conversation.longPressed = { [weak self] indexPath,info in 
            //Process you business logic.
        }

```

# Theme
- 切换到 chat_uikit 附带的浅色或深色主题。在初始化单群聊UIKit视图之前切换主题切换主题即可更改默认主题，在视图使用中也可以切换由开发者判断系统当前主题后切换你想对应的主题即可。

```swift
Theme.switchTheme(style: .dark)
// 或
Theme.switchTheme(style: .light)
```

- 切换到自定义主题。

```swift
/**
如何定制主题？

自定义主题时，需要参考设计文档的主题色定义以下五种主题色的色相值。

chat_uikit 中的所有颜色都是使用 HSLA 颜色模型定义的，该模型是一种使用色调、饱和度、亮度和 alpha 表示颜色的方式。

H（Hue）：色相，颜色的基本属性，是色轮上从0到360的一个度数。0是红色，120是绿色，240是蓝色。

S（饱和度）：饱和度是颜色的强度和纯度。 饱和度越高，颜色越鲜艳； 饱和度越低，颜色越接近灰色。 饱和度以百分比值表示，范围从 0% 到 100%。 0% 表示灰度，100% 表示全色。

L（明度）：明度是颜色的亮度或暗度。 亮度越高，颜色越亮； 亮度越低，颜色越深。 亮度以百分比值表示，范围从 0% 到 100%。 0% 表示黑色，100% 表示白色。

A（Alpha）：Alpha是颜色的透明度。 值 1 表示完全不透明，0 表示完全透明。

通过调整HSLA模型的各个分量的值，您可以实现精确的色彩控制。
  */
Appearance.primaryHue = 191/360.0
Appearance.secondaryHue = 210/360.0
Appearance.errorHue = 189/360.0
Appearance.neutralHue = 191/360.0
Appearance.neutralSpecialHue = 199/360.0
Theme.switchTheme(style: .custom)
```

# Documentation

## [Documentation](/Documentation/chat_uikit.doccarchive)

您可以在 Xcode 中打开“chat_uikit.doccarchive”文件来查看其中的文件。

另外，您可以右键单击该文件以显示包内容并将其中的所有文件复制到一个文件夹中。 然后将此文件夹拖到“terminal”应用程序中并运行以下命令将其部署到本地IP地址上。

```bash
python3 -m http.server 8080
```

部署完成后，您可以在浏览器中访问 http://yourlocalhost:8080/documentation/chat_uikit   其中`yourlocalhost`是您的本地IP地址。 或者，您可以将此文件夹部署在外部网络地址上。

## 1.Appearance 

[Appearance](./Documentation/Appearance.md). 

即加载UI前的所有可改动的配置项。包含公共配置以及三类业务功能配置
- 公共配置  包含自定义皮肤的色相值配置、Alert、ActionSheet、默认头像等。
- 会话列表  包含会话滑动后的菜单项，会话列表'+'按钮点击后菜单项的配置等。
- 联系人    包含联系人页面以及header等配置项
- 聊天页面  包含消息长按以及键盘发送附件消息等可配菜单项、以及消息收发方的气泡颜色、字体颜色等。

## 2.ComponentRegister 

[ComponentRegister](./Documentation/ComponentsRegister.md). 

即可继承进行自定义定制的 UI 组件。

包含会话列表相关的页面以及UITableViewCell、联系人页面以及UITableViewCell、聊天页面以及不同类型消息内容的可定制组件等

## 3.ComponentViewsActionHooker

[ComponentViewsActionHooker](./Documentation/ComponentsActionEventsRegister.md). 所有可拦截的点击事件

## 4.拦截主要页面点击以及跳转事件

[详见](./Documentation/customize_click_jump.md).

## 5.拦截主要页面回调事件监听

[详见](./Documentation/modular_events_listener.md).

# Design Guide

如果您对设计指南和细节有任何疑问，您可以在 Figma 设计稿中添加评论并提及我们的设计师 Stevie Jiang。

参见[设计图](https://www.figma.com/community/file/1327193019424263350/chat-uikit-for-mobile)。

请参阅[UI设计指南](https://github.com/StevieJiang/Chat-UIkit-Design-Guide/blob/main/README.md)

# Contribution

欢迎贡献和反馈！ 对于任何问题或改进建议，您可以提出问题或提交拉取请求。

## Author

zjc19891106, [984065974@qq.com](mailto:984065974@qq.com)

## LICENSE

chat_uikit 可在 MIT 许可下使用。 有关详细信息，请参阅许可证文件。
