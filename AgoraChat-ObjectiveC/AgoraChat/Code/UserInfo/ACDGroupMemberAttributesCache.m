//
//  ACDGroupMemberAttributesCache.m
//  EaseIM
//
//  Created by 朱继超 on 2023/1/16.
//  Copyright © 2023 朱继超. All rights reserved.
//

#import "ACDGroupMemberAttributesCache.h"
#import "NSDictionary+Safely.h"
#import "UserInfoStore.h"

static ACDGroupMemberAttributesCache *instance = nil;

@interface ACDGroupMemberAttributesCache ()

@property (nonatomic) NSMutableDictionary *attributes;

@property (atomic) NSMutableArray *userNames;

@end

@implementation ACDGroupMemberAttributesCache

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[ACDGroupMemberAttributesCache alloc] init];
    });
    return instance;
}

- (void)removeAllCaches {
    [self.attributes removeAllObjects];
}

- (instancetype)init {
    if ([super init]) {
        _userNames = [NSMutableArray array];
        _attributes = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)updateCacheWithGroupId:(NSString *)groupId userName:(NSString *)userName key:(NSString *)key value:(NSString *)value {
    NSMutableDictionary<NSString*,NSString*> *usesAttributes = [self.attributes objectForKeySafely:groupId];
    if (usesAttributes == nil || ![usesAttributes isKindOfClass:[NSMutableDictionary class]]) {
        usesAttributes = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary<NSString*,NSString*> *attributes = [usesAttributes objectForKeySafely:userName];
    if (attributes == nil || ![attributes isKindOfClass:[NSMutableDictionary class]]) {
        attributes = [NSMutableDictionary dictionary];
    }
    [attributes setObject:value forKeySafely:key];
    [usesAttributes setObject:attributes forKeySafely:userName];
    [self.attributes setObject:usesAttributes forKeySafely:groupId];
}

- (void)updateCacheWithGroupId:(NSString *)groupId userName:(NSString *)userName attributes:(NSDictionary<NSString*,NSString*>*)attributes {
    NSMutableDictionary<NSString*,NSString*> *usesAttributes = [self.attributes objectForKeySafely:groupId];
    if (usesAttributes == nil || ![usesAttributes isKindOfClass:[NSMutableDictionary class]]) {
        usesAttributes = [NSMutableDictionary dictionary];
    }
    [usesAttributes setObject:attributes forKeySafely:userName];
    [self.attributes setObject:usesAttributes forKeySafely:groupId];
}

- (void)removeCacheWithGroupId:(NSString *)groupId {
    [self.attributes setObject:[@{} mutableCopy] forKeySafely:groupId];
}

- (void)removeCacheWithGroupId:(NSString *)groupId userId:(NSString *)userId {
    [[self.attributes objectForKeySafely:groupId] setObject:[@{} mutableCopy] forKeySafely:userId];
}

- (void)fetchCacheValueGroupId:(NSString *)groupId userName:(NSString *)userName key:(NSString *)key completion:(void(^)(AgoraChatError *_Nullable error,NSString * _Nullable value))completion {
    if( userName.length <= 0 || key.length <= 0)
        return;
    __block NSString *value = [[[self.attributes objectForKeySafely:groupId] objectForKeySafely:userName] objectForKeySafely:key];
    if (![self.userNames containsObject:userName] || value == nil) {
        [self.userNames addObject:userName];
        [AgoraChatClient.sharedClient.groupManager fetchMembersAttributes:groupId userIds:self.userNames keys:@[key] completion:^(NSDictionary<NSString *,NSDictionary<NSString *,NSString *> *> * _Nullable attributes, AgoraChatError * _Nullable error) {
            if (error == nil) {
                for (NSString *userNameKey in attributes.allKeys) {
                    NSDictionary<NSString *,NSString *> *dic = [attributes objectForKeySafely:userNameKey];
                    NSString* nickname = [dic valueForKeySafely:GROUP_NICKNAME_KEY];
                    if (nickname.length == 0)
                        nickname = @"";
                    [self updateCacheWithGroupId:groupId userName:userNameKey key:GROUP_NICKNAME_KEY value:nickname];
                    [self.userNames removeObject:userNameKey];
                }
            } else {
                for (NSString *userNameKey in attributes.allKeys) {
                    [self.userNames removeObject:userNameKey];
                }
            }
            if (completion) {
                completion(error,value);
            }
        }];
    } else {
        [self.userNames removeObject:userName];
        completion(nil,value);
    }
    
}

- (NSString *)fetchGroupAlias:(NSString *)groupId userId:(NSString *)usrId
{
    NSString *value = [[[self.attributes objectForKeySafely:groupId] objectForKeySafely:usrId] objectForKeySafely:GROUP_NICKNAME_KEY];
    return value;
}

- (void)fetchCacheValueGroupId:(NSString *)groupId userIds:(NSArray *)userName key:(NSString *)key completion:(void(^)(AgoraChatError *_Nullable error,NSDictionary<NSString*, NSString *>* value))completion
{
    NSMutableArray<NSString* >* memberToFetch = [NSMutableArray array];
    NSMutableDictionary* result = [NSMutableDictionary dictionary];
    for (NSString* userId in userName) {
        NSString* tmp = [[[self.attributes objectForKeySafely:groupId] objectForKeySafely:userId] objectForKeySafely:GROUP_NICKNAME_KEY];
        if (tmp == nil) {
            [memberToFetch addObject:userId];
            [result setObject:@"" forKey:userId];
        } else {
            [result setObject:tmp forKey:userId];
        }
    }
    [AgoraChatClient.sharedClient.groupManager fetchMembersAttributes:groupId userIds:memberToFetch keys:@[key] completion:^(NSDictionary<NSString *,NSDictionary<NSString *,NSString *> *> * _Nullable attributes, AgoraChatError * _Nullable error) {
        if (!error) {
            for (NSString* user in attributes) {
                NSDictionary* keyValues = [attributes valueForKeySafely:user];
                NSString* value = [keyValues objectForKey:GROUP_NICKNAME_KEY];
                if (value.length > 0) {
                    [self updateCacheWithGroupId:groupId userName:user key:key value:value];
                    [result setObject:value forKey:user];
                }
            }
        }
        if (completion)
            completion(error,result);
    }];
}

- (void)setGroupMemberAttributes:(NSString *)groupId userName:(NSString *)userName key:(NSString *)key value:(NSString *)value completion:(void(^)(AgoraChatError *error))completion {
    [AgoraChatClient.sharedClient.groupManager setMemberAttribute:groupId userId:userName attributes:@{key:value} completion:^(AgoraChatError * _Nullable error) {
        if (error == nil) {
            [self updateCacheWithGroupId:groupId userName:userName key:key value:value];
        }
        if (completion) {
            completion(error);
        }
    }];
}
@end
