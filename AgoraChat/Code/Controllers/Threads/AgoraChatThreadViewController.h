//
//  AgoraChatThreadViewController.h
//  AgoraChat
//
//  Created by 朱继超 on 2022/4/5.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AgoraChatThreadViewController : UIViewController

@property (nonatomic, strong) AgoraChatConversation *conversation;
@property (nonatomic, strong) EaseThreadChatViewController *chatController;

@property (nonatomic, strong, readonly) NSString *conversationId;
@property (nonatomic, strong) NSString *navTitle;
@property (nonatomic) NSString *detail;
@property (nonatomic) BOOL createPush;
@property (nonatomic, strong) void(^leaveGroupBlock)(void);


- (instancetype)initThreadChatViewControllerWithCoversationid:(NSString *)conversationId conversationType:(AgoraChatConversationType)conType chatViewModel:(EaseChatViewModel *)viewModel parentMessageId:(NSString *)parentMessageId model:(EaseMessageModel *)model;
@end

