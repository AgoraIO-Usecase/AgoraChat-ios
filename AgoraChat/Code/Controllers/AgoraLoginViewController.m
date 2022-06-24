//
//  AgoraNewLoginViewController.m
//  login-UI3.0
//
//  Created by liang on 2021/10/18.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraLoginViewController.h"
#import "AgoraChatHttpRequest.h"
#import "UserInfoStore.h"
#import "Reachability.h"
#import "UIViewController+ComponentSize.h"
#import "AgoraChatCallKitManager.h"
#import "EMRightViewToolView.h"

#define kLoginButtonHeight 48.0f
#define kMaxLimitLength 64

@interface AgoraLoginViewController ()<UITextViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIImageView* titleImageView;
@property (nonatomic, strong) UILabel *titleRegisterMarkLabel;
@property (nonatomic, strong) UIView *hintView;
@property (nonatomic, strong) UILabel *hintTitleLabel;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *passwordConfirmTextField;
@property (nonatomic, strong) UIButton *loginButton;

@property (nonatomic, strong) EMRightViewToolView *confirmPswdRightView;
@property (nonatomic, strong) EMRightViewToolView *pswdRightView;
@property (nonatomic, strong) EMRightViewToolView *userIdRightView;

@property (nonatomic, strong) UIButton *registerButton;
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, assign) CGFloat loadingAngle;

@property (nonatomic, strong) UIButton *operateTypeButton;

@end

@implementation AgoraLoginViewController

#pragma mark life cycle
- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupForDismissKeyboard];
    [self placeAndLayoutSubViews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)placeAndLayoutSubViews
{
    self.contentView = [[UIView alloc]init];
    self.contentView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.logoImageView];
    [self.contentView addSubview:self.titleImageView];
    [self.contentView addSubview:self.hintView];
    [self.contentView addSubview:self.usernameTextField];
    [self.contentView addSubview:self.passwordTextField];
    [self.contentView addSubview:self.passwordConfirmTextField];
    [self.contentView addSubview:self.loginButton];
    [self.contentView addSubview:self.operateTypeButton];

    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    [self.logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView.mas_top).offset(134.0);
        make.centerX.equalTo(self.contentView);
    }];
    
    [self.titleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.logoImageView.mas_bottom).offset(20);
        make.centerX.equalTo(self.contentView);
    }];
    
//    [self.titleRegisterMarkLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.titleImageView);
//        make.left.equalTo(self.titleImageView.mas_right).offset(4);
//        make.width.equalTo(@90);
//    }];
    
    [self.usernameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleImageView.mas_bottom).offset(95);
        make.left.equalTo(self.contentView).offset(24);
        make.right.equalTo(self.contentView).offset(-24);
        make.height.equalTo(@kLoginButtonHeight);
    }];
    
    [self.hintView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.usernameTextField.mas_top).offset(-10);
        make.centerX.equalTo(self.contentView);
        make.height.equalTo(@20);
    }];
    self.hintView.hidden = YES;
    
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_usernameTextField.mas_bottom).offset(20);
        make.left.equalTo(self.usernameTextField);
        make.right.equalTo(self.usernameTextField);
        make.height.equalTo(@kLoginButtonHeight);
    }];
    
    [self.passwordConfirmTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_passwordTextField.mas_bottom).offset(20);
        make.left.equalTo(self.passwordTextField);
        make.right.equalTo(self.passwordTextField);
        make.height.equalTo(@kLoginButtonHeight);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.mas_bottom).offset(kAgroaPadding * 2);
        make.left.equalTo(self.usernameTextField);
        make.right.equalTo(self.usernameTextField);
        make.height.equalTo(@kLoginButtonHeight);
    }];
    
    [self.operateTypeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginButton.mas_bottom).offset(kAgroaPadding * 2);
        make.left.equalTo(self.loginButton);
        make.right.equalTo(self.loginButton);
        make.height.equalTo(@kLoginButtonHeight);
    }];
    
    self.passwordConfirmTextField.hidden = YES;
}

