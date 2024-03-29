//
//  UIViewController+Util.m
//  dxstudio
//
//  Created by XieYajie on 25/08/2017.
//  Copyright © 2017 dxstudio. All rights reserved.
//

#import "UIViewController+Util.h"

@implementation UIViewController (Util)

- (void)addPopBackLeftItem
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"black_goBack"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(popBackLeftItemAction)];
}

- (void)addPopBackLeftItemWithTarget:(id _Nullable )aTarget
                              action:(SEL _Nullable )aAction
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"black_goBack"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:aTarget action:aAction];
}

- (void)addKeyboardNotificationsWithShowSelector:(SEL)aShowSelector
                                    hideSelector:(SEL)aHideSelector
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aShowSelector name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:aHideSelector name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)popBackLeftItemAction
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showAlertControllerWithMessage:(NSString *)aMsg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"o(TωT)o" message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}

- (UIViewController *)currentViewController {
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [[UIApplication sharedApplication] connectedScenes]) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow* window in scene.windows) {
                    if(window.isKeyWindow) {
                        UIViewController* vc =  window.rootViewController;
                        if ([vc isKindOfClass:[UINavigationController class]]) {
                            return ((UINavigationController*)vc).visibleViewController;
                        } else if ([vc isKindOfClass:[UITabBarController class]]) {
                            UIViewController* selectVC = ((UITabBarController*)vc).selectedViewController;
                            if ([selectVC isKindOfClass:[UINavigationController class]]) {
                                return ((UINavigationController*)selectVC).visibleViewController;
                            } else {
                                return selectVC;
                            }
                        } else {
                            return vc;
                        }
                    }
                }
            }
        }
    } else {
        return [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    return nil;
}

@end
