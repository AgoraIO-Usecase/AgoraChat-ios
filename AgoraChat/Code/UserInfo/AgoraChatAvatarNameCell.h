//
//  AgoraChatAvatarNameCell.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/9.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AgoraChatAvatarNameModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraChatAvatarNameCellDelegate;
@interface AgoraChatAvatarNameCell : UITableViewCell

@property (nonatomic, weak) id<AgoraChatAvatarNameCellDelegate> delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *detailLabel;

@property (nonatomic, strong) UILabel *timestampLabel;

@property (nonatomic, strong) UIButton *accessoryButton;

@property (nonatomic, strong) AgoraChatAvatarNameModel *model;

@end

@protocol AgoraChatAvatarNameCellDelegate<NSObject>

@optional

- (void)cellAccessoryButtonAction:(AgoraChatAvatarNameCell *)aCell;

@end

NS_ASSUME_NONNULL_END
