/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "NSArray+AgoraSortContacts.h"
#import "AgoraUserModel.h"
#import "ACDGroupMemberAttributesCache.h"
#import "UserInfoStore.h"

@implementation NSArray (SortContacts)

+ (NSArray<NSArray *> *)sortContacts:(NSArray *)contacts
                       sectionTitles:(NSArray **)sectionTitles
                        searchSource:(NSArray **)searchSource {
    if (contacts.count == 0) {
        return @[];
    }
    
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *_sectionTitles = [NSMutableArray arrayWithArray:indexCollation.sectionTitles];
    NSMutableArray *_contacts = [NSMutableArray arrayWithCapacity:_sectionTitles.count];
    for (int i = 0; i < _sectionTitles.count; i++) {
        NSMutableArray *array = [NSMutableArray array];
        [_contacts addObject:array];
    }
    
    NSMutableArray *sortArray = NSMutableArray.new;
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    NSMutableArray *userInfos = NSMutableArray.new;
    [AgoraChatUserInfoManagerHelper fetchUserInfoWithUserIds:contacts completion:^(NSDictionary * _Nonnull userInfoDic) {
        for (int i = 0; i< contacts.count; ++i) {
            AgoraChatUserInfo *userInfo = userInfoDic[contacts[i]];
            if (userInfo) {
                [userInfos addObject:userInfo];
            }
        }
    
        [userInfos sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            AgoraChatUserInfo *usr1 = (AgoraChatUserInfo *)obj1;
            AgoraChatUserInfo *usr2 = (AgoraChatUserInfo *)obj2;

            return [usr1.nickname caseInsensitiveCompare:usr2.nickname];
        }];
        
        for (int k = 0; k < userInfos.count; ++k) {
            AgoraChatUserInfo *userInfo = userInfos[k];
            if (userInfo) {
                [sortArray addObject:userInfo.userId];
            }
        }
        dispatch_semaphore_signal(sem);
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    

    NSMutableArray *_searchSource = [NSMutableArray array];
    for (NSString *hyphenateId in sortArray) {
        AgoraUserModel *model = [[AgoraUserModel alloc] initWithHyphenateId:hyphenateId];
        if (model) {
            NSString *firstLetter = [model.nickname substringToIndex:1];
            NSUInteger sectionIndex = [indexCollation sectionForObject:firstLetter collationStringSelector:@selector(uppercaseString)];
            NSMutableArray *array = _contacts[sectionIndex];
            [array addObject:model];
            [_searchSource addObject:model];
        }
    }

    __block NSMutableIndexSet *indexSet = nil;
    [_contacts enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.count == 0) {
            if (!indexSet) {
                indexSet = [NSMutableIndexSet indexSet];
            }
            [indexSet addIndex:idx];
        }
    }];
    if (indexSet) {
        [_contacts removeObjectsAtIndexes:indexSet];
        [_sectionTitles removeObjectsAtIndexes:indexSet];
    }
    *searchSource = [NSArray arrayWithArray:_searchSource];
    *sectionTitles = [NSArray arrayWithArray:_sectionTitles];
    return _contacts;
}

+ (NSArray<NSArray *> *)sortGroupMembers:(NSArray *)members
                           sectionTitles:(NSArray **)sectionTitles
                            searchSource:(NSArray **)searchSource
                                 groupId:(NSString*)groupId {
    if (members.count == 0) {
        return @[];
    }
    
    UILocalizedIndexedCollation *indexCollation = [UILocalizedIndexedCollation currentCollation];
    NSMutableArray *_sectionTitles = [NSMutableArray arrayWithArray:indexCollation.sectionTitles];
    NSMutableArray *_contacts = [NSMutableArray arrayWithCapacity:_sectionTitles.count];
    for (int i = 0; i < _sectionTitles.count; i++) {
        NSMutableArray *array = [NSMutableArray array];
        [_contacts addObject:array];
    }
    
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    __block NSMutableDictionary* groupMemberInfos = [NSMutableDictionary dictionary];
    [ACDGroupMemberAttributesCache.shareInstance fetchCacheValueGroupId:groupId userIds:members key:@"nickName" completion:^(AgoraChatError * _Nullable error, NSDictionary<NSString *,NSString *> * _Nonnull value) {
        groupMemberInfos = [value mutableCopy];
        NSMutableArray<NSString*>* userIdsNeedUserInfo = [NSMutableArray array];
        NSMutableDictionary<NSString*,NSString*>* userInfosToModify = [NSMutableDictionary dictionary];
        for (NSString* key in groupMemberInfos) {
            NSString* val = [groupMemberInfos objectForKey:key];
            if (val.length == 0) {
                AgoraChatUserInfo* userInfo = [UserInfoStore.sharedInstance getUserInfoById:key];
                if (userInfo.nickname.length > 0) {
                    val = userInfo.nickname;
                    [userInfosToModify setObject:val forKey:key];
                } else {
                    [userIdsNeedUserInfo addObject:key];
                }
            }
        }
        if (userInfosToModify.count > 0) {
            [groupMemberInfos addEntriesFromDictionary:userInfosToModify];
        }
        if (userIdsNeedUserInfo.count > 0) {
            [UserInfoStore.sharedInstance fetchUserInfosFromServer:userIdsNeedUserInfo];
        }
        dispatch_semaphore_signal(sem);
    }];
    
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    

    [groupMemberInfos keysSortedByValueUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 caseInsensitiveCompare:obj2];
    }];
    NSMutableArray *_searchSource = [NSMutableArray array];
    for (NSString *hyphenateId in groupMemberInfos) {
        NSString* nickname = [groupMemberInfos objectForKey:hyphenateId];
        AgoraUserModel *model = [[AgoraUserModel alloc] initWithHyphenateId:hyphenateId nickname:nickname.length > 0?nickname:hyphenateId];
        if (model) {
            NSString *firstLetter = [model.nickname substringToIndex:1];
            NSUInteger sectionIndex = [indexCollation sectionForObject:firstLetter collationStringSelector:@selector(uppercaseString)];
            NSMutableArray *array = _contacts[sectionIndex];
            [array addObject:model];
            [_searchSource addObject:model];
        }
    }

    __block NSMutableIndexSet *indexSet = nil;
    [_contacts enumerateObjectsUsingBlock:^(NSMutableArray * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.count == 0) {
            if (!indexSet) {
                indexSet = [NSMutableIndexSet indexSet];
            }
            [indexSet addIndex:idx];
        }
    }];
    if (indexSet) {
        [_contacts removeObjectsAtIndexes:indexSet];
        [_sectionTitles removeObjectsAtIndexes:indexSet];
    }
    *searchSource = [NSArray arrayWithArray:_searchSource];
    *sectionTitles = [NSArray arrayWithArray:_sectionTitles];
    return _contacts;
}


@end
