//
//  ACDSearchJoinCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/31.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDCustomCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDSearchJoinCell : ACDCustomCell
@property (nonatomic, assign) BOOL isSearchGroup;
@property (nonatomic, copy) void (^addGroupBlock)(void);
- (void)updateSearchName:(NSString *)searchName;

@end

NS_ASSUME_NONNULL_END
