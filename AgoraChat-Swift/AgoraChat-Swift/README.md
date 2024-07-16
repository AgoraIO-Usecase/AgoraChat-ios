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

1. [Register an application](https://docs.agora.io/en/agora-chat/get-started/enable?platform=ios).

2. Fill registered `AppKey` into the `AppKey` field in the `PublicFiles.swift` file.

3. You need to deploy the [server source code](https://github.com/easemob/easemob-demo-appserver/tree/dev-aigc) and fill it into the `ServerHost` in the `PublicFiles.swift` file. App server mainly provides APIs for obtaining tokens and uploading user avatars.
   - The login API is mainly used to register and generate the token required for chat-uikit login based on the user information.
   - Uploading avatars is a common general function and will not be described in detail here.
   - The appkey of the client and the server must be the same.

4. Select the target device and click **Run** on it (Note: As ARM simulator is not supported, and you need to select a Rosetta simulator or real device).

# Use of chat-uikit in Demo

## 1. Initialize

[For details, see the steps in the `didFinishLaunchingWithOptions` method](./AgoraChat-Swift/AgoraChat-Swift//AppDelegate.swift).

## 2. Log in

[For details, see the subsequent steps of the `loginRequest` method](./AgoraChat-Swift/AgoraChat-Swift/LoginViewController.swift).

## 3. Use the Provider

If your app already has a complete user system and user information that can be displayed (such as the avatar and nickname), you can implement the EaseChatProfileProvider protocol to provide UIKit with the data to be displayed.

3.1 [For details on Provider initialization, see the `viewDidLoad` method](./AgoraChat-Swift/AgoraChat-Swift/Main/MainViewController.swift).

3.2 To implement the Provider protocol and extend the `MainViewController` class, see the following sample code:

```Swift
extension MainViewController: EaseProfileProvider,EaseGroupProfileProvider {

}
```

## 4. Inherit the class in chat-uikit for secondary development

4.1 How to inherit customizable classes in chat-uikit

[See the IntegratedFromChatUIKit folder](./AgoraChat-Swift/AgoraChat-Swift/IntegratedFromChatUIKit).

4.2 How to register a subclass inherited from chat-uikit into chat-uikit to replace the parent class

[For details, see](./AgoraChat-Swift/AgoraChat-Swift/AppDelegate.swift) in the `didFinishLaunchingWithOptions` method.

# Demo UI Design

https://www.figma.com/community/file/1327193019424263350/chat-uikit-for-mobile

# Known Issues

1. When a user is invited to join a video call or audio call on group chat, a one-to-one chat message will be generated. 
2. The conversation list and contact list are separate modules. To listen for contact events, you need to set `enableContact` in the `option_UI` property in the `option` property of `EaseChatUIKitClient` to `true` before login. 
3. UserProvider and GroupProvider need to be implemented by the developer to obtain the user attributes and the group information and display them on the UI. If the two providers are not implemented, the default user ID and default user avatar are used for one-to-one chat and the default group ID and default group avatar are used for group chat. The default implementation in the Demo is only used to display some SDK functions. 
4. When changing devices, logging in to multiple devices, getting the conversation list from the server, or displaying information such as group avatar that is not stored locally in the AgoraChat SDK, developers need to use Provider to provide it to chat-uikit to display the information properly on the UI.
5. Since the Provider mechanism is triggered when the scrolling stops or the first page has less than 7 data items, updating the nickname or avatar displayed on the conversation list or contact list UI requires sliding and the Provider providing data to UIKit, and then UIKit will refresh the UI.
   
6. The ARM simulator is not supported because the audio recording library uses libffmpeg's wav to ARM library. 

# Feedback

If you have any problems or suggestions regarding the sample project, please feel free to file an issue.

# Reference

Agora provides the full set of documentation and API Reference at [Agora Chat documents](https://docs.agora.io/en/agora-chat/get-started/get-started-sdk?platform=ios).

# Related Resources

- Check our [FAQ](https://docs.agora.io/en/faq) to see if your issue has been recorded.
- Repositories managed by developer communities can be found at [Agora Community](https://github.com/AgoraIO-Community).
- For any issues during integration, feel free to ask for help in [Stack Overflow](https://stackoverflow.com/questions/tagged/agora.io).

# License

chat_uikit is available under the MIT License. See the LICENSE file for details.
