//
//  ACDChatDetailViewController.h
//  AgoraChat
//
//  Created by liu001 on 2022/3/11.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDBaseTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ACDChatDetailViewController : ACDBaseTableViewController
- (instancetype)initWithCoversation:(AgoraChatConversation *)aConversation;

@end

NS_ASSUME_NONNULL_END
