/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraChatDemoHelper.h"
#import "AgoraApplyManager.h"
#import <UserNotifications/UserNotifications.h>
#import "AgoraNotificationNames.h"
#import "ACDChatViewController.h"
#import "ACDGroupMemberAttributesCache.h"

static AgoraChatDemoHelper *helper = nil;

@implementation AgoraChatDemoHelper

+ (instancetype)shareHelper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[AgoraChatDemoHelper alloc] init];
    });
    return helper;
}

- (void)dealloc
{
    [[AgoraChatClient sharedClient] removeDelegate:self];
    [[AgoraChatClient sharedClient].chatManager removeDelegate:self];
    [[AgoraChatClient sharedClient].groupManager removeDelegate:self];
    [[AgoraChatClient sharedClient].contactManager removeDelegate:self];
    [[AgoraChatClient sharedClient].roomManager removeDelegate:self];
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initHelper];
    }
    return self;
}

- (void)initHelper
{
    [[AgoraChatClient sharedClient] addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].groupManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    [[AgoraChatClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
}


#pragma mark - public

- (void)setupUntreatedApplyCount
{
    NSInteger unreadCount = [[AgoraApplyManager defaultManager] unHandleApplysCount];
    if (_contactsVC) {
        if (unreadCount > 0) {
//            _contactsVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
            [_contactsVC.tabBarController.tabBar showBadgeOnItemIndex:1];
            [_contactsVC navBarUnreadRequestIsShow:YES];
        }else{
//            _contactsVC.tabBarItem.badgeValue = nil;
            [_contactsVC.tabBarController.tabBar hideBadgeOnItemIndex:1];
            [_contactsVC navBarUnreadRequestIsShow:NO];
        }
    }
}

- (void)hiddenApplyRedPoint {
    [_contactsVC.tabBarController.tabBar hideBadgeOnItemIndex:1];
    [_contactsVC navBarUnreadRequestIsShow:NO];
}

#pragma mark - AgoraChatClientDelegate

- (void)autoLoginDidCompleteWithError:(AgoraChatError *)aError {
    [_contactsVC reloadGroupNotifications];
    [_contactsVC reloadContactRequests];
    [_contactsVC reloadContacts];
}

#pragma mark - AgoraChatManagerDelegate

- (void)conversationListDidUpdate:(NSArray *)aConversationList {
    if (_mainVC) {
        [_mainVC setupUnreadMessageCount];
    }
    if (_chatsVC) {
        [_chatsVC tableViewDidTriggerHeaderRefresh];
    }
}

- (void)messagesDidRecall:(NSArray *)aMessages {
    if (_mainVC) {
        [_mainVC setupUnreadMessageCount];
    }
    if (_chatsVC) {
        [_chatsVC tableViewDidTriggerHeaderRefresh];
    }
}


#pragma mark - AgoraContactManagerDelegate

- (void)friendRequestDidApproveByUser:(NSString *)aUsername {
    NSString *msgstr = [NSString stringWithFormat:NSLocalizedString(@"message.friendapply.agree", @"%@ agreed to add friends to apply"), aUsername];
    [self showAlertWithMessage:msgstr];
    
    [self notificationMsg:aUsername aUserName:@"" conversationType:AgoraChatConversationTypeChat hintMsg:@"Your friend request has been approved"];
}

- (void)friendRequestDidDeclineByUser:(NSString *)aUsername {
    NSString *msgstr = [NSString stringWithFormat:NSLocalizedString(@"message.friendapply.refuse", @"%@ refuse to add friends to apply"), aUsername];
    [self showAlertWithMessage:msgstr];
}

- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    NSString *msg = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"common.delete", @"Delete"), aUsername];
    [self showAlertWithMessage:msg];
    if (_contactsVC) {
        [_contactsVC reloadContacts];
    }
}

- (void)friendshipDidAddByUser:(NSString *)aUsername {
    if (_contactsVC) {
        [_contactsVC reloadContacts];
    }
}

- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername message:(NSString *)aMessage {
    if (!aUsername) {
        return;
    }
    
    if (!aMessage) {
        aMessage = [NSString stringWithFormat:NSLocalizedString(@"contact.somebodyAddWithName", @"%@ add you as a friend"), aUsername];
    }
    

    AgoraApplyModel *model = [[AgoraApplyModel alloc] init];
    model.applyHyphenateId = aUsername;
    model.applyNickName = aUsername;
    model.reason = aMessage;
    model.style = AgoraApplyStyle_contact;
    
    if (![[AgoraApplyManager defaultManager] isExistingRequest:aUsername
                                                    groupId:nil
                                                 applyStyle:AgoraApplyStyle_contact])
    {
        [[AgoraApplyManager defaultManager] addApplyRequest:model];
    }else {
        [[AgoraApplyManager defaultManager] updateApplyWithModel:model];
    }
    
    if (self.mainVC && helper) {
        [helper setupUntreatedApplyCount];
#if !TARGET_IPHONE_SIMULATOR
        
        BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
        if (!isAppActivity) {
            if (NSClassFromString(@"UNUserNotificationCenter")) {
                UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.01 repeats:NO];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.sound = [UNNotificationSound defaultSound];
                content.body =[NSString stringWithFormat:NSLocalizedString(@"contact.somebodyAddWithName", @"%@ add you as a friend"), aUsername];
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate] * 1000] stringValue] content:content trigger:trigger];
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:nil];
            }
            else {
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.fireDate = [NSDate date];
                notification.alertBody = [NSString stringWithFormat:NSLocalizedString(@"contact.somebodyAddWithName", @"%@ add you as a friend"), aUsername];
                notification.alertAction = NSLocalizedString(@"common.open", @"Open");
                notification.timeZone = [NSTimeZone defaultTimeZone];
            }
        }
#endif
    }
    [_contactsVC reloadContactRequests];
}

#pragma mark - AgoraChatGroupManagerDelegate

- (void)didLeaveGroup:(AgoraChatGroup *)aGroup
               reason:(AgoraChatGroupLeaveReason)aReason {
//    [[AgoraChatClient sharedClient].chatManager deleteConversation:aGroup.groupId isDeleteMessages:YES completion:nil];
//    [[AgoraChatClient sharedClient].chatManager deleteServerConversation:aGroup.groupId conversationType:AgoraChatConversationTypeGroupChat isDeleteServerMessages:YES completion:nil];
//    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_UPDATE_CONVERSATIONS object:nil];
    
    NSString *msgstr = nil;
    if (aReason == AgoraChatGroupLeaveReasonBeRemoved) {
        msgstr = [NSString stringWithFormat:@"Your are kicked out from group: %@ [%@]", aGroup.groupName, aGroup.groupId];
    } else if (aReason == AgoraChatGroupLeaveReasonDestroyed) {
        msgstr = [NSString stringWithFormat:@"Group: %@ [%@] is destroyed", aGroup.groupName, aGroup.groupId];
    }
    
    if (msgstr.length > 0) {
        [self showHint:msgstr];
    }
    [ACDGroupMemberAttributesCache.shareInstance removeCacheWithGroupId:aGroup.groupId];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_GROUP_DESTORY_OR_KICKEDOFF object:aGroup];

    
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:_mainVC.navigationController.viewControllers];
    ACDChatViewController *chatViewContrller = nil;
    for (id viewController in viewControllers) {
        if ([viewController isKindOfClass:[ACDChatViewController class]] && [aGroup.groupId isEqualToString:[(ACDChatViewController*)viewController conversationId]]) {
            chatViewContrller = viewController;
            break;
        }
    }
    
    if (chatViewContrller) {
        [viewControllers removeObject:chatViewContrller];
        if ([viewControllers count] > 0) {
            [_mainVC.navigationController setViewControllers:@[viewControllers[0]] animated:YES];
        } else {
            [_mainVC.navigationController setViewControllers:viewControllers animated:YES];
        }
    }
}

- (void)joinGroupRequestDidReceive:(AgoraChatGroup *)aGroup
                              user:(NSString *)aUsername
                            reason:(NSString *)aReason {
    if (!aGroup || !aUsername) {
        return;
    }
    
    if (!aReason || aReason.length == 0) {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoin", @"%@ apply to join groups\'%@\'"), aUsername, aGroup.groupName];
    }
    else{
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoinWithName", @"%@ apply to join groups\'%@\'：%@"), aUsername, aGroup.groupName, aReason];
    }
    
    AgoraApplyModel *model = [[AgoraApplyModel alloc] init];
    model.applyHyphenateId = aUsername;
    model.applyNickName = aUsername;
    model.groupId = aGroup.groupId;
    model.groupSubject = aGroup.groupName;
    model.groupMemberCount = aGroup.occupantsCount;
    model.reason = aReason;
    model.style = AgoraApplyStyle_joinGroup;

    if (![[AgoraApplyManager defaultManager] isExistingRequest:aUsername
                                                    groupId:aGroup.groupId
                                                 applyStyle:AgoraApplyStyle_joinGroup])
    {
        [[AgoraApplyManager defaultManager] addApplyRequest:model];
    }else {
        [[AgoraApplyManager defaultManager] updateApplyWithModel:model];
    }
    
    if (self.mainVC && helper) {
        [helper setupUntreatedApplyCount];
#if !TARGET_IPHONE_SIMULATOR
#endif
    }
    
    if (_contactsVC) {
        [_contactsVC reloadGroupNotifications];
    }
}

