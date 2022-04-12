//
//  NSObject+AlertController.h
//  AgoraChat
//
//  Created by liu001 on 2022/3/23.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (AlertController)
- (void)showAlertWithMessage:(NSString *)aMsg;

- (void)showAlertWithTitle:(NSString *)aTitle
                   message:(NSString *)aMsg;

@end

NS_ASSUME_NONNULL_END
