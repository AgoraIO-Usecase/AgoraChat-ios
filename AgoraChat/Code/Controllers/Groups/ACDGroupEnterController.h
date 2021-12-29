//
//  AgoraGroupEnterController.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/19.
//  Copyright © 2021 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACDSearchTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ACDGroupEnterAccessType) {
    ACDGroupEnterAccessTypeContact, // from tab contact right bar
    ACDGroupEnterAccessTypeChat,  // from tab chat right bar
};

@interface ACDGroupEnterController : ACDSearchTableViewController
@property (nonatomic, assign) ACDGroupEnterAccessType accessType;

@end

NS_ASSUME_NONNULL_END