#pragma mark - UITextFieldDelegate

- (NSUInteger)charactorNumberWithEncoding:(NSString *)str
{
    NSUInteger strLength = 0;
    char *p = (char *)[str cStringUsingEncoding:NSUTF8StringEncoding];
    
    NSUInteger lengthOfBytes = [str lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    for (int i = 0; i < lengthOfBytes; i++) {
        if (*p) {
            p++;
            strLength++;
        }
        else {
            p++;
        }
    }
    return strLength;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.contentView endEditing:YES];
    return YES;
}


#pragma mark - private
- (NSAttributedString *)textFieldAttributeString:(NSString *)content {
    
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:content attributes:
        @{NSForegroundColorAttributeName:COLOR_HEX(0x999999),
          NSFontAttributeName:[UIFont fontWithName:@"PingFang SC" size:14.0]
        }];
    return attrString;
}

- (void)startAnimation {
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(self.loadingAngle * (M_PI /180.0f));

    [UIView animateWithDuration:0.05 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{        self.loadingImageView.transform = endAngle;
    } completion:^(BOOL finished) {
        self.loadingAngle += 15;
        [self startAnimation];
    }];
}

- (void)updateLoginStateWithStart:(BOOL)start{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (start) {
            [self.loginButton setTitle:@"" forState:UIControlStateNormal];
            self.loadingImageView.hidden = NO;
            [self startAnimation];
            
        }else {
            if (self.operateTypeButton.tag == 0) {
                [self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
            } else {
                [self.loginButton setTitle:@"Register" forState:UIControlStateNormal];
            }
            self.loadingImageView.hidden = YES;
        }
    });
}


- (BOOL)_isEmpty
{
    BOOL ret = NO;
    NSString *username = _usernameTextField.text;
    NSString *password = _passwordTextField.text;
    if (username.length == 0 || password.length == 0) {
        ret = YES;
        self.hintView.hidden = NO;
        self.hintTitleLabel.text = NSLocalizedString(@"login.inputNameAndPswd", @"Please enter username and nickname");
    } else {
        NSString *regex = @"^[A-Za-z0-9]+$";
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
        BOOL result = [predicate evaluateWithObject:username];
        if (!result) {
            ret = YES;
            self.hintView.hidden = NO;
            self.hintTitleLabel.text = NSLocalizedString(@"login.inputNameNotCompliance", @"Latin letters and numbers only.");
        }
    }
    
    return ret;
}

- (BOOL)conecteNetwork
{
    Reachability *reachability   = [Reachability reachabilityWithHostName:@"www.apple.com"];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    if (internetStatus == NotReachable) {
        return NO;
    }
    return YES;
}

- (void)changeOperate:(UIButton *)aButton
{
    self.hintView.hidden = YES;
    self.hintTitleLabel.text = @"";
    if (aButton.tag == 0) {
        //self.titleRegisterMarkLabel.hidden = NO;
//        [self.titleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.titleView).offset(- 47);
//        }];
        
        self.titleImageView.image = ImageWithName(@"login.bundle/register_agoraChat");
        
        [self.usernameTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleImageView.mas_bottom).offset(65);
            make.left.equalTo(self.contentView).offset(24);
            make.right.equalTo(self.contentView).offset(-24);
            make.height.equalTo(@kLoginButtonHeight);
        }];
        
        self.passwordConfirmTextField.hidden = NO;
        [self.loginButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordConfirmTextField.mas_bottom).offset(kAgroaPadding * 2);
            make.left.equalTo(self.usernameTextField);
            make.right.equalTo(self.usernameTextField);
            make.height.equalTo(@kLoginButtonHeight);
        }];
        
        aButton.tag = 1;
        [self.loginButton setTitle:@"Set Up" forState:UIControlStateNormal];
        [self.operateTypeButton setAttributedTitle:[self attributeText:@"Back to Login" key:@"Back to Login"] forState:UIControlStateNormal];
    } else {
//        self.titleRegisterMarkLabel.hidden = YES;
//        [self.titleImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.equalTo(self.titleView);
//        }];
        self.titleImageView.image = ImageWithName(@"login.bundle/login_agoraChat");
        
        [self.usernameTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleImageView.mas_bottom).offset(95);
            make.left.equalTo(self.contentView).offset(24);
            make.right.equalTo(self.contentView).offset(-24);
            make.height.equalTo(@kLoginButtonHeight);
        }];
        
        self.passwordConfirmTextField.hidden = YES;
        [self.loginButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.passwordTextField.mas_bottom).offset(kAgroaPadding * 2);
            make.left.equalTo(self.usernameTextField);
            make.right.equalTo(self.usernameTextField);
            make.height.equalTo(@kLoginButtonHeight);
        }];
        
        aButton.tag = 0;
        [self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
        [self.operateTypeButton setAttributedTitle:[self attributeText:@"No account? Register" key:@"Register"] forState:UIControlStateNormal];
    }
}

