//
//  ACDGroupMemberNickNameViewController.m
//  EaseIM
//
//  Created by 朱继超 on 2023/1/17.
//  Copyright © 2023 朱继超. All rights reserved.
//

#import "ACDGroupMemberNickNameViewController.h"
#import "ACDGroupMemberAttributesCache.h"
#import "NSDictionary+Safely.h"

@interface ACDGroupMemberNickNameViewController ()<UITextFieldDelegate>

@property (nonatomic,strong) NSString *groupId;

@property (nonatomic,strong) UITextField *nickNameField;

@property (nonatomic) UILabel *countLabel;

@end

@implementation ACDGroupMemberNickNameViewController
#define MAX_GROUPNICKNAME_LENGTH 50
- (instancetype)initWithGroupId:(nonnull NSString *)groupId nickName:(nullable NSString *)name{
    if ([self init]) {
        self.groupId = groupId;
        self.nickName = name;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [ACDUtil customLeftButtonItem:@"My Alias in Group" action:@selector(goBack) actionTarget:self];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(saveAction)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:@"154dfe"];
    [self.view addSubview:[self nickNameField]];
    [self.view addSubview:[self countLabel]];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (UITextField *)nickNameField {
    if (!_nickNameField) {
        _nickNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) - 60, 50)];
        _nickNameField.placeholder = self.nickName ? self.nickName:NSLocalizedString(@"Please input your nick name in group",nil);
        _nickNameField.text = _nickNameField.placeholder;
        _nickNameField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 50)];
        _nickNameField.leftViewMode = UITextFieldViewModeAlways;
        _nickNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nickNameField.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
        [_nickNameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        _nickNameField.delegate = self;
    }
    return _nickNameField;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 60, 0, 60, 50)];
        _countLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1];
        _countLabel.text = [NSString stringWithFormat:@"%ld/%d",self.nickName.length,MAX_GROUPNICKNAME_LENGTH];
        _countLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightRegular];
        _countLabel.numberOfLines = 0;
    }
    return _countLabel;
}

- (void)saveAction {
    [self.view endEditing:YES];
    if ([self.nickNameField.text isEqualToString:@""] || self.nickNameField.text == nil) {
        self.nickNameField.text = @"";
    }
    [AgoraChatClient.sharedClient.groupManager setMemberAttribute:self.groupId userId:AgoraChatClient.sharedClient.currentUsername attributes:@{GROUP_NICKNAME_KEY:self.nickNameField.text} completion:^(AgoraChatError * _Nullable error) {
        if (error == nil) {
            [self showHint:NSLocalizedString(@"Saved", nil)];
            [[ACDGroupMemberAttributesCache shareInstance] updateCacheWithGroupId:self.groupId userName:AgoraChatClient.sharedClient.currentUsername key:GROUP_NICKNAME_KEY value:self.nickNameField.text];
            if (self.changeResult) {
                self.changeResult(self.nickNameField.text);
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self showHint:error.errorDescription];
        }
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSString *toBeString = textField.text;

    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];

    if (!position){
        if (toBeString.length > MAX_GROUPNICKNAME_LENGTH){
         NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_GROUPNICKNAME_LENGTH)];
         textField.text = [toBeString substringWithRange:rangeRange];
        }
    }
    if (textField.text.length <= MAX_GROUPNICKNAME_LENGTH)
        self.countLabel.text = [NSString stringWithFormat:@"%ld/%d",textField.text.length,MAX_GROUPNICKNAME_LENGTH];
}

@end
