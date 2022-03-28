//
//  EMChatRecordViewController.h
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/15.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraChatSearchViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDChatRecordViewController : AgoraChatSearchViewController

- (instancetype)initWithCoversationModel:(AgoraChatConversation *)conversation;

@end

NS_ASSUME_NONNULL_END
