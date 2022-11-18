//
//  ACDGroupInfoViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/26.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDBaseTableViewController.h"

@protocol  ACDGroupInfoViewControllerDelegate <NSObject>

@optional
//group member list
- (void)checkGroupMemberListWithGroup:(AgoraChatGroup *_Nonnull)group;
//group chat
- (void)enterGroupChatWithGroup:(AgoraChatGroup *_Nonnull)group;
//group Description
- (void)checkGroupDescriptionWithGroup:(AgoraChatGroup *_Nonnull)group;
//group Notice
- (void)checkGroupNoticeWithGroup:(AgoraChatGroup *_Nonnull)group;

@end


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ACDGroupInfoAccessType) {
    ACDGroupInfoAccessTypeContact,
    ACDGroupInfoAccessTypeChat,
    ACDGroupInfoAccessTypeSearch,
};


@interface ACDGroupInfoViewController : ACDBaseTableViewController
@property (nonatomic, assign) ACDGroupInfoAccessType accessType;
@property (nonatomic,assign) BOOL isHideChatButton;

@property (nonatomic, assign) id<ACDGroupInfoViewControllerDelegate> delegate;
 
- (instancetype)initWithGroupId:(NSString *)aGroupId;

@end

NS_ASSUME_NONNULL_END
