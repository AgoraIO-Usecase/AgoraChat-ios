# Uncomment this line to define a global platform for your project
platform :ios, '11.0'

# Uncomment this line if you're using Swift
# use_frameworks!
inhibit_all_warnings!

# Import CocoaPods sources
source 'https://github.com/CocoaPods/Specs.git'

target 'AgoraChat-Demo' do
  
post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end

    pod 'MWPhotoBrowser', '~> 2.1.2'
    pod 'MJRefresh'
    pod 'Masonry'
    pod 'WHToast'
    pod 'FMDB'
    pod 'Agora_Chat_iOS'
    pod 'chat-uikit', '~> 1.0.7'
    pod 'AgoraChatCallKit'
end


#    target 'AgoraChatSDK' do
#    project '../agora-ios/newSDK/AgoraChatSDK.xcodeproj’
#    end