- (void)doLogin {
    
    if (![self conecteNetwork]) {
        self.hintView.hidden = NO;
        self.hintTitleLabel.text = NSLocalizedString(@"networkReachable", @"Network disconnected.");
        return;
    }
    
    if ([self _isEmpty]) {
        return;
    }
    if (self.operateTypeButton.tag == 1) {
        if (![_passwordTextField.text isEqualToString:_passwordConfirmTextField.text]) {
            self.hintView.hidden = NO;
            self.hintTitleLabel.text = NSLocalizedString(@"register.confirm.differentPswd", @"Please enter the same password");
            return;
        }
    }
    [self.view endEditing:YES];
        
    [self updateLoginStateWithStart:YES];
    self.hintView.hidden = YES;
    self.hintTitleLabel.text = @"";
    
    if (self.operateTypeButton.tag == 1) {
        [self doRegister];
        return;
    }
    
    void (^finishBlock) (NSString *aName, NSString *nickName, NSInteger agoraUid, AgoraChatError *aError) = ^(NSString *aName, NSString *nickName, NSInteger agoraUid, AgoraChatError *aError) {
        if (!aError) {
            if (nickName) {
//                [AgoraChatClient.sharedClient.userInfoManager updateOwnUserInfo:nickName withType:AgoraChatUserInfoTypeNickName completion:^(AgoraChatUserInfo *aUserInfo, AgoraChatError *aError) {
//                    if (!aError) {
//                        [self updateLoginStateWithStart:NO];
//
//                        [UserInfoStore.sharedInstance setUserInfo:aUserInfo forId:aName];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:USERINFO_UPDATE  object:nil userInfo:@{USERINFO_LIST:@[aUserInfo]}];
//                    }
//                }];
//                if (aError.code == 204) {
//                    [AgoraChatClient.sharedClient registerWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
//                } else {
                
//                }
            }
            
            NSUserDefaults *shareDefault = [NSUserDefaults standardUserDefaults];
            [shareDefault setObject:aName forKey:USER_NAME];
            [shareDefault setObject:nickName forKey:USER_NICKNAME];
            [shareDefault setObject:@(agoraUid) forKey:USER_AGORA_UID];
            [shareDefault setObject:self.passwordTextField.text forKey:USER_PWD];
            [shareDefault synchronize];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hintView.hidden = YES;
                self.hintTitleLabel.text = @"";
                [AgoraChatCallKitManager.shareManager updateAgoraUid:agoraUid];
                [self updateLoginStateWithStart:NO];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES userInfo:@{@"userName":aName,@"nickName":!nickName ? @"" : nickName}];
            });
            return ;
        }
        
        NSString *errorDes = NSLocalizedString(@"login.failure", @"login failure");
        switch (aError.code) {
            case AgoraChatErrorServerNotReachable:
                errorDes = NSLocalizedString(@"error.connectServerFail", @"Connect to the server failed!");
                break;
            case AgoraChatErrorNetworkUnavailable:
                errorDes = NSLocalizedString(@"error.connectNetworkFail", @"No network connection!");
                break;
            case AgoraChatErrorServerTimeout:
                errorDes = NSLocalizedString(@"error.connectServerTimeout", @"Connect to the server timed out!");
                break;
            case AgoraChatErrorUserAlreadyExist:
                errorDes = NSLocalizedString(@"login.taken", @"Username taken");
                break;
            default:
                errorDes = NSLocalizedString(@"login.failure", @"login failure");
                break;
        }
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:nil message:errorDes delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"login.ok", @"Ok"), nil];
        [alertError show];
        
        self.hintView.hidden = NO;
        self.hintTitleLabel.text = errorDes;
        [self updateLoginStateWithStart:NO];
    };
    
    //unify token login
    [[AgoraChatHttpRequest sharedManager] loginToApperServer:[_usernameTextField.text lowercaseString] pwd:_passwordTextField.text completion:^(NSInteger statusCode, NSString * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *alertStr = nil;
            if (response && response.length > 0 && statusCode) {
                NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                NSString *token = [responsedict objectForKey:@"accessToken"];
                NSString *loginName = [responsedict objectForKey:@"chatUserName"];
                NSString *nickName = [responsedict objectForKey:@"chatUserNickname"];
                NSInteger agoraUid = [responsedict[@"agoraUid"] integerValue];

                if (token && token.length > 0) {
                    [[AgoraChatClient sharedClient] loginWithUsername:[loginName lowercaseString] agoraToken:token completion:^(NSString *aUsername, AgoraChatError *aError) {
                        finishBlock(aUsername, nickName, agoraUid, aError);
                    }];
                    return;
                } else {
                    alertStr = NSLocalizedString(@"login analysis token failure", @"analysis token failure");
                }
            } else {
                alertStr = NSLocalizedString(@"login appserver failure", @"Sign in appserver failure");
            }
            [self updateLoginStateWithStart:NO];
            finishBlock([_usernameTextField.text lowercaseString], @"", 0, nil);
        });
    }];
}