- (void)didJoinGroup:(AgoraChatGroup *)aGroup
             inviter:(NSString *)aInviter
             message:(NSString *)aMessage
{
    NSString *msgstr = [NSString stringWithFormat:NSLocalizedString(@"group.invite", @"%@ invite you to group: %@ [%@]"), aInviter, aGroup.groupName, aGroup.groupId];
    [self showAlertWithMessage:msgstr];
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];
    
    [self notificationMsg:aGroup.groupId aUserName:aInviter conversationType:AgoraChatConversationTypeGroupChat hintMsg:[NSString stringWithFormat:@"You have automatically agreed to %@ group invitation.", aInviter]];
}

- (void)joinGroupRequestDidDecline:(NSString *)aGroupId
                            reason:(NSString *)aReason
{
    if (!aReason || aReason.length == 0) {
        aReason = [NSString stringWithFormat:NSLocalizedString(@"group.beRefusedToJoin", @"be refused to join the group\'%@\'"), aGroupId];
    }
    [self showAlertWithMessage:aReason];
}

- (void)joinGroupRequestDidApprove:(AgoraChatGroup *)aGroup
{
    NSString *msgstr = [NSString stringWithFormat:NSLocalizedString(@"group.agreedAndJoined", @"agreed to join the group of \'%@\'"), aGroup.groupName];
    [self showAlertWithMessage:msgstr];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUPLIST_NOTIFICATION object:nil];

    [self notificationMsg:aGroup.groupId aUserName:@"" conversationType:AgoraChatConversationTypeGroupChat hintMsg:@"The group owner agrees to your group application."];
}

- (void)groupInvitationDidReceive:(NSString *)aGroupId
                        groupName:(NSString * _Nonnull)aGroupName
                          inviter:(NSString * _Nonnull)aInviter
                          message:(NSString * _Nullable)aMessage
{
    if (!aGroupId || !aInviter) {
        return;
    }
    
    [[AgoraChatClient sharedClient].groupManager getGroupSpecificationFromServerWithId:aGroupId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        
        AgoraApplyModel *model = [[AgoraApplyModel alloc] init];
        model.groupId = aGroupId;
        model.groupSubject = aGroupName;
        model.applyHyphenateId = aInviter;
        model.applyNickName = aInviter;
        NSString* message = aMessage;
        if (message.length == 0) {
            message = [NSString stringWithFormat:NSLocalizedString(@"group.invite", @""), aInviter,aGroupName,aGroupId];
        }
        model.reason = message;
        model.style = AgoraApplyStyle_groupInvitation;
        
        if (![[AgoraApplyManager defaultManager] isExistingRequest:aInviter
                                                        groupId:aGroupId
                                                     applyStyle:AgoraApplyStyle_groupInvitation])
        {
      
            [[AgoraApplyManager defaultManager] addApplyRequest:model];
        }else {
            [[AgoraApplyManager defaultManager] updateApplyWithModel:model];

        }
        
        if (self.mainVC && helper) {
            [helper setupUntreatedApplyCount];
        }
        
        if (self.contactsVC) {
            [self.contactsVC reloadGroupNotifications];
        }
    }];
}

- (void)groupInvitationDidDecline:(AgoraChatGroup *)aGroup
                          invitee:(NSString *)aInvitee
                           reason:(NSString *)aReason
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.declineInvitation", @"%@ decline to join the group [%@]"), aInvitee, aGroup.groupName];
  
    [self showAlertWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:message];
}

- (void)groupInvitationDidAccept:(AgoraChatGroup *)aGroup
                         invitee:(NSString *)aInvitee
{
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.acceptInvitation", @"%@ has agreed to join the group [%@]"), aInvitee, aGroup.groupName];
    
    [self showAlertWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:message];

    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];

    [self notificationMsg:aGroup.groupId aUserName:aInvitee conversationType:AgoraChatConversationTypeGroupChat hintMsg:[NSString stringWithFormat:@"%@ agreed to your invitation to join the group.", aInvitee]];
}

