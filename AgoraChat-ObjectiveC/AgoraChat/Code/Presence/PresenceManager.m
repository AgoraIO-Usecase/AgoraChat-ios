//
//  PresenceManager.m
//  EaseIM
//
//  Created by lixiaoming on 2022/2/8.
//  Copyright © 2022 lixiaoming. All rights reserved.
//

#import "PresenceManager.h"

static PresenceManager *presenceManager = nil;

@interface PresenceManager()

@end

@implementation PresenceManager
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        presenceManager = [[PresenceManager alloc] init];
        [[[AgoraChatClient sharedClient] presenceManager] addDelegate:presenceManager delegateQueue:nil];
        [[AgoraChatClient sharedClient] addDelegate:presenceManager delegateQueue:nil];
    });
    return presenceManager;
}

//- (void)initialize
//{
//    [[[AgoraChatClient sharedClient] presenceManager] fetchSubscribedMembersWithPageNum:0 pageSize:50 Completion:^(NSArray<NSString *> *members, AgoraChatError *error) {
//        self.subscribedMembers = members;
//    }];
//}

- (NSMutableArray<NSString*>*)subscribedMembers
{
    if(!_subscribedMembers) {
        _subscribedMembers = [NSMutableArray<NSString*> array];
    }
    return _subscribedMembers;
}

- (NSMutableDictionary*)presences
{
    if(!_presences) {
        _presences = [NSMutableDictionary dictionary];
    }
    return _presences;
}

+ (NSDictionary*)presenceImages
{
    return @{
        @PRESENCESTATUS_ONLINE:kPresenceOnlineDescription,
        @PRESENCESTATUS_OFFLINE:kPresenceOfflineDescription,
        @PRESENCESTATUS_BUSY:kPresenceBusyDescription,
        @PRESENCESTATUS_DONOTDISTURB:kPresenceDNDDescription,
        @PRESENCESTATUS_LEAVE:kPresenceLeaveDescription,
        @PRESENCESTATUS_CUSTOM:@"custom"
    };
}

+ (NSDictionary*)whiteStrokePresenceImages
{
    return @{
        @PRESENCESTATUS_ONLINE:@"Online_whitestroke",
        @PRESENCESTATUS_OFFLINE:@"Offline_whitestroke",
        @PRESENCESTATUS_BUSY:@"Busy_whitestroke",
        @PRESENCESTATUS_DONOTDISTURB:@"Do Not Disturb_whitestroke",
        @PRESENCESTATUS_LEAVE:@"Away_whitestroke",
        @PRESENCESTATUS_CUSTOM:@"custom_whitestroke"
    };
}

+ (NSDictionary*)showStatus
{
    return @{
        @PRESENCESTATUS_ONLINE:kPresenceOnlineDescription,
        @PRESENCESTATUS_OFFLINE:kPresenceOfflineDescription,
        @PRESENCESTATUS_BUSY:kPresenceBusyDescription,
        @PRESENCESTATUS_DONOTDISTURB:kPresenceDNDDescription,
        @PRESENCESTATUS_LEAVE:kPresenceLeaveDescription
    };
}

- (void) subscribe:(NSArray<NSString*>*)members completion:(void(^)(NSArray<AgoraChatPresence*>* presences,AgoraChatError*error))aCompletion
{
//    NSMutableArray<NSString*>* members = [NSMutableArray array];
//    for(NSString* member in submembers) {
//        if([self.subscribedMembers containsObject:member])
//            continue;
//        [members addObject:member];
//    }
    NSInteger index = 0;
    NSInteger count = members.count;
    while(count > 0) {
        NSRange range;
        range.location = 100*index;
        if(count > 100) {
            range.length = 100;
        }else
            range.length = count;
        count -= range.length;
        NSArray* arr = [members subarrayWithRange:range];
        WEAK_SELF
        [[[AgoraChatClient sharedClient] presenceManager] subscribe:arr expiry:7*24*3600 completion:^(NSArray<AgoraChatPresence *> *presences, AgoraChatError *error) {
            if(!error) {
                [weakSelf.subscribedMembers addObjectsFromArray:arr];
                NSMutableArray<NSString*>* users = [NSMutableArray array];
                for (AgoraChatPresence* presence in presences) {
                    if(presence && presence.publisher.length > 0) {
                        [users addObject:presence.publisher];
                        [weakSelf.presences setObject:presence forKey:presence.publisher];
                    }
                }
                if(presences.count > 0)
                    [[NSNotificationCenter defaultCenter] postNotificationName:PRESENCES_UPDATE  object:users];
            }
            
            if(aCompletion)
                aCompletion(presences,error);
        }];
    }
}

- (void) unsubscribe:(NSArray<NSString*>*) members completion:(void(^)(AgoraChatError*error))aCompletion
{
    NSInteger index = 0;
    NSInteger count = members.count;
    while(members.count > 0) {
        NSRange range;
        range.location = 100*index;
        if(count > 100) {
            range.length = 100;
        }else
            range.length = count;
        NSArray* arr = [members subarrayWithRange:range];
        WEAK_SELF
        [[[AgoraChatClient sharedClient] presenceManager] unsubscribe:arr completion:^(AgoraChatError *error) {
            if(!error) {
                [weakSelf.subscribedMembers removeObjectsInArray:arr];
            }
        }];
    }
}

