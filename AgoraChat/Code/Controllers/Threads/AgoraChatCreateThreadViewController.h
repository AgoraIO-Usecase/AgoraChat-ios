//
//  AgoraChatCreateThreadViewController.h
//  AgoraChat
//
//  Created by 朱继超 on 2022/4/5.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AgoraChatCreateThreadViewController : UIViewController

- (instancetype)initWithType:(EMThreadHeaderType)type viewModel:(EaseChatViewModel *)viewModel message:(EaseMessageModel *)message;

@end

