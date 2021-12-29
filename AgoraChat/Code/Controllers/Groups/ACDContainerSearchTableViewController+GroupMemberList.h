//
//  ACDContainerSearchTableViewController+GroupMemberList.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/31.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContainerSearchTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ACDGroupMemberListType) {
    ACDGroupMemberListTypeALL = 0,
    ACDGroupMemberListTypeAdmin,
    ACDGroupMemberListTypeMute,
    ACDGroupMemberListTypeBlock,
    ACDGroupMemberListTypeWhite
};


@interface ACDContainerSearchTableViewController (GroupMemberList)

@property (nonatomic, strong) NSString *selectedUserId;
@property (nonatomic, strong) NSString *groupId;

/// action sheet operation selected member
/// @param userId selected member userId
/// @param memberListType selected member of memberList type
/// @param group current group
- (void)actionSheetWithUserId:(NSString *)userId
               memberListType:(ACDGroupMemberListType)memberListType
                        group:(AgoraChatGroup *)group ;

@end

NS_ASSUME_NONNULL_END
