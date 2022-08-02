//
//  DoraemonPluginEnvironment.m
//  AgoraChat
//
//  Created by 朱继超 on 2022/6/17.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "DoraemonPluginEnvironment.h"
#import "EMSDKOptionsViewController.h"

@implementation DoraemonPluginEnvironment



- (void)pluginDidLoad {
    EMSDKOptionsViewController *controller = [[EMSDKOptionsViewController alloc] initWithEnableEdit:YES finishCompletion:^(ACDDemoOptions * _Nonnull aOptions) {
        //weakself.appkeyField.text = aOptions.appkey;
    }];
    controller.modalPresentationStyle = 0;
    for (UIWindow *window in [UIApplication sharedApplication].windows) {
        if ([window isKindOfClass:[NSClassFromString(@"DoraemonHomeWindow") class]]) {
            [window.rootViewController presentViewController:controller animated:YES completion:nil];
            break;
        }
    }
}

@end
