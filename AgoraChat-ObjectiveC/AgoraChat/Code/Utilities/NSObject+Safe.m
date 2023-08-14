//
//  NSObject+Safe.m
//  AgoraChat-Demo
//
//  Created by 朱继超 on 2023/8/11.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "NSObject+Safe.h"

@implementation NSObject (Safe)

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"setValue forUndefinedKey:%@", key);
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"valueForUndefinedKey:%@", key);
    return nil;
}

@end
