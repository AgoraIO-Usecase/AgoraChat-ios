//
//  AgoraGroupMemberNewCell.h
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/25.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraChatCustomBaseCell.h"
#import "AgoraGroupUIProtocol.h"
#import "ACDCustomCell.h"

@class AgoraUserModel;

@interface AgoraGroupMemberCell : ACDCustomCell

@property (nonatomic, assign) BOOL isGroupOwner;

@property (nonatomic, assign) BOOL isEditing;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) AgoraUserModel *model;

@property (nonatomic, assign) id<AgoraGroupUIProtocol> delegate;

@end
