//
//  ACDContainerSearchTableViewController+GroupMemberList.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/31.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContainerSearchTableViewController+GroupMemberList.h"
#import <objc/runtime.h>

typedef void(^actionBlock)();

#define kActionAdminKey   @"ActionAdminKey"
#define kActionUnAdminKey @"ActionUnAdminKey"

#define kActionMuteKey    @"ActionMuteKey"
#define kActionUnMuteKey  @"ActionUnMuteKey"

#define kActionBlockKey   @"ActionBlockKey"
#define kActionUnBlockKey @"ActionUnBlockKey"

#define kActionRemoveFromGroupKey @"ActionRemoveFromGroupKey"

static NSString *selectedUserIdKey = @"selectedUserId";
static NSString *groupIdKey = @"groupId";

@interface ACDContainerSearchTableViewController ()

@end

@implementation ACDContainerSearchTableViewController (GroupMemberList)

- (void)actionSheetWithUserId:(NSString *)userId
               memberListType:(ACDGroupMemberListType)memberListType
                        group:(AgoraChatGroup *)group {
    //if selected user is currentUsernam, than do nothing
    if ([userId isEqualToString:AgoraChatClient.sharedClient.currentUsername]) {
        return;
    }
    
    //admin can not opertion admin
    if (group.permissionType == AgoraChatGroupPermissionTypeAdmin) {
        BOOL isAdminUserId = [group.adminList containsObject:userId];
        if (isAdminUserId) {
            return;
        }
    }
    
    if (group.permissionType == AgoraChatGroupPermissionTypeMember) {
        return;
    }
    
    self.selectedUserId = userId;
    self.groupId = group.groupId;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:userId message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (group.permissionType == AgoraChatGroupPermissionTypeOwner) {
        BOOL isAdmin = [group.adminList containsObject:userId];
        NSArray *actions = [self ownerWithMemberListType:memberListType selectedIsAdmin:isAdmin alertController:alertController];
        for (UIAlertAction *action in actions) {
            [alertController addAction:action];
        }
        
    }
    
    if (group.permissionType == AgoraChatGroupPermissionTypeAdmin) {
        NSArray *actions = [self adminWithMemberListType:memberListType alertController:alertController];
        
        for (UIAlertAction *action in actions) {
            [alertController addAction:action];
        }
    }
    
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    return;

}
   

-(NSArray *)ownerWithMemberListType:(ACDGroupMemberListType)memberListType
                    selectedIsAdmin:(BOOL)selectedIsAdmin
                    alertController:(UIAlertController *)alertController {
    
    NSMutableArray *actionArray = NSMutableArray.new;
    NSDictionary *actionDic = [self alertActionDics];
    if (memberListType == ACDGroupMemberListTypeALL) {
        if (selectedIsAdmin) {
            [actionArray addObject:actionDic[kActionUnAdminKey]];
            [actionArray addObject:actionDic[kActionMuteKey]];
            [actionArray addObject:actionDic[kActionBlockKey]];
            [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    
        }else {
            [actionArray addObject:actionDic[kActionAdminKey]];
            [actionArray addObject:actionDic[kActionMuteKey]];
            [actionArray addObject:actionDic[kActionBlockKey]];
            [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
        }
    }
    
    if (memberListType == ACDGroupMemberListTypeBlock) {
        [actionArray addObject:actionDic[kActionUnBlockKey]];
        [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    }

    if (memberListType == ACDGroupMemberListTypeMute) {
        [actionArray addObject:actionDic[kActionUnMuteKey]];
        [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    }

    return [actionArray copy];
    
}


-(NSArray *)adminWithMemberListType:(ACDGroupMemberListType)memberListType
               alertController:(UIAlertController *)alertController {
    
    NSMutableArray *actionArray = NSMutableArray.new;
    NSDictionary *actionDic = [self alertActionDics];
    if (memberListType == ACDGroupMemberListTypeALL) {
        [actionArray addObject:actionDic[kActionMuteKey]];
        [actionArray addObject:actionDic[kActionBlockKey]];
        [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    }
    
    if (memberListType == ACDGroupMemberListTypeBlock) {
        [actionArray addObject:actionDic[kActionUnBlockKey]];
        [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    }

    if (memberListType == ACDGroupMemberListTypeMute) {
        [actionArray addObject:actionDic[kActionUnMuteKey]];
        [actionArray addObject:actionDic[kActionRemoveFromGroupKey]];
    }

    return [actionArray copy];

}

- (NSDictionary *)alertActionDics {
        NSMutableDictionary *alertActionDics = NSMutableDictionary.new;
//        UIAlertAction *makeAdminAction = [self alertActionWithTitle:@"Make Admin" completion:^{
//            [self makeAdmin];
//        }];
  
    UIAlertAction *makeAdminAction = [UIAlertAction alertActionWithTitle:@"Make Admin" iconImage:ImageWithName(@"admin") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self makeAdmin];
    }];

    
//        UIAlertAction *makeMuteAction = [self alertActionWithTitle:@"Mute" completion:^{
//            [self makeMute];
//        }];

    UIAlertAction *makeMuteAction = [UIAlertAction alertActionWithTitle:@"Mute" iconImage:ImageWithName(@"mute") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self makeMute];
    }];
    
//        UIAlertAction *makeBlockAction = [self alertActionWithTitle:@"Move to Blocked List" completion:^{
//            [self makeBlock];
//        }];

    UIAlertAction *makeBlockAction = [UIAlertAction alertActionWithTitle:@"Move to Blocked List" iconImage:ImageWithName(@"blocked") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self makeBlock];
    }];
    
        
//        UIAlertAction *makeRemoveGroupAction = [self alertActionWithTitle:@"Remove From Group" completion:^{
//            [self makeRemoveGroup];
//        }];
//
    UIAlertAction *makeRemoveGroupAction = [UIAlertAction alertActionWithTitle:@"Remove From Group" iconImage:ImageWithName(@"remove") textColor:TextLabelPinkColor alignment:NSTextAlignmentLeft completion:^{
        [self makeRemoveGroup];
    }];

    
//        UIAlertAction *makeUnAdminAction = [self alertActionWithTitle:@"Remove as Admin" completion:^{
//            [self unAdmin];
//        }];
    
    UIAlertAction *makeUnAdminAction = [UIAlertAction alertActionWithTitle:@"Remove as Admin" iconImage:ImageWithName(@"remove_admin") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self unAdmin];
    }];

    
