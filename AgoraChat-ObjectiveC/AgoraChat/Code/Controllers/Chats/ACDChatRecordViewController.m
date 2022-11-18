//
//  EMChatRecordViewController.m
//  EaseIM
//
//  Created by 娜塔莎 on 2020/7/15.
//  Copyright © 2020 娜塔莎. All rights reserved.
//

#import "ACDChatRecordViewController.h"
#import "AgoraChatAvatarNameCell.h"
#import "ACDDateHelper.h"
#import "AgoraChatAvatarNameModel.h"
#import "ACDChatViewController.h"

@interface ACDChatRecordViewController ()<AgoraChatSearchBarDelegate, AgoraChatAvatarNameCellDelegate>

@property (nonatomic, strong) AgoraChatConversation *conversation;
@property (nonatomic, strong) dispatch_queue_t msgQueue;
//消息格式化
@property (nonatomic) NSTimeInterval msgTimelTag;
@property (nonatomic, strong) NSString *keyWord;

@end

@implementation ACDChatRecordViewController

- (instancetype)initWithCoversationModel:(AgoraChatConversation *)conversation
{
    if (self = [super init]) {
        _conversation = conversation;
        _msgQueue = dispatch_queue_create("AgoraChatMessagerecord.com", NULL);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgTimelTag = -1;
    [self _setupChatSubviews];
}

#pragma mark - Subviews

- (void)_setupChatSubviews
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.showRefreshHeader = NO;
    self.searchBar.delegate = self;
    self.searchBar.layer.cornerRadius = 20;
    
    [self.searchBar mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view).offset(8);
        make.right.equalTo(self.view).offset(-8);
        make.height.equalTo(@36);
    }];
    [self.searchBar.textField becomeFirstResponder];
    
    self.searchResultTableView.backgroundColor = UIColor.whiteColor;
    self.searchResultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchResultTableView.rowHeight = UITableViewAutomaticDimension;
    self.searchResultTableView.estimatedRowHeight = 130;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id obj = [self.searchResults objectAtIndex:indexPath.row];
    AgoraChatAvatarNameModel *model = (AgoraChatAvatarNameModel *)obj;

    AgoraChatAvatarNameCell *cell = (AgoraChatAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"chatRecord"];
    // Configure the cell...
    if (cell == nil) {
        cell = [[AgoraChatAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"chatRecord"];
    }
    cell.indexPath = indexPath;
    cell.model = model;
    cell.delegate = self;
    return cell;
}

#pragma mark - ACDAvatarNameCellDelegate

- (void)cellAccessoryButtonAction:(AgoraChatAvatarNameCell *)aCell
{
    ACDChatViewController *chatController = [[ACDChatViewController alloc]initWithConversationId:self.conversation.conversationId conversationType:self.conversation.type];
    chatController.modalPresentationStyle = 0;
    [self.navigationController pushViewController:chatController animated:YES];
}

#pragma mark - EMSearchBarDelegate

- (void)searchBarSearchButtonClicked:(NSString *)aString
{
    _keyWord = aString;
    [self.view endEditing:YES];
    if ([_keyWord length] < 1)
        return;
    if (!self.isSearching) return;
    __weak typeof(self) weakself = self;
    [self.conversation loadMessagesWithKeyword:aString timestamp:0 count:50 fromUser:nil searchDirection:AgoraChatMessageSearchDirectionDown completion:^(NSArray *aMessages, AgoraChatError *aError) {
        if (!aError && [aMessages count] > 0) {
            dispatch_async(self.msgQueue, ^{
                NSMutableArray *msgArray = [[NSMutableArray alloc] init];
                for (int i = 0; i < [aMessages count]; i++) {
                    AgoraChatMessage *msg = aMessages[i];
                    if(msg.body.type == AgoraChatMessageBodyTypeText) {
                        AgoraChatTextMessageBody* textBody = (AgoraChatTextMessageBody*)msg.body;
                        NSRange range = [textBody.text rangeOfString:aString options:NSCaseInsensitiveSearch];
                        if(range.length)
                            [msgArray addObject:msg];
                    }
                    
                }
                NSArray *formated = [weakself _formatMessages:[msgArray copy]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.searchResults removeAllObjects];
                    [weakself.searchResults addObjectsFromArray:formated];
                    [weakself.searchResultTableView reloadData];
                });
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakself.searchResults removeAllObjects];
                [weakself.searchResultTableView reloadData];
            });
        }
    }];
}

#pragma mark - Data

- (NSArray *)_formatMessages:(NSArray<AgoraChatMessage *> *)aMessages
{
    NSMutableArray *formated = [[NSMutableArray alloc] init];
    NSString *timeStr;
    for (int i = 0; i < [aMessages count]; i++) {
        AgoraChatMessage *msg = aMessages[i];
        if (!(msg.body.type == AgoraChatMessageBodyTypeText))
            continue;
        if ([msg.ext objectForKey:MSG_EXT_GIF] || [msg.ext objectForKey:MSG_EXT_RECALL] || [msg.ext objectForKey:MSG_EXT_NEWNOTI])
            continue;
        
        CGFloat interval = (self.msgTimelTag - msg.timestamp) / 1000;
        if (self.msgTimelTag < 0 || interval > 60 || interval < -60) {
            timeStr = [ACDDateHelper formattedTimeFromTimeInterval:msg.timestamp];
            self.msgTimelTag = msg.timestamp;
        }
        AgoraChatAvatarNameModel *model = [[AgoraChatAvatarNameModel alloc]initWithInfo:_keyWord img:[UIImage imageNamed:@"defaultAvatar"] msg:msg time:timeStr];
        [formated addObject:model];
    }
    
    return formated;
}

@end
