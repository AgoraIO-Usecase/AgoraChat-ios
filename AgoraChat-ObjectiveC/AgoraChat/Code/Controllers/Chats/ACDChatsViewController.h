//
//  ACDChatsViewController.h
//  ChatDemo-UI3.0
//
//  Created by zhangchong on 2021/11/6.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraChatRefreshViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDChatsViewController : AgoraChatRefreshViewController

@property (nonatomic, copy) void (^deleteConversationCompletion)(BOOL isDelete);

- (void)networkChanged:(AgoraChatConnectionState)connectionState;

@end

NS_ASSUME_NONNULL_END
