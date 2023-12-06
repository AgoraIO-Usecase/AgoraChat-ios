//
//  NSObject+AlertController.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/23.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "NSObject+AlertController.h"
#import "UIViewController+Util.h"

@implementation NSObject (AlertController)
- (void)_showAlertController:(UIAlertController *)aAlert
{
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"common.ok", @"OK") style:UIAlertActionStyleCancel handler:nil];
    [aAlert addAction:okAction];
    
    UIViewController *currentViewController = [aAlert currentViewController];
    aAlert.modalPresentationStyle = 0;
    [currentViewController presentViewController:aAlert animated:YES completion:nil];
}

- (void)showAlertWithMessage:(NSString *)aMsg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    [self _showAlertController:alertController];
}

- (void)showAlertWithTitle:(NSString *)aTitle
                   message:(NSString *)aMsg
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:aTitle message:aMsg preferredStyle:UIAlertControllerStyleAlert];
    [self _showAlertController:alertController];
}

@end
