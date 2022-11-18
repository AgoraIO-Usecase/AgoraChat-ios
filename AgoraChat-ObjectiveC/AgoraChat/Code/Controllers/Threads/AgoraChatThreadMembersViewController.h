//
//  AgoraChatThreadMembersViewController.h
//  AgoraChat
//
//  Created by 朱继超 on 2022/3/13.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AgoraChatThreadMembersViewController : UIViewController

- (instancetype)initWithThread:(NSString *)threadId group:(AgoraChatGroup *)grou;

- (void)updateUI;

@end

