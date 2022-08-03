//
//  AgoraSDKOptionsViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2018/12/17.
//  Copyright © 2018 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ACDDemoOptions;
@interface AgoraSDKOptionsViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

- (instancetype)initWithEnableEdit:(BOOL)aEnableEdit
               finishCompletion:(void (^)(ACDDemoOptions *aOptions))aFinishBlock;

@end

NS_ASSUME_NONNULL_END
