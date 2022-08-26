//
//  ACDReportMessageViewContoller.m
//  AgoraChat
//
//  Created by 杜洁鹏 on 2022/7/7.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDReportMessageViewController.h"
#import "ACDNormalNavigationView.h"
#import "ACDReportMessageTagCell.h"
#import "ACDReportMessageBaseCell.h"
#import "ACDReportMessageReasonCell.h"
#import "UIViewController+HUD.h"
#import "ACDReportMessageSucceedViewController.h"

@interface ACDReportMessageViewController () <UITableViewDelegate, UITableViewDataSource>
{
    EaseMessageModel* _reportMessageModel;
    NSString *_tagStr;
    NSString *_cellID;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ACDNormalNavigationView *navigationView;

@end

@implementation ACDReportMessageViewController

- (instancetype)initWithReportMessage:(EaseMessageModel *)messageModel {
    if (self = [super init]) {
        _reportMessageModel = messageModel;
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tagStr = @"Adult";
    
    switch(_reportMessageModel.type) {
        case AgoraChatMessageTypeText:
        {
            _cellID = @"ReportTextMessageCell";
        }
            break;
        case AgoraChatMessageTypeImage:
        case AgoraChatMessageTypeVideo:
        case AgoraChatMessageTypeVoice:
        case AgoraChatMessageTypeFile:
        {
            _cellID = @"ReportDocumentMessageCell";
        }
            break;
        default:
            _cellID = nil;
            break;
    }
   
    [self _setupChatSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)_setupChatSubviews
{
    [self.view addSubview:self.navigationView];
    [self.view addSubview:self.tableView];
    [self.navigationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(_tableView.mas_top);
    }];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(AgoraChatVIEWTOPMARGIN + 60.0, 0, 0, 0));
    }];
    self.view.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)doneAction {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Confirm to Report?" message:nil preferredStyle:UIAlertControllerStyleAlert];

    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    ACD_WS
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf reportAction];
    }];
    
    [alertController addAction:confirmAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)reportAction {
    [self showHudInView:self.view hint:@"Loading..."];
    
    ACDReportMessageReasonCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    NSString *reason = cell.textView.text;
    ACD_WS
    [AgoraChatClient.sharedClient.chatManager reportMessageWithId:_reportMessageModel.message.messageId tag:_tagStr reason:reason completion:^(AgoraChatError * _Nullable error) {
        [weakSelf hideHud];
        if (error) {
            [weakSelf showHint:error.errorDescription];
        }else {
            ACDReportMessageSucceedViewController *succedVC = [[ACDReportMessageSucceedViewController alloc] initWithNibName:@"ACDReportMessageSucceedViewController" bundle:nil];
            __weak typeof(succedVC) weakVC = succedVC;
            succedVC.doneButtonBlock = ^{
                [weakVC dismissViewControllerAnimated:NO completion:nil];
                [weakSelf backAction];
            };
            succedVC.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:succedVC animated:YES completion:^{
                self.tableView.hidden = YES;
            }];
        }
    }];
}

- (void)showTagsMenu {
    [self.view endEditing:YES];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *adultAction = [UIAlertAction actionWithTitle:@"Adult" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _tagStr = @"Adult";
        [self.tableView reloadData];
    }];
    [alertController addAction:adultAction];
    [adultAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    UIAlertAction *racyAction = [UIAlertAction actionWithTitle:@"Racy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _tagStr = @"Racy";
        [self.tableView reloadData];
    }];
    [alertController addAction:racyAction];
    
    [racyAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
    
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"Other" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        _tagStr = @"Other";
        [self.tableView reloadData];
    }];
    [alertController addAction:otherAction];
    
    [otherAction setValue:TextLabelBlackColor forKey:@"titleTextColor"];
   
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma - mark UITableViewDataSource & UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        if (_cellID) {
            cell = [tableView dequeueReusableCellWithIdentifier:_cellID forIndexPath:indexPath];
            [(ACDReportMessageBaseCell *)cell setModel:_reportMessageModel];
        }else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"BaseCell" forIndexPath:indexPath];
        }
    }else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ReportMessageTagCell" forIndexPath:indexPath];
        [(ACDReportMessageTagCell *)cell tagLabel].text = _tagStr;
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ReportMessageReasonCell" forIndexPath:indexPath];
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        [self showTagsMenu];
    }
}

#pragma - mark getter & setter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerClass:[ACDReportMessageBaseCell class] forCellReuseIdentifier:@"BaseCell"];
        
        UINib *textCellNib = [UINib nibWithNibName:@"ACDReportTextMessageCell" bundle:nil];
        [_tableView registerNib:textCellNib forCellReuseIdentifier:@"ReportTextMessageCell"];
        
        UINib *documentCellNib = [UINib nibWithNibName:@"ACDReportDocumentMessageCell" bundle:nil];
        [_tableView registerNib:documentCellNib forCellReuseIdentifier:@"ReportDocumentMessageCell"];
        
        UINib *tagCellNib = [UINib nibWithNibName:@"ACDReportMessageTagCell" bundle:nil];
        [_tableView registerNib:tagCellNib forCellReuseIdentifier:@"ReportMessageTagCell"];
        
        UINib *reasonCellNib = [UINib nibWithNibName:@"ACDReportMessageReasonCell" bundle:nil];
        [_tableView registerNib:reasonCellNib forCellReuseIdentifier:@"ReportMessageReasonCell"];
    }
    
    return _tableView;
}

- (ACDNormalNavigationView *)navigationView {
    if (_navigationView == nil) {
        _navigationView = [[ACDNormalNavigationView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 80.0f)];
        _navigationView.leftLabel.text = @"Message Report";
        _navigationView.leftLabel.font = [UIFont boldSystemFontOfSize:18];
        [_navigationView.rightButton setTitle:@"Done" forState:UIControlStateNormal];
        [_navigationView.rightButton setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
        ACD_WS
        _navigationView.leftButtonBlock = ^{
            [weakSelf backAction];
        };
        
        _navigationView.rightButtonBlock = ^{
            [weakSelf doneAction];
        };
        
        _navigationView.tag = -2000;
    }
    return _navigationView;
}

@end
