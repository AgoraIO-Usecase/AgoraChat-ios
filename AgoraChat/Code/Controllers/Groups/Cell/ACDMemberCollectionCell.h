//
//  ACDMemberCollectionCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/16.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AgoraUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface ACDMemberCollectionCell : UICollectionViewCell
@property (nonatomic, strong) AgoraUserModel *model;

+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
