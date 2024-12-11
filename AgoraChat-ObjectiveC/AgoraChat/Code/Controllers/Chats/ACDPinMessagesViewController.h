//
//  ACDPinMessagesViewController.h
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2024/3/12.
//  Copyright © 2024 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDPinMessagesViewController : UIViewController

@property (strong,nonatomic) NSArray<AgoraChatMessage*> *pinMessages;
@property (nonatomic, copy) void(^selectMessageCompletion)(NSString* selectedMessage);
@property (nonatomic, copy) void(^unpinMessageCompletion)(NSString* messageId);

@end

NS_ASSUME_NONNULL_END