- (void)doRegister
{
    [[AgoraChatHttpRequest sharedManager] registerToApperServer:[_usernameTextField.text lowercaseString] pwd:_passwordTextField.text completion:^(NSInteger statusCode, NSString * _Nonnull response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *alertStr = nil;
            BOOL isRegisterSuccess = NO;
            if (response && response.length > 0 && statusCode) {
                NSData *responseData = [response dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary *responsedict = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
                NSString *result = [responsedict objectForKey:@"code"];
                if ([result isEqualToString:@"RES_OK"]) {
                    isRegisterSuccess = YES;
                    alertStr = NSLocalizedString(@"register appserver success", @"Register appserver success");
                } else {
                    alertStr = NSLocalizedString(@"register appserver failure", @"Sign in appserver failure");
                }
            } else {
                alertStr = NSLocalizedString(@"register appserver failure", @"Sign in appserver failure");
            }
            
            [self updateLoginStateWithStart:NO];
            
            if (!isRegisterSuccess) {
                self.hintView.hidden = NO;
                self.hintTitleLabel.text = alertStr;
            }

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertStr delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"RegisterAppServer.ok", @"Ok"), nil];
            [alert show];
        });
    }];
}

#pragma mark - notification

#pragma mark - KeyBoard

- (void)keyBoardWillShow:(NSNotification *)note
{
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    
    CGFloat offset = 0;
    if (self.contentView.frame.size.height - keyBoardHeight <= CGRectGetMaxY(self.loginButton.frame)) {
        offset = CGRectGetMaxY(self.loginButton.frame) - (self.contentView.frame.size.height - keyBoardHeight);
    } else {
        return;
    }
    
    void (^animation)(void) = ^void(void) {
        [self.logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(134.0 - offset - 20);
        }];
    };
    [self keyBoardWillShow:note animations:animation completion:nil];
}