- (void)groupMuteListDidUpdate:(AgoraChatGroup *)aGroup
             addedMutedMembers:(NSArray *)aMutedMembers
                    muteExpire:(NSInteger)aMuteExpire
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSMutableString *message = [NSMutableString stringWithString:NSLocalizedString(@"group.mute.added", @"Added to mute list:")];
    for (NSString *username in aMutedMembers) {
        [message appendFormat:@" %@", username];
    }
    
    [self showAlertWithTitle:[NSString stringWithFormat:@"%@ %@", aGroup.groupName, NSLocalizedString(@"group.notifications", @"Group Notification")] message:message];
}

- (void)groupMuteListDidUpdate:(AgoraChatGroup *)aGroup
           removedMutedMembers:(NSArray *)aMutedMembers
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSMutableString *message = [NSMutableString stringWithString:NSLocalizedString(@"group.mute.removed", @"Removed from mute list:")];
    for (NSString *username in aMutedMembers) {
        [message appendFormat:@" %@", username];
    }
    [self showAlertWithTitle:[NSString stringWithFormat:@"%@ %@", aGroup.groupName, NSLocalizedString(@"group.notifications", @"Group Notification")] message:message];
}

- (void)groupAdminListDidUpdate:(AgoraChatGroup *)aGroup
                     addedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.memberToAdmin", @"%@ is upgraded to administrator"), aAdmin];
    [self showAlertWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:message];

}

- (void)groupAdminListDidUpdate:(AgoraChatGroup *)aGroup
                   removedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.AdminToMember", @"%@ is downgraded to members"), aAdmin];
    [self showAlertWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:message];

}

- (void)groupOwnerDidUpdate:(AgoraChatGroup *)aGroup
                   newOwner:(NSString *)aNewOwner
                   oldOwner:(NSString *)aOldOwner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.owner.updated", @"The group owner changed from %@ to %@"), aOldOwner, aNewOwner];
    [self showAlertWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:message];
    
    [self notificationMsg:aGroup.groupId aUserName:aNewOwner conversationType:AgoraChatConversationTypeGroupChat hintMsg:[NSString stringWithFormat:@"%@ becomes the new Group Owner.", aNewOwner]];
}

- (void)userDidJoinGroup:(AgoraChatGroup *)aGroup
                    user:(NSString *)aUsername
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];

    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.member.joined", @"%@ has joined to the group [%@]"), aUsername, aGroup.groupName];
    [self showAlertWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:message];

    [self notificationMsg:aGroup.groupId aUserName:aUsername conversationType:AgoraChatConversationTypeGroupChat hintMsg:[NSString stringWithFormat:@"%@ joined the Group.", aUsername]];
}

- (void)userDidLeaveGroup:(AgoraChatGroup *)aGroup
                     user:(NSString *)aUsername
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.member.leaved", @"%@ has leaved from the group [%@]"), aUsername, aGroup.groupName];
    [self showAlertWithTitle:NSLocalizedString(@"group.notifications", @"Group Notification") message:message];
    [[ACDGroupMemberAttributesCache shareInstance] removeCacheWithGroupId:aGroup.groupId userId:aUsername];
    
    [self notificationMsg:aGroup.groupId aUserName:aUsername conversationType:AgoraChatConversationTypeGroupChat hintMsg:[NSString stringWithFormat:@"%@ left the Group.", aUsername]];
}

- (void)groupAnnouncementDidUpdate:(AgoraChatGroup *)aGroup announcement:(NSString *)aAnnouncement
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_GROUP_INFO object:aGroup];
    
    NSString *message = aAnnouncement == nil ? [NSString stringWithFormat:NSLocalizedString(@"group.clearAnnouncement", @"Group:%@ Announcement is clear"), aGroup.groupName] : [NSString stringWithFormat:NSLocalizedString(@"group.updateAnnouncement", @"Group:%@ Announcement: %@"), aGroup.groupName, aAnnouncement];
    
    [self showAlertWithTitle:NSLocalizedString(@"group.announcementUpdate", @"Group Announcement Update") message:message];

}

