//
//  ACDReportMessageSucceedViewController.h
//  AgoraChat
//
//  Created by 杜洁鹏 on 2022/7/14.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDReportMessageSucceedViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (nonatomic, copy) void (^doneButtonBlock)(void);
@end

NS_ASSUME_NONNULL_END
