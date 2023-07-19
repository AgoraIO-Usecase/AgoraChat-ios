//
//  PresenceManager.h
//  EaseIM
//
//  Created by lixiaoming on 2022/2/8.
//  Copyright © 2022 lixiaoming. All rights reserved.
//

#import <Foundation/Foundation.h>

#define PRESENCESTATUS_OFFLINE 0
#define PRESENCESTATUS_ONLINE 1
#define PRESENCESTATUS_BUSY 100
#define PRESENCESTATUS_DONOTDISTURB 101
#define PRESENCESTATUS_LEAVE 102
#define PRESENCESTATUS_CUSTOM 103

static NSString* const kPresenceOnlineDescription = @"Online";
static NSString* const kPresenceOfflineDescription = @"Offline";
static NSString* const kPresenceBusyDescription = @"Busy";
static NSString* const kPresenceDNDDescription = @"Do not Disturb";
static NSString* const kPresenceLeaveDescription = @"Away";

@interface PresenceManager : NSObject<AgoraChatPresenceManagerDelegate,AgoraChatClientDelegate>
+(instancetype _Nonnull ) alloc __attribute__((unavailable("call sharedInstance instead")));
+(instancetype _Nonnull ) new __attribute__((unavailable("call sharedInstance instead")));
-(instancetype _Nonnull ) copy __attribute__((unavailable("call sharedInstance instead")));
-(instancetype _Nonnull ) mutableCopy __attribute__((unavailable("call sharedInstance instead")));

@property (nonatomic,strong) NSMutableArray<NSString*>* _Nonnull subscribedMembers;
@property (nonatomic,strong) NSMutableDictionary* _Nonnull presences;
+ (instancetype _Nonnull )sharedInstance;
- (void)initialize;
- (void) subscribe:(NSArray<NSString*>*_Nonnull)members completion:(void(^_Nullable)(NSArray<AgoraChatPresence*>* _Nullable presences,AgoraChatError* _Nullable error))aCompletion;
- (void) unsubscribe:(NSArray<NSString*>* _Nonnull) members completion:(void(^_Nullable)(AgoraChatError* _Nullable error))aCompletion;
- (void) publishPresenceWithDescription:(NSString* _Nullable)aDescription completion:(void(^_Nullable)(AgoraChatError* _Nullable error))aCompletion;
- (void) fetchPresencesByMembers:(NSArray* _Nonnull)members completion:(void(^_Nullable)(NSArray<AgoraChatPresence*>*_Nullable  presences,AgoraChatError* _Nullable error))aCompletion;
+ (NSDictionary*_Nonnull)presenceImages;
+ (NSDictionary*_Nonnull)whiteStrokePresenceImages;
+ (NSDictionary*_Nonnull)showStatus;
+ (NSInteger)fetchStatus:(AgoraChatPresence*_Nonnull)presence;
+ (NSString*_Nonnull)formatOfflineStatus:(NSUInteger)lasttime;
@end
