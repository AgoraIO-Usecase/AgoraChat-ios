//
//  ACDGroupNoticeViewController.m
//  AgoraChat
//
//  Created by liu001 on 2022/3/17.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDGroupNoticeViewController.h"
#import "ACDTextView.h"
#import "ACDTextViewController.h"
#import "ACDNoDataPlaceHolderView.h"

@interface ACDGroupNoticeViewController()
@property (nonatomic, strong) AgoraChatGroup *group;
@property (nonatomic, assign) BOOL isEditable;
@property (nonatomic, strong) NSString *originalString;
@property (nonatomic, strong) ACDTextView *textView;
@property (nonatomic, strong) ACDNoDataPlaceHolderView *noDataPromptView;

@end

@implementation ACDGroupNoticeViewController
- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.group = aGroup;
        self.isEditable = self.group.permissionType == AgoraChatGroupPermissionTypeOwner || self.group.permissionType == AgoraChatGroupPermissionTypeAdmin;
        self.originalString = self.group.announcement;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [ACDUtil customLeftButtonItem:@"Group Notice" action:@selector(goBack) actionTarget:self];
    
    if (self.isEditable) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", nil) style:UIBarButtonItemStylePlain target:self action:@selector(editAction)];
        self.navigationItem.rightBarButtonItem.tintColor = ButtonEnableBlueColor;
    }

    [self placeAndLayoutSubviews];
    [self updateUI];
}


- (void)placeAndLayoutSubviews {
    self.view.backgroundColor = UIColor.whiteColor;
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.view addSubview:self.textView];
    [self.view addSubview:self.noDataPromptView];

    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bgView);
        make.top.equalTo(bgView).offset(5);
        make.left.equalTo(bgView).offset(10);
    }];
    
    [self.noDataPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.left.right.equalTo(self.view);
    }];
}


- (void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Action
- (void)updateUI {
    self.textView.text = self.originalString;
    self.noDataPromptView.hidden = self.originalString.length > 0 ? YES : NO;
}

- (void)editAction
{
    [self.view endEditing:YES];
    ACDTextViewController *vc = [[ACDTextViewController alloc] initWithString:self.group.announcement placeholder:@"" isEditable:[self isEditable]];
        vc.navTitle = @"Edit Notice";
        vc.doneCompletion = ^BOOL(NSString * _Nonnull aString) {
            AgoraChatError *error = nil;
            AgoraChatGroup * group = [AgoraChatClient.sharedClient.groupManager updateGroupAnnouncementWithId:self.group.groupId announcement:aString error:&error];
            if (error == nil) {
                self.group = group;
                self.originalString = self.group.announcement;
                [self updateUI];
                if (self.updateNoticeBlock) {
                    self.updateNoticeBlock(self.group);
                }
                return YES;
            }else {
                [self showHint:error.description];
                return NO;
            }
        };
    
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.view.backgroundColor = [UIColor whiteColor];
        [self.navigationController presentViewController:nav animated:YES completion:nil];
}


- (ACDNoDataPlaceHolderView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = ACDNoDataPlaceHolderView.new;
        [_noDataPromptView.noDataImageView setImage:ImageWithName(@"no_search_result")];
        _noDataPromptView.prompt.text = @"";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}

- (ACDTextView *)textView {
    if (_textView == nil) {
        _textView = [[ACDTextView alloc] init];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.font = [UIFont systemFontOfSize:16];
        _textView.returnKeyType = UIReturnKeyDone;
        _textView.editable = NO;
    }
    return _textView;
}

@end