- (void)keyBoardWillHide:(NSNotification *)note
{
    void (^animation)(void) = ^void(void) {
        [self.logoImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView.mas_top).offset(134.0);
        }];
    };
    [self keyBoardWillHide:note animations:animation completion:nil];
}

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSValue *beginValue = [userInfo objectForKey:@"UIKeyboardFrameBeginUserInfoKey"];
    NSValue *endValue = [userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"];
    CGRect beginRect;
    [beginValue getValue:&beginRect];
    CGRect endRect;
    [endValue getValue:&endRect];
    
    CGRect buttonFrame = _loginButton.frame;
    CGFloat top = 0;

    if (endRect.origin.y == self.view.frame.size.height) {
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame);
    } else if(beginRect.origin.y == self.view.frame.size.height){
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame) - CGRectGetHeight(endRect) + 100;
        top = -100;
    } else {
        buttonFrame.origin.y = KScreenHeight - CGRectGetHeight(buttonFrame) - CGRectGetHeight(endRect) + 100;
        top = -100;
    }
    [UIView animateWithDuration:0.3 animations:^{
        //[[UIApplication sharedApplication].keyWindow setTop:top];
//        _loginButton.frame = buttonFrame;
    }];
}

#pragma mark Action

//clear user id
- (void)clearUserIdAction
{
    self.usernameTextField.text = @"";
    self.userIdRightView.hidden = YES;
}

//hidden show pwd
- (void)pswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.passwordTextField.secureTextEntry = !self.passwordTextField.secureTextEntry;
}

//hidden show confirm pwd
- (void)confirmPswdSecureAction:(UIButton *)aButton
{
    aButton.selected = !aButton.selected;
    self.passwordConfirmTextField.secureTextEntry = !self.passwordConfirmTextField.secureTextEntry;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.usernameTextField && [self.usernameTextField.text length] == 0) {
        self.userIdRightView.hidden = YES;
    }
    if (textField == self.passwordTextField && [self.passwordTextField.text length] == 0) {
        self.pswdRightView.hidden = YES;
    }
    if (textField == self.passwordConfirmTextField && [self.passwordConfirmTextField.text length] == 0) {
        self.confirmPswdRightView.hidden = YES;
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }
    if (textField == self.usernameTextField) {
        self.userIdRightView.hidden = NO;
        if ([self.usernameTextField.text length] <= 1 && [string isEqualToString:@""])
            self.userIdRightView.hidden = YES;
    }
    if (textField == self.passwordTextField) {
        NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = updatedString;
        self.pswdRightView.hidden = NO;
        if ([self.passwordTextField.text length] <= 0 && [string isEqualToString:@""]) {
            self.pswdRightView.hidden = YES;
            self.passwordTextField.secureTextEntry = YES;
            [self.pswdRightView.rightViewBtn setSelected:NO];
        }
        return NO;
    }
    if (textField == self.passwordConfirmTextField) {
        NSString *updatedString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        textField.text = updatedString;
        self.confirmPswdRightView.hidden = NO;
        if ([self.passwordConfirmTextField.text length] <= 0 && [string isEqualToString:@""]) {
            self.confirmPswdRightView.hidden = YES;
            self.passwordConfirmTextField.secureTextEntry = YES;
            [self.confirmPswdRightView.rightViewBtn setSelected:NO];
        }
        return NO;
    }
    
    return YES;
}


#pragma mark getter and setter
- (UIImageView *)logoImageView {
    if (_logoImageView == nil) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _logoImageView.image = ImageWithName(@"login.bundle/login_logo");
    }
    return _logoImageView;
}

- (UIImageView *)titleImageView {
    if (_titleImageView == nil) {
        _titleImageView = [[UIImageView alloc] init];
        _titleImageView.contentMode = UIViewContentModeScaleAspectFill;
        _titleImageView.image = ImageWithName(@"login.bundle/login_agoraChat");
    }
    return _titleImageView;
}

