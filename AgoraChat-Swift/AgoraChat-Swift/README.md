# Demo

![](./demo.png)

# Development Environment

- Xcode 15.0 or later. The reason is that the audio detection `AVAudioApplication` API is used in UIKit to adapt to iOS 17 and later access check.
- Minimum system version: iOS 13.0
- A valid developer signature for your project

# Installation

You can install chat_uikit using CocoaPods as a dependency of your Xcode project.

## CocoaPods

Add the following dependencies to `podfile`.

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

Then run the `cd` command on the terminal to navigate to the folder where `podfile` is located:

```
    pod install
```

>⚠️If the compilation error `Sandbox: rsync.samba(47334) deny(1) file-write-create...` is reported in Xcode15, you can:

> Search for `ENABLE_USER_SCRIPT_SANDBOXING` in **Build Setting** and change `User Script Sandboxing` to `NO`.

# Run the Demo

1. [Register Application](https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios)

2. Fill registered `AppKey` into the `AppKey` field in the `PublicFiles.swift` file.

3. You need to deploy the [server source code](https://github.com/easemob/easemob-demo-appserver/tree/dev-aigc) and fill it into the `ServerHost` in the `PublicFiles.swift` file. Appserver mainly provides interfaces for obtaining tokens and uploading user avatars.
   - The main function of the login interface is to register and generate the token required for chat-uikit login based on the user's information
   - Uploading avatars is a common general function and will not be described in detail here.
   - The appkey of the client and the server must be the same.

4. Click Run to the target device (Note: ARM simulator is not supported, you need to select Rosetta simulator or real device)

# Use of chat-uikit in Demo

## 1. Initialize

[For details, see the steps in the `didFinishLaunchingWithOptions` method in](./AgoraChat-Swift/AgoraChat-Swift//AppDelegate.swift).
## 2. Login

[For details, see the subsequent steps of the `loginRequest` method in](./AgoraChat-Swift/AgoraChat-Swift/LoginViewController.swift)

## 3. Provider Usage

If your App already has a complete user system and user information that can be displayed (such as avatar nicknames, etc.), you can implement the EaseChatProfileProvider protocol to provide UIKit with the data to be displayed.

3.1 [For details on Provider initialization, see the `viewDidLoad` method in](./AgoraChat-Swift/AgoraChat-Swift/Main/MainViewController.swift)

3.2 To implement the Provider protocol and extend the `MainViewController` class, see the following sample code

```Swift
extension MainViewController: EaseProfileProvider,EaseGroupProfileProvider {

}
```


## 4.Inherit the class in chat-uikit for secondary development

4.1 How to inherit customizable classes in chat-uikit

[See the IntegratedFromChatUIKit folder](./AgoraChat-Swift/AgoraChat-Swift/IntegratedFromChatUIKit)

4.2 How to register a subclass inherited from chat-uikit into chat-uikit to replace the parent class

[For details, see] (./AgoraChat-Swift/AgoraChat-Swift/AppDelegate.swift) in the `didFinishLaunchingWithOptions` method

# Demo UI Design

https://www.figma.com/community/file/1327193019424263350/chat-uikit-for-mobile


# Known Issues

1. When a callkit group chat calls a user, a single chat message will be generated. Even if the other party is not your friend, the system will improve this in the future, and users can also use the directed messages in the group chat to do their own signaling.
2. The conversation list and contact list are separate modules. If you want to monitor friend events, you need to set `enableContact` in the `option_UI` property in the `option` property of `EaseChatUIKitClient` to true on login before.
3. UserProvider and GroupProvider need to be implemented by the user to obtain the user's display information and the group's brief display information. If not implemented, the default id and default avatar are used. The default implementation in the Demo is only used to display some SDK functions.
4. When changing devices or logging in to multiple devices, roaming session lists, and display information such as group avatar names that are not stored locally in the AgoraChat SDK, users need to use Provider to provide it to chat-uikit for normal display.
5. Since the Provider mechanism is triggered when scrolling stops or the first page has less than 7 data items, updating the nickname avatar displayed in the conversation list and contact list UI requires sliding and the Provider providing data to UIKit, and then UIKit will refresh the UI.
6. The arm simulator is not supported because the audio recording library uses libffmpeg's wav to amr library.


# Feedback

If you have any problems or suggestions regarding the sample projects, feel free to file an issue.

# Reference

Agora provides the full set of documentation and API Reference at [Agora Chat documents](https://docs.agora.io/en/agora-chat/get-started/get-started-sdk?platform=ios).

# Related Resources

- Check our [FAQ](https://docs.agora.io/en/faq) to see if your issue has been recorded.
- Repositories managed by developer communities can be found at [Agora Community](https://github.com/AgoraIO-Community).
- If you encounter problems during integration, feel free to ask questions in [Stack Overflow](https://stackoverflow.com/questions/tagged/agora.io).

# License

Distributed under the MIT License. See `LICENSE` for more information.