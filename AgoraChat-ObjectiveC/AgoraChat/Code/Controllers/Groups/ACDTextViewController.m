//
//  EMTextViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/17.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import "ACDTextViewController.h"

#import "ACDTextView.h"

@interface ACDTextViewController ()<UITextViewDelegate>

@property (nonatomic, strong) NSString *originalString;
@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic) BOOL isEditable;

@property (nonatomic, strong) ACDTextView *textView;

@end

@implementation ACDTextViewController

- (instancetype)initWithString:(NSString *)aString
                   placeholder:(NSString *)aPlaceholder
                    isEditable:(BOOL)aIsEditable
{
    self = [super init];
    if (self) {
        _originalString = aString;
        _placeholder = aPlaceholder;
        _isEditable = aIsEditable;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.navTitle;
    
    [self _setupSubviews];
}

#pragma mark - Subviews

- (void)_setupSubviews
{

    self.navigationItem.leftBarButtonItem = [ACDUtil customBarButtonItem:@"Cancel" action:@selector(goBack) actionTarget:self];
    
    if (self.isEditable) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"common.done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
        self.navigationItem.rightBarButtonItem.tintColor = ButtonEnableBlueColor;
    }
    
    self.view.backgroundColor = UIColor.whiteColor;
    UIView *bgView = [[UIView alloc] init];
    bgView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.textView = [[ACDTextView alloc] init];
    self.textView.delegate = self;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.font = [UIFont systemFontOfSize:16];
    if (!self.isEditable)
        self.textView.placeholder = NSLocalizedString(@"editRight", nil);
    else
        self.textView.placeholder = self.placeholder;
    self.textView.returnKeyType = UIReturnKeyDone;
    if (self.originalString && ![self.originalString isEqualToString:@""]) {
        self.textView.text = self.originalString;
    }
    self.textView.editable = self.isEditable;
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(bgView);
        make.top.equalTo(bgView).offset(5);
        make.left.equalTo(bgView).offset(10);
    }];
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Action

- (void)doneAction
{
    [self.view endEditing:YES];
    
    BOOL isPop = YES;
    if (_doneCompletion) {
        isPop = _doneCompletion(self.textView.text);
    }
    
    if (isPop) {
        [self goBack];
    }
}

@end