- (UILabel *)titleRegisterMarkLabel
{
    if (_titleRegisterMarkLabel == nil) {
        _titleRegisterMarkLabel = [[UILabel alloc]init];
        _titleRegisterMarkLabel.backgroundColor = [UIColor whiteColor];
        _titleRegisterMarkLabel.font = [UIFont fontWithName:@"SFCompact-Medium" size:24];
        _titleRegisterMarkLabel.text = @"Register";
        _titleRegisterMarkLabel.textColor = COLOR_HEX(0x666666);
        _titleRegisterMarkLabel.hidden = YES;
        _titleRegisterMarkLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    return _titleRegisterMarkLabel;
}

- (UIView *)hintView
{
    if (!_hintView) {
        _hintView = [[UIView alloc]init];
        
        [_hintView addSubview:self.hintTitleLabel];
        [self.hintTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_hintView);
            make.centerX.equalTo(_hintView.mas_centerX).offset(11);
            make.height.equalTo(@20);
        }];
        
        UIImageView *failImg = [[UIImageView alloc]initWithImage:ImageWithName(@"login.bundle/loginFail")];
        [_hintView addSubview:failImg];
        [failImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@18);
            make.centerY.equalTo(_hintView);
            make.right.equalTo(self.hintTitleLabel.mas_left).offset(-4);
        }];
    }
    return  _hintView;
}

- (UILabel *)hintTitleLabel
{
    if (!_hintTitleLabel) {
        _hintTitleLabel = [[UILabel alloc]init];
        _hintTitleLabel.textColor = [UIColor blackColor];
        _hintTitleLabel.font = [UIFont fontWithName:@"PingFang SC" size:14.0];
    }
    return _hintTitleLabel;
}

- (UITextField *)usernameTextField {
    if (_usernameTextField == nil) {
        _usernameTextField = [[UITextField alloc] init];
        _usernameTextField.backgroundColor = COLOR_HEX(0xF2F2F2);
        _usernameTextField.delegate = self;
        _usernameTextField.borderStyle = UITextBorderStyleNone;
        _usernameTextField.attributedPlaceholder = [self textFieldAttributeString:@"AgoraID"];
        
        _usernameTextField.returnKeyType = UIReturnKeyDone;
        _usernameTextField.font = [UIFont fontWithName:@"PingFang SC" size:14.0];
        _usernameTextField.textColor = COLOR_HEX(0x000000);
        _usernameTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
        _usernameTextField.leftViewMode = UITextFieldViewModeAlways;
        _usernameTextField.layer.cornerRadius = kLoginButtonHeight * 0.5;
        
        _usernameTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        _usernameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _userIdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMUsernameRightView];
        [_userIdRightView.rightViewBtn addTarget:self action:@selector(clearUserIdAction) forControlEvents:UIControlEventTouchUpInside];
        _userIdRightView.hidden = YES;
        _usernameTextField.rightView = _userIdRightView;
        
    }
    return _usernameTextField;
}

