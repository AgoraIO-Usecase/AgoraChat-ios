//
//  ACDGroupShareFileModel.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/21.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDGroupShareFileModel.h"

@interface ACDGroupShareFileModel ()
@property (nonatomic, strong) AgoraChatGroupSharedFile *file;

@end

@implementation ACDGroupShareFileModel
- (instancetype)initWithObject:(NSObject *)obj {
    if ([obj isKindOfClass:[AgoraChatGroupSharedFile class]]) {
        self = [super init];
        if (self) {
            _file = (AgoraChatGroupSharedFile *)obj;
        }
        return self;
    }
    return nil;
}


- (NSString *)searchKey {
    if (self.file.fileName > 0) {
        return self.file.fileName;
    }
    return self.file.fileId;
}
@end