//add friend / group noti
- (void)notificationMsg:(NSString *)itemId aUserName:(NSString *)aUserName conversationType:(AgoraChatConversationType)aType hintMsg:(NSString *)aHintMsg
{
    AgoraChatConversationType conversationType = aType;
    AgoraChatConversation *conversation = [[AgoraChatClient sharedClient].chatManager getConversation:itemId type:conversationType createIfNotExist:YES];
    AgoraChatTextMessageBody *body;
    NSString *to = itemId;
    AgoraChatMessage *message;
    if (conversationType == AgoraChatTypeChat) {
        body = [[AgoraChatTextMessageBody alloc] initWithText:aHintMsg];
        message = [[AgoraChatMessage alloc] initWithConversationID:to from:AgoraChatClient.sharedClient.currentUsername to:to body:body ext:@{MSG_EXT_NEWNOTI : NOTI_EXT_ADDFRIEND, kNOTI_EXT_USERID : aUserName}];
    } else if (conversationType == AgoraChatTypeGroupChat) {
        body = [[AgoraChatTextMessageBody alloc] initWithText:aHintMsg];
        message = [[AgoraChatMessage alloc] initWithConversationID:to from:aUserName to:to body:body ext:@{MSG_EXT_NEWNOTI : NOTI_EXT_ADDGROUP, kNOTI_EXT_USERID : aUserName}];
    }
    message.chatType = (AgoraChatType)conversation.type;
    message.isRead = YES;
    [conversation insertMessage:message error:nil];
    //refresh conversation list
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_UPDATE_CONVERSATIONS object:nil];
}

- (void)onAttributesChangedOfGroupMember:(NSString *)groupId userId:(NSString *)userId attributes:(NSDictionary<NSString *,NSString *> *)attributes operatorId:(NSString *)operatorId {
    for (NSString *key in attributes.allKeys) {
        [[ACDGroupMemberAttributesCache shareInstance] updateCacheWithGroupId:groupId userName:userId key:key value:attributes[key]];
    }
}

#pragma mark - AgoraChatroomManagerDelegate

- (void)didReceiveKickedFromChatroom:(AgoraChatroom *)aChatroom
                              reason:(AgoraChatroomBeKickedReason)aReason
{
    NSString *roomId = nil;
    if (aReason == AgoraChatroomBeKickedReasonDestroyed) {
        roomId = aChatroom.chatroomId;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_END_CHAT object:roomId];
}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom
                addedMutedMembers:(NSArray *)aMutes
                       muteExpire:(NSInteger)aMuteExpire
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSMutableString *message = [NSMutableString stringWithString:NSLocalizedString(@"chatroom.mute.added", @"Added to mute list:")];
    for (NSString *username in aMutes) {
        [message appendFormat:@" %@", username];
    }
        
    [self showAlertWithTitle:NSLocalizedString(@"chatroom.notifications", @"Chatroom Notification") message:message];

}

- (void)chatroomMuteListDidUpdate:(AgoraChatroom *)aChatroom
              removedMutedMembers:(NSArray *)aMutes
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSMutableString *message = [NSMutableString stringWithString:NSLocalizedString(@"chatroom.mute.removed", @"Removed from mute list:")];
    for (NSString *username in aMutes) {
        [message appendFormat:@" %@", username];
    }
    
    [self showAlertWithTitle:NSLocalizedString(@"chatroom.notifications", @"Chatroom Notification") message:message];

}

- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom
                        addedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"chatroom.memberToAdmin", @"%@ is upgraded to administrator"), aAdmin];
    [self showAlertWithTitle:NSLocalizedString(@"chatroom.notifications", @"Chatroom Notification") message:message];
}

- (void)chatroomAdminListDidUpdate:(AgoraChatroom *)aChatroom
                      removedAdmin:(NSString *)aAdmin
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"chatroom.AdminToMember", @"%@ is downgraded to members"), aAdmin];
    [self showAlertWithTitle:NSLocalizedString(@"chatroom.notifications", @"Chatroom Notification") message:message];
}

- (void)chatroomOwnerDidUpdate:(AgoraChatroom *)aChatroom
                      newOwner:(NSString *)aNewOwner
                      oldOwner:(NSString *)aOldOwner
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"chatroom.owner.updated", @"The chatroom owner changed from %@ to %@"), aOldOwner, aNewOwner];
    [self showAlertWithTitle:NSLocalizedString(@"chatroom.notifications", @"Chatroom Notification") message:message];
}

- (void)chatroomAnnouncementDidUpdate:(AgoraChatroom *)aChatroom announcement:(NSString *)aAnnouncement
{
    [[NSNotificationCenter defaultCenter] postNotificationName:KAgora_REFRESH_CHATROOM_INFO object:aChatroom];
    
    NSString *message = aAnnouncement == nil ? [NSString stringWithFormat:NSLocalizedString(@"chatroom.clearAnnouncement", @"Chatroom:%@ Announcement is clear"), aChatroom.subject] : [NSString stringWithFormat:NSLocalizedString(@"chatroom.updateAnnouncement", Chatroom:%@ Announcement: %@), aChatroom.subject, aAnnouncement];
    
    [self showAlertWithTitle:NSLocalizedString(@"chatroom.announcementUpdate", @"Chatroom Announcement Update") message:message];

}


@end
