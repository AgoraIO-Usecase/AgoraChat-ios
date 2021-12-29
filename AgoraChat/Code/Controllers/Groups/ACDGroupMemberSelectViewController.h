//
//  ACDGroupMemberSelectViewController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/16.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDSearchTableViewController.h"
#import <UIKit/UIKit.h>

@class AgoraUserModel;
#import "AgoraGroupUIProtocol.h"

typedef NS_ENUM(NSUInteger, AgoraContactSelectStyle) {
    AgoraContactSelectStyle_Add      =       0,
    AgoraContactSelectStyle_Invite
};

NS_ASSUME_NONNULL_BEGIN

@interface ACDGroupMemberSelectViewController : ACDSearchTableViewController

@property (nonatomic, assign) AgoraContactSelectStyle style;

@property (nonatomic, assign) id<AgoraGroupUIProtocol> delegate;

- (instancetype)initWithInvitees:(NSArray *)aHasInvitees
                  maxInviteCount:(NSInteger)aCount;

@end


NS_ASSUME_NONNULL_END
