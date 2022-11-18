//
//  AgoraChatThreadListNavgation.h
//  AgoraChat
//
//  Created by 朱继超 on 2022/4/5.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AgoraChatThreadListNavgation : UIView

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *detail;

@property (nonatomic, copy) void (^backBlock)(void);

@property (nonatomic, copy) void (^moreBlock)(void);

- (void)hiddenMore:(BOOL)hidden;

@end