- (UITextField *)passwordTextField {
    if (_passwordTextField == nil) {
        _passwordTextField = [[UITextField alloc] init];
        _passwordTextField.backgroundColor = COLOR_HEX(0xF2F2F2);
        _passwordTextField.delegate = self;
        _passwordTextField.borderStyle = UITextBorderStyleNone;

        _passwordTextField.font = [UIFont fontWithName:@"PingFang SC" size:14.0];
        _passwordTextField.textColor = COLOR_HEX(0x000000);
        _passwordTextField.attributedPlaceholder = [self textFieldAttributeString:@"Password"];

        _passwordTextField.secureTextEntry = YES;
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.clearsOnBeginEditing = NO;
        _passwordTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
        _passwordTextField.leftViewMode = UITextFieldViewModeAlways;
        _passwordTextField.layer.cornerRadius = kLoginButtonHeight * 0.5;
        
        _passwordTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        _passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.pswdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMPswdRightView];
        [self.pswdRightView.rightViewBtn addTarget:self action:@selector(pswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
        self.pswdRightView.hidden = YES;
        _passwordTextField.rightView = self.pswdRightView;
    }
    return _passwordTextField;
}

- (UITextField *)passwordConfirmTextField
{
    if (_passwordConfirmTextField == nil) {
        _passwordConfirmTextField = [[UITextField alloc] init];
        _passwordConfirmTextField.backgroundColor = COLOR_HEX(0xF2F2F2);
        _passwordConfirmTextField.delegate = self;
        _passwordConfirmTextField.borderStyle = UITextBorderStyleNone;

        _passwordConfirmTextField.font = [UIFont fontWithName:@"PingFang SC" size:14.0];
        _passwordConfirmTextField.textColor = COLOR_HEX(0x000000);
        _passwordConfirmTextField.attributedPlaceholder = [self textFieldAttributeString:@"Confirm Password"];

        _passwordConfirmTextField.secureTextEntry = YES;
        _passwordConfirmTextField.returnKeyType = UIReturnKeyDone;
        _passwordConfirmTextField.clearsOnBeginEditing = NO;
        _passwordConfirmTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 10)];
        _passwordConfirmTextField.leftViewMode = UITextFieldViewModeAlways;
        _passwordConfirmTextField.layer.cornerRadius = kLoginButtonHeight * 0.5;
        
        _passwordConfirmTextField.rightViewMode = UITextFieldViewModeWhileEditing;
        _passwordConfirmTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.confirmPswdRightView = [[EMRightViewToolView alloc]initRightViewWithViewType:EMPswdRightView];
        [self.confirmPswdRightView.rightViewBtn addTarget:self action:@selector(confirmPswdSecureAction:) forControlEvents:UIControlEventTouchUpInside];
        self.confirmPswdRightView.hidden = YES;
        _passwordConfirmTextField.rightView = self.confirmPswdRightView;
    }
    return _passwordConfirmTextField;
}


- (UIButton *)loginButton {
    if (_loginButton == nil) {
        _loginButton = [[UIButton alloc] init];
        _loginButton.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:16.0];
        _loginButton.titleLabel.textColor = COLOR_HEX(0x000000);
        [_loginButton setTitle:@"Log In" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.backgroundColor = COLOR_HEX(0x114EFF);
        [_loginButton addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
        _loginButton.layer.cornerRadius = kLoginButtonHeight * 0.5;
        
        [_loginButton addSubview:self.loadingImageView];
        
        [self.loadingImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_loginButton);
        }];
        
    }
    return _loginButton;
}


- (UIImageView *)loadingImageView {
    if (_loadingImageView == nil) {
        _loadingImageView = [[UIImageView alloc] init];
        _loadingImageView.contentMode = UIViewContentModeScaleAspectFill;
        _loadingImageView.image = ImageWithName(@"login.bundle/loading");
        _loadingImageView.hidden = YES;
    }
    return _loadingImageView;
}

- (UIButton *)operateTypeButton
{
    if (_operateTypeButton == nil) {
        _operateTypeButton = [[UIButton alloc] init];
        _operateTypeButton.titleLabel.font = [UIFont fontWithName:@"SFCompact-Medium" size:16.0];
        [_operateTypeButton setAttributedTitle:[self attributeText:@"No account? Register" key:@"Register"] forState:UIControlStateNormal];
        _operateTypeButton.backgroundColor = [UIColor whiteColor];
        [_operateTypeButton addTarget:self action:@selector(changeOperate:) forControlEvents:UIControlEventTouchUpInside];
        _operateTypeButton.layer.cornerRadius = kLoginButtonHeight * 0.5;
        _operateTypeButton.tag = 0;
    }
    return _operateTypeButton;
}

- (NSAttributedString *)attributeText:(NSString *)message key:(NSString *)keyInfo {
    NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc]initWithString:message];
    
    [attribute addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium],NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#999999"]} range:NSMakeRange(0, message.length)];
    
    if (keyInfo && keyInfo.length > 0) {
        [attribute addAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16 weight:UIFontWeightMedium],NSForegroundColorAttributeName:COLOR_HEX(0x114EFF)} range:[message rangeOfString:keyInfo]];
    }
    
    return attribute;
}

@end
#undef loginButtonHeight
#undef kMaxLimitLength

