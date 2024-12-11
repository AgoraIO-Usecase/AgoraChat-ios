//
//  ACDPinMessagesViewController.m
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2024/3/12.
//  Copyright © 2024 easemob. All rights reserved.
//

#import "ACDPinMessagesViewController.h"
#import "ACDPinMessageCell.h"

@interface ACDPinMessagesViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,ACDPinMessageCellDelegate>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (nonatomic) BOOL isMin;

@property (nonatomic,strong) NSMutableArray<ACDPinMessageModel*>* dataArray;

@end
#define PIN_TABLEVIEW_MIN_HEIGHT 150
@implementation ACDPinMessagesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self _setupSubviews];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapAction:)];
    [self.bgView addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanAction:)];
    [self.mainView addGestureRecognizer:pan];
    self.isMin = YES;
}

- (void)handleTapAction:(UITapGestureRecognizer *)aTap
{
    [self exit];
}

- (void)exit
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)handlePanAction:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint translation = [gestureRecognizer translationInView:self.mainView];
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (translation.y > 0) {
            if (self.dataArray.count > 1) {
                self.isMin = NO;
                [self moveMainView:YES];
            }
        }
        else
        {
            if (self.dataArray.count > 1) {
                if (self.isMin)
                    [self exit];
                else {
                    self.isMin = YES;
                    [self moveMainView:NO];
                }
            } else {
                [self exit];
            }
        }
    }
}

- (void)_setupSubviews
{
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = YES;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.mainView.height = PIN_TABLEVIEW_MIN_HEIGHT;
}

- (void)setPinMessages:(NSArray<AgoraChatMessage *> *)pinMessages
{
    _pinMessages = pinMessages;
    [self.dataArray removeAllObjects];
    for (AgoraChatMessage* msg in pinMessages) {
        ACDPinMessageModel* model = [[ACDPinMessageModel alloc] initWithMessage:msg];
        [self.dataArray addObject:model];
    }
    
    self.titleLabel.text = pinMessages.count == 1 ? @"1 Pin Message" : [NSString stringWithFormat:@"%lu Pin messages",(unsigned long)pinMessages.count];
    [self.tableView reloadData];
    [self moveMainView:pinMessages.count > 0 ? NO : YES];
}

- (NSMutableArray<ACDPinMessageModel *> *)dataArray
{
    if(!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count > indexPath.row)
    {
        ACDPinMessageModel* model = [self.dataArray objectAtIndex:indexPath.row];
        AgoraChatMessage* message = model.message;
        if (message && self.selectMessageCompletion) {
            self.selectMessageCompletion(message.messageId);
        }
    }
    [self exit];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACDPinMessageModel* model = [self.dataArray objectAtIndex:indexPath.row];
    if (model) {
        return model.contentHeight;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACDPinMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ACDPinMessageCell"];
    if (cell == nil)
        cell = [[ACDPinMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ACDPinMessageCell"];
    cell.delegate = self;
    ACDPinMessageModel* model = [self.dataArray objectAtIndex:indexPath.row];
    if (model) {
        cell.model = model;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)unpinMessage:(ACDPinMessageModel *)model
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirm to remove pinned message?" message:nil preferredStyle:UIAlertControllerStyleAlert];

    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    ACD_WS
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Remove" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [AgoraChatClient.sharedClient.chatManager unpinMessage:model.message.messageId completion:^(AgoraChatMessage * _Nullable message, AgoraChatError * _Nullable aError) {
            if(aError == nil) {
                [weakSelf showHint:@"remove pinned message success"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.dataArray removeObject:model];
                    [weakSelf.tableView reloadData];
                    if (weakSelf.mainView.height != PIN_TABLEVIEW_MIN_HEIGHT) {
                        [weakSelf moveMainView:YES];
                    }
                    if (weakSelf.unpinMessageCompletion) {
                        weakSelf.unpinMessageCompletion(model.message.messageId);
                    }
                });
                
            } else {
                [weakSelf showHint:[NSString stringWithFormat:@"remove pinned message failed, %@",aError.errorDescription]];
            }
        }];
    }];
    
    [alertController addAction:confirmAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)moveMainView:(BOOL)max
{
    NSInteger contentHeight = 0;
    for (ACDPinMessageModel* model in self.dataArray) {
        contentHeight += model.contentHeight;
    }
    NSInteger maxHeight = 400;
    [UIView animateWithDuration:0.25 animations:^{
        if (max) {
            self.mainView.height = (contentHeight > maxHeight ? maxHeight : contentHeight) + 90;
        } else
            self.mainView.height = PIN_TABLEVIEW_MIN_HEIGHT;
        } completion:^(BOOL finished) {
            
            
        }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