//        UIAlertAction *makeUnMuteAction = [self alertActionWithTitle:@"Unmute" completion:^{
//            [self unMute];
//        }];

    UIAlertAction *makeUnMuteAction = [UIAlertAction alertActionWithTitle:@"Unmute" iconImage:ImageWithName(@"Unmute") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self unMute];
    }];
    
        
//        UIAlertAction *makeUnBlockAction = [self alertActionWithTitle:@"Remove from Blocked List" completion:^{
//            [self unBlock];
//        }];
    
    UIAlertAction *makeUnBlockAction = [UIAlertAction alertActionWithTitle:@"Remove from Blocked List" iconImage:ImageWithName(@"Unblock") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self unBlock];
    }];
    
    alertActionDics[kActionAdminKey] = makeAdminAction;
    alertActionDics[kActionMuteKey] =  makeMuteAction;
    alertActionDics[kActionBlockKey] = makeBlockAction;
    alertActionDics[kActionUnAdminKey] = makeUnAdminAction;
    alertActionDics[kActionUnMuteKey] = makeUnMuteAction;
    alertActionDics[kActionUnBlockKey] = makeUnBlockAction;
    alertActionDics[kActionRemoveFromGroupKey] = makeRemoveGroupAction;

    return alertActionDics;
}

//- (UIAlertAction* )alertActionWithTitle:(NSString *)title
//                             completion:(actionBlock)completion {
//    UIAlertAction* alertAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        if (completion) {
//            completion();
//        }
//    }];
//    return alertAction;
//}


#pragma mark actions
- (void)makeAdmin {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager addAdmin:self.selectedUserId toGroup:self.groupId error:&error];
    [self handleActionTitle:@"add admin" responseError:error];
}




- (void)unAdmin {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager removeAdmin:self.selectedUserId fromGroup:self.groupId error:&error];
    
    [self handleActionTitle:@"remove admin" responseError:error];

}


- (void)makeMute {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager muteMembers:@[self.selectedUserId] muteMilliseconds:-1 fromGroup:self.groupId error:&error];
    
    [self handleActionTitle:@"Mute" responseError:error];

}

- (void)unMute {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager unmuteMembers:@[self.selectedUserId] fromGroup:self.groupId error:&error];
    [self handleActionTitle:@"unmute" responseError:error];

}


- (void)makeBlock {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager blockOccupants:@[self.selectedUserId] fromGroup:self.groupId error:&error];
    [self handleActionTitle:@"block" responseError:error];

}

- (void)unBlock {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager unblockOccupants:@[self.selectedUserId] forGroup:self.groupId error:&error];
    [self handleActionTitle:@"unBlock" responseError:error];

}


- (void)makeRemoveGroup {
    AgoraChatError *error = nil;
    [[AgoraChatClient sharedClient].groupManager removeOccupants:@[self.selectedUserId] fromGroup:self.groupId error:&error];
    [self handleActionTitle:@"remove" responseError:error];

}

- (void)handleActionTitle:(NSString *)title
            responseError:(AgoraChatError *)error {
    if (error == nil) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:self.groupId];
    }else {
        [self showHint:error.errorDescription];
    }
}


#pragma mark getter and setter
- (void)setSelectedUserId:(NSString *)selectedUserId {
    objc_setAssociatedObject(self, &selectedUserIdKey, selectedUserId, OBJC_ASSOCIATION_COPY);
}

- (NSString *)selectedUserId {
    return objc_getAssociatedObject(self, &selectedUserIdKey);
}


- (void)setGroupId:(NSString *)groupId {
    objc_setAssociatedObject(self, &groupIdKey, groupId, OBJC_ASSOCIATION_COPY);
}

- (NSString *)groupId {
    return objc_getAssociatedObject(self, &groupIdKey);
}

@end

#undef kActionAdminKey
#undef kActionUnAdminKey

#undef kActionMuteKey
#undef kActionUnMuteKey

#undef kActionBlockKey
#undef kActionUnBlockKey

#undef kActionRemoveFromGroupKey
