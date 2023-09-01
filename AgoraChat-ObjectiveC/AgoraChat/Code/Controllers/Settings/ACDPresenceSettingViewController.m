//
//  ACDPresenceSettingViewController.m
//  AgoraChat
//
//  Created by lixiaoming on 2022/2/27.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDPresenceSettingViewController.h"
#import "PresenceManager.h"

@interface ACDPresenceSettingViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (nonatomic,strong) UITableView* tableView;
@property (nonatomic,strong) NSMutableArray* dataArray;
@property (nonatomic,strong) NSString* currentPresence;
@end

@implementation ACDPresenceSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadData];
    
    [self _setupSubviews];
}

- (void)loadData
{
    self.dataArray = [@[kPresenceOnlineDescription,kPresenceBusyDescription,kPresenceDNDDescription,kPresenceLeaveDescription,@"Custom Status"] mutableCopy];
    AgoraChatPresence* minePresence = [[[PresenceManager sharedInstance] presences] objectForKey:[AgoraChatClient sharedClient].currentUsername];
    self.currentPresence = minePresence.statusDescription;
    if(self.currentPresence.length == 0)
        self.currentPresence = @"Online";
    if(![self.dataArray containsObject:self.currentPresence]) {
        self.dataArray[self.dataArray.count-1] = self.currentPresence;
    }
}

- (void)_setupSubviews
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"done" style:UIBarButtonItemStylePlain target:self action:@selector(completeAction)];
    self.title = @"Presence Setting";
    self.view.backgroundColor = [UIColor colorWithRed:249/255.0 green:249/255.0 blue:249/255.0 alpha:1.0];

    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (NSArray<NSString*>*)imageNames
{
    return @[kPresenceOnlineDescription,kPresenceBusyDescription,kPresenceDNDDescription,kPresenceLeaveDescription,@"custom"];
}

- (void)completeAction
{
    AgoraChatPresence* presence = [[[PresenceManager sharedInstance] presences] objectForKey:[AgoraChatClient sharedClient].currentUsername];
    if(presence.statusDescription.length > 0 && ![presence.statusDescription isEqualToString:kPresenceBusyDescription] && ![presence.statusDescription isEqualToString:kPresenceDNDDescription] && ![presence.statusDescription isEqualToString:kPresenceLeaveDescription]) {
        NSString* message = [NSString stringWithFormat:@"Clear your '%@',change to %@",presence.statusDescription,self.currentPresence];
        if(self.currentPresence.length == 0) {
            message = [message stringByAppendingString:kPresenceOnlineDescription];
        }
        UIAlertController* tipControler = [UIAlertController alertControllerWithTitle:@"Clear your Custom Status" message:message preferredStyle:UIAlertControllerStyleAlert];
        [tipControler addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.navigationController popViewControllerAnimated:NO];
        }]];
        [tipControler addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [[PresenceManager sharedInstance] publishPresenceWithDescription:self.currentPresence completion:nil];
            [self.navigationController popViewControllerAnimated:NO];
        }]];
        [self presentViewController:tipControler animated:YES completion:nil];
    }else{
        [[PresenceManager sharedInstance] publishPresenceWithDescription:self.currentPresence completion:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }
    
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.dataArray.count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableView*)tableView
{
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PresenceCell"];
    
    
    // Configure the cell...
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PresenceCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString* status = [self.dataArray objectAtIndex:indexPath.row];
    if([self.dataArray indexOfObject:self.currentPresence] == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else
        cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = status;
    cell.imageView.image = [UIImage imageNamed:[[self imageNames] objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 4) {
        [self _updateCustomStatus];
    }
    self.currentPresence = [self.dataArray objectAtIndex:indexPath.row];
    [self.tableView reloadData];
//    UITableViewCell* language = [self.allLanguages objectAtIndex:indexPath.row];
//    NSString* selectedLanguage = language.languageCode;
//    if(![selectedLanguage isEqualToString:self.selectLanguage]) {
//        self.selectLanguage = selectedLanguage;
//        [self.tableView reloadData];
//    }
}

- (void)_updateCustomStatus
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Custom Status" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Custom Status";
        UILabel* rightLabel = [[UILabel alloc] init];
        rightLabel.font = [UIFont systemFontOfSize:10];
        rightLabel.textColor = [UIColor grayColor];
        rightLabel.text = @"0/10";
        textField.rightView = rightLabel;
        textField.rightViewMode = UITextFieldViewModeAlways;
        textField.delegate = self;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];

    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UITextField *textField = alertController.textFields.firstObject;
        self.dataArray[4] = textField.text;
        self.currentPresence = textField.text;
        [self.tableView reloadData];
        //[[PresenceManager sharedInstance] publishPresenceWithDescription:textField.text completion:nil];
    }];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if(str.length > 10)
        return NO;
    UILabel* rightLabel = (UILabel*)textField.rightView;
    if ([rightLabel isKindOfClass:[UILabel class]]) {
        rightLabel.text = [NSString stringWithFormat:@"%ld/10",str.length];
    }
    return YES;
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
