//
//  AgoraChatThreadListViewController.h
//  AgoraChat
//
//  Created by 朱继超 on 2022/4/5.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AgoraChatThreadListViewController : UIViewController
- (instancetype)initWithGroup:(AgoraChatGroup *)group chatViewModel:(EaseChatViewModel *)viewModel;

@end

