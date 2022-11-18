//
//  ACDAvatarCollectionCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/11/7.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDAvatarCollectionCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *iconImageView;

+ (NSString *)reuseIdentifier;

@end

NS_ASSUME_NONNULL_END
