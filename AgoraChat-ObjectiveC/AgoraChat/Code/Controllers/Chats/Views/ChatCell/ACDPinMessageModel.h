//
//  ACDPinMessageModel.h
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2024/3/12.
//  Copyright © 2024 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ACDPinMessageModel : NSObject
@property (nonatomic,strong) AgoraChatMessage* message;
@property (nonatomic,strong) NSString* title;
@property (nonatomic,strong) NSString* dateString;
@property (nonatomic) NSUInteger contentHeight;
- (instancetype)initWithMessage:(AgoraChatMessage*)message;
@end

NS_ASSUME_NONNULL_END
