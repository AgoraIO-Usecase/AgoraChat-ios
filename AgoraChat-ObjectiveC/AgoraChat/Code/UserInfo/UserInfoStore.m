//
//  UserInfoStore.m
//  EaseIM
//
//  Created by lixiaoming on 2021/3/18.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import "UserInfoStore.h"
#import "DBManager.h"

@interface UserInfoStore()
@property (nonatomic,strong) NSMutableDictionary* dicUsersInfo;
@property (nonatomic) NSTimeInterval timeOutInterval;
@property (nonatomic,strong) NSMutableArray* userIds;
@property (nonatomic,strong) NSLock* lock;
@property (nonatomic,strong) NSLock* userInfolock;
@property (nonatomic,strong) dispatch_queue_t workQueue;
@end

static UserInfoStore *userInfoStoreInstance = nil;

@implementation UserInfoStore

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userInfoStoreInstance = [[UserInfoStore alloc] init];
        userInfoStoreInstance.timeOutInterval = 24*3600;
        userInfoStoreInstance.lock = [[NSLock alloc] init];
        userInfoStoreInstance.userInfolock = [[NSLock alloc] init];
        userInfoStoreInstance.workQueue = dispatch_queue_create("demo.userinfostore", DISPATCH_QUEUE_SERIAL);
    });
    return userInfoStoreInstance;
}

- (void)setUserInfo:(AgoraChatUserInfo*)aUserInfo forId:(NSString*)aUserId
{
    [self.userInfolock lock];
    if(aUserId.length > 0 && aUserInfo)
    {
        [self.dicUsersInfo setObject:aUserInfo forKey:aUserId];
        [[DBManager sharedInstance] addUserInfos:@[aUserInfo]];
    }
    [self.userInfolock unlock];
}

- (void)setUserInfo:(AgoraChatUserInfo*)aUserInfo type:(AgoraChatUserInfoType)aType forId:(NSString*)aUserId
{
    [self.userInfolock lock];
    if(aUserId.length > 0 && aUserInfo)
    {
        AgoraChatUserInfo* info = [self.dicUsersInfo objectForKey:aUserId];
        if(info) {
            switch (aType) {
                case AgoraChatUserInfoTypeAvatarURL:
                    info.avatarUrl = aUserInfo.avatarUrl;
                    break;
                case AgoraChatUserInfoTypeNickName:
                    info.nickname = aUserInfo.nickname;
                    break;
                case AgoraChatUserInfoTypeMail:
                    info.mail = aUserInfo.mail;
                    break;
                case AgoraChatUserInfoTypePhone:
                    info.phone = aUserInfo.phone;
                    break;
                case AgoraChatUserInfoTypeExt:
                    info.ext = aUserInfo.ext;
                    break;
                case AgoraChatUserInfoTypeSign:
                    info.sign = aUserInfo.sign;
                    break;
                case AgoraChatUserInfoTypeBirth:
                    info.birth = aUserInfo.birth;
                    break;
                case AgoraChatUserInfoTypeGender:
                    info.gender = aUserInfo.gender;
                    break;
                default:
                    break;
            }
        }else{
            info = aUserInfo;
        }
        [self.dicUsersInfo setObject:info forKey:aUserId];
        [[DBManager sharedInstance] addUserInfos:@[info]];
    }
    [self.userInfolock unlock];
}
- (void)addUserInfos:(NSArray<AgoraChatUserInfo*>*)aUserInfos
{
    [self.userInfolock lock];
    if(aUserInfos.count > 0) {
        for (AgoraChatUserInfo* userInfo in aUserInfos) {
            if(userInfo && userInfo.userId.length > 0 )
            {
                [self.dicUsersInfo setObject:userInfo forKey:userInfo.userId];
            }
        }
        [[DBManager sharedInstance] addUserInfos:aUserInfos];
    }
    [self.userInfolock unlock];
}
- (AgoraChatUserInfo*)getUserInfoById:(NSString*)aUserId
{
    
    if(aUserId.length > 0)
    {
        [self.userInfolock lock];
        AgoraChatUserInfo* userInfo = [self.dicUsersInfo objectForKey:aUserId];
        [self.userInfolock unlock];
        return userInfo;
    }
    return nil;
}

- (NSMutableDictionary*)dicUsersInfo
{
    if(!_dicUsersInfo){
        _dicUsersInfo = [NSMutableDictionary dictionary];
    }
    return  _dicUsersInfo;
}

-(NSMutableArray*)userIds
{
    if(!_userIds) {
        _userIds = [NSMutableArray array];
    }
    return _userIds;
}

- (void)loadInfosFromLocal
{
    NSArray<AgoraChatUserInfo*>* aUserInfos = [[DBManager sharedInstance] loadUserInfos];
    [self.userInfolock lock];
    if(aUserInfos.count > 0) {
        for (AgoraChatUserInfo* userInfo in aUserInfos) {
            if(userInfo && userInfo.userId.length > 0 )
            {
                [self.dicUsersInfo setObject:userInfo forKey:userInfo.userId];
            }
        }
    }
    [self.userInfolock unlock];
}

- (void)fetchUserInfosFromServer:(NSArray<NSString*>*)aUids
{
    [self.lock lock];
    for (NSString* uid in aUids) {
        if(![self.userIds containsObject:uid])
            [self.userIds addObject:uid];
            
    }
    [self.lock unlock];
    __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), self.workQueue, ^{
        [weakself.lock lock];
        if(weakself.userIds.count > 0) {
            [[[AgoraChatClient sharedClient] userInfoManager] fetchUserInfoById:[weakself.userIds copy] completion:^(NSDictionary *aUserDatas, AgoraChatError *aError) {
                if(!aError && aUserDatas.count > 0) {
                    NSMutableArray* arrayUserInfo = [NSMutableArray array];
                    for (NSString* uid in aUserDatas) {
                        AgoraChatUserInfo* userInfo = [aUserDatas objectForKey:uid];
                        if(uid.length > 0 && userInfo)
                        {
                            [arrayUserInfo addObject:userInfo];
                            
                        }
                    }
                    [self addUserInfos:arrayUserInfo];
                    if(arrayUserInfo.count > 0) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:USERINFO_UPDATE  object:nil userInfo:@{USERINFO_LIST:arrayUserInfo}];
                    }
                }
            }];
            [weakself.userIds removeAllObjects];
        }
        [weakself.lock unlock];
    });
}

@end