- (void) fetchPresencesByMembers:(NSArray*)members completion:(void(^)(NSArray<AgoraChatPresence*>* presences,AgoraChatError*error))aCompletion
{
    NSInteger index = 0;
    NSInteger count = members.count;
    while(count > 0) {
        NSRange range;
        range.location = 100*index;
        if(count > 100) {
            range.length = 100;
        }else
            range.length = count;
        count -= range.length;
        NSArray* arr = [members subarrayWithRange:range];
        [[[AgoraChatClient sharedClient] presenceManager] fetchPresenceStatus:arr completion:^(NSArray<AgoraChatPresence *> *presences, AgoraChatError *error) {
            if(!error) {
                NSMutableArray<NSString*>* users = [NSMutableArray array];
                for (AgoraChatPresence* presence in presences) {
                    if(presence && presence.publisher.length > 0) {
                        [users addObject:presence.publisher];
                        [self.presences setObject:presence forKey:presence.publisher];
                    }
                }
                if(presences.count > 0)
                    [[NSNotificationCenter defaultCenter] postNotificationName:PRESENCES_UPDATE  object:users];
            }
            
            if(aCompletion)
                aCompletion(presences,error);
        }];
    }
}
- (void) publishPresenceWithDescription:(NSString*)aDescription completion:(void(^)(AgoraChatError*error))aCompletion
{
    if([aDescription isEqualToString:kPresenceOnlineDescription])
        aDescription = @"";
    [[[AgoraChatClient sharedClient] presenceManager] publishPresenceWithDescription:aDescription completion:^(AgoraChatError *error) {
        if(aCompletion)
            aCompletion(error);
    }];
}

- (void) presenceStatusDidChanged:(NSArray<AgoraChatPresence*>*)presences
{
    NSMutableArray<NSString*>* users = [NSMutableArray array];
    for (AgoraChatPresence* presence in presences) {
        if(presence && presence.publisher.length > 0) {
            [users addObject:presence.publisher];
            [self.presences setObject:presence forKey:presence.publisher];
        }
    }
    if(presences.count > 0)
        [[NSNotificationCenter defaultCenter] postNotificationName:PRESENCES_UPDATE  object:users];
}

- (void)connectionStateDidChange:(AgoraChatConnectionState)aConnectionState
{
    AgoraChatPresence* presence = [self.presences objectForKey:[AgoraChatClient sharedClient].currentUsername];
    if(aConnectionState == AgoraChatConnectionDisconnected) {
        if(presence) {
            for (AgoraChatPresenceStatusDetail* detail in presence.statusDetails) {
                detail.status = 0;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:PRESENCES_UPDATE  object:@[[AgoraChatClient sharedClient].currentUsername]];
        }
    }
}

+ (NSInteger)fetchStatus:(AgoraChatPresence*)presence
{
    if(!presence)
        return 0;
    if(presence.statusDetails.count <= 0)
        return 0;
    NSInteger retStatus= 0;
    for(AgoraChatPresenceStatusDetail* detail in presence.statusDetails) {
        if(detail.status == 1){
            retStatus = 1;
            break;
        }
    }
    if(retStatus != 0) {
        if(presence.statusDescription.length > 0) {
            retStatus = PRESENCESTATUS_CUSTOM;
            if([presence.statusDescription isEqualToString:kPresenceOnlineDescription])
                retStatus = PRESENCESTATUS_ONLINE;
            if([presence.statusDescription isEqualToString:kPresenceBusyDescription])
                retStatus = PRESENCESTATUS_BUSY;
            if([presence.statusDescription isEqualToString:kPresenceDNDDescription])
                retStatus = PRESENCESTATUS_DONOTDISTURB;
            if([presence.statusDescription isEqualToString:kPresenceLeaveDescription])
                retStatus = PRESENCESTATUS_LEAVE;
        }
    }
    return retStatus;
}

+ (NSString*)formatOfflineStatus:(NSUInteger)lasttime
{
    NSDate* date = [NSDate date];
    NSUInteger secodes = [date timeIntervalSince1970] - lasttime;
    NSString* timeStr = @"";
    if(secodes < 60)
        timeStr = [NSString stringWithFormat:@"%lus",secodes];//unit seconds
    else if(secodes < 60*60)
        timeStr = [NSString stringWithFormat:@"%lum",secodes/60];//unit minutes
    else if(secodes < 24*60*60)
        timeStr = [NSString stringWithFormat:@"%luh",secodes/60/60];//unit hours
    else if(secodes < 7*24*60*60)
        timeStr = [NSString stringWithFormat:@"%lud",secodes/60/60/24];//unit hours
    else
        timeStr = [NSString stringWithFormat:@"%luw",secodes/60/60/24/7];//unit hours
    return [NSString stringWithFormat:@"Online %@ ago",timeStr];
}

@end
