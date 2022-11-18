//
//  ACDGroupShareFileModel.h
//  AgoraChat
//
//  Created by liu001 on 2022/3/21.
//  Copyright © 2022 easemob. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAgoraRealtimeSearch.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDGroupShareFileModel : NSObject<IAgoraRealtimeSearch>
@property (nonatomic, strong,readonly) AgoraChatGroupSharedFile *file;

- (instancetype)initWithObject:(NSObject *)obj;

@end

NS_ASSUME_NONNULL_END
