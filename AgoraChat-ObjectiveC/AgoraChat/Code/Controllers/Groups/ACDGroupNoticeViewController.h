//
//  ACDGroupNoticeViewController.h
//  AgoraChat
//
//  Created by liu001 on 2022/3/17.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDGroupNoticeViewController : UIViewController
@property (nonatomic, copy) void (^updateNoticeBlock)(AgoraChatGroup *aGroup);

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup;

@end

NS_ASSUME_NONNULL_END
