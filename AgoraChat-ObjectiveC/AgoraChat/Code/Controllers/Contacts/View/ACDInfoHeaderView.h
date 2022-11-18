//
//  AgoraInfoBaseHeaderView.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraChatAvatarView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ACDHeaderInfoType) {
    ACDHeaderInfoTypeContact,
    ACDHeaderInfoTypeGroup,
    ACDHeaderInfoTypeMe,
};

@interface ACDInfoHeaderView : UIView

- (instancetype)initWithFrame:(CGRect)frame
                     withType:(ACDHeaderInfoType)type;

- (instancetype)initWithType:(ACDHeaderInfoType)type;


@property (nonatomic, strong) AgoraChatAvatarView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *userIdLabel;
@property (nonatomic, strong) UILabel *describeLabel;
@property (nonatomic, assign) BOOL isHideChatButton;
@property (nonatomic, assign) BOOL isHideBackButton;
@property (nonatomic, copy) void (^tapHeaderBlock)(void);
@property (nonatomic, copy) void (^goChatPageBlock)(void);
@property (nonatomic, copy) void (^goBackBlock)(void);


@end

NS_ASSUME_NONNULL_END
