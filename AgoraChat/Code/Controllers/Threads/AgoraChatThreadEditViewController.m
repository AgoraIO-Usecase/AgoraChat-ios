//
//  AgoraChatThreadEditViewController.m
//  AgoraChat
//
//  Created by 朱继超 on 2022/4/6.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "AgoraChatThreadEditViewController.h"
#import "AgoraChatThreadListNavgation.h"

@interface AgoraChatThreadEditViewController ()<UITextFieldDelegate>

@property (nonatomic) UITextField *threadNameField;

@property (nonatomic) UIView *divideLine;

@property (nonatomic) AgoraChatThreadListNavgation *navBar;

@end

@implementation AgoraChatThreadEditViewController

- (UITextField *)threadNameField {
    if (!_threadNameField) {
        _threadNameField = [[UITextField alloc] initWithFrame:CGRectMake(16, EMNavgationHeight + 10, EMScreenWidth - 32, 20)];
        _threadNameField.font = [UIFont boldSystemFontOfSize:18];
        _threadNameField.leftView = [self leftView];
        _threadNameField.placeholder = @"Thread Name";
        _threadNameField.leftViewMode = UITextFieldViewModeAlways;
        _threadNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _threadNameField.delegate = self;
        _threadNameField.returnKeyType = UIReturnKeyDone;
    }
    return _threadNameField;
}

- (UIView *)leftView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    UIImageView *icon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 32, 32)];
    icon.image = ImageWithName(@"groupThread");
    [view addSubview:icon];
    return view;
}

- (UIButton *)rightView {
    UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
    view.frame = CGRectMake(0, 0, 30, 30);
    [view setBackgroundImage:ImageWithName(@"edit_gray") forState:UIControlStateNormal];
    return view;
}

- (UIView *)divideLine {
    if (!_divideLine) {
        _divideLine = [[UIView alloc]initWithFrame:CGRectMake(16, CGRectGetMaxY(self.threadNameField.frame)+5, EMScreenWidth - 32, 1)];
        _divideLine.backgroundColor = [UIColor colorWithHexString:@"#E6E6E6"];
    }
    return _divideLine;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.navBar];
    [self.view addSubview:self.threadNameField];
    [self.view addSubview:self.divideLine];
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

- (AgoraChatThreadListNavgation *)navBar {
    if (!_navBar) {
        _navBar = [[AgoraChatThreadListNavgation alloc]initWithFrame:CGRectMake(0, 0, EMScreenWidth, EMNavgationHeight)];
        _navBar.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
        __weak typeof(self) weakSelf = self;
        _navBar.title = @"Edit Thread";
        [_navBar addSubview:[self done]];
        [_navBar setBackBlock:^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _navBar;
}

- (UIButton *)done {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(EMScreenWidth - 59, EaseVIEWBOTTOMMARGIN > 0 ? 49:29, 45, 20);
    [button setTitle:@"Done" forState:UIControlStateNormal];
    [button setTitleColor:COLOR_HEX(0x154DFE) forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)doneAction {
    if ([self.threadNameField.text isEqualToString:@""] || !self.threadNameField.text) {
        [self showHint:@"Thread name empty!"];
        return;
    }
    [self.view endEditing:YES];
    [AgoraChatClient.sharedClient.threadManager updateChatThreadName:self.threadNameField.text threadId:self.threadId completion:^(AgoraChatError *aError) {
        if (!aError) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showHint:aError.errorDescription];
        }
    }];
}

@end
