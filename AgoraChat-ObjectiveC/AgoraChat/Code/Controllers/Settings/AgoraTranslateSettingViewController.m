//
//  AgoraTranslateSettingViewController.m
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2023/6/9.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "AgoraTranslateSettingViewController.h"
#import "ACDTitleDetailCell.h"
#import "ACDTitleSwitchCell.h"
#import "TranslateLanguageTableViewController.h"

@interface AgoraTranslateSettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AgoraTranslateSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.leftBarButtonItem = [ACDUtil customLeftButtonItem:NSLocalizedString(@"translate.setting", nil) action:@selector(back) actionTarget:self];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)back {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ACDCustomCell*cell = nil;
    if (indexPath.section == 0) {
        cell = [[ACDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell = [[ACDTitleSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[ACDTitleSwitchCell reuseIdentifier]];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    WEAK_SELF
    if (indexPath.section == 0) {
        cell.nameLabel.text = NSLocalizedString(@"demandLanguages", nil);
        NSString* code = ACDDemoOptions.sharedOptions.demandLanguage.languageNativeName;
        if (code.length == 0)
            code = @"No set";
        ((ACDTitleDetailCell*)cell).detailLabel.text = code;
        cell.tapCellBlock = ^{
            [weakSelf pushDemandLanguageSettingVC];
        };
    }
    else if (indexPath.section == 1) {
        cell.nameLabel.text = @"On-demand translation";
        [((ACDTitleSwitchCell*)cell).aSwitch setOn:ACDDemoOptions.sharedOptions.enableTranslate animated:NO];
        ((ACDTitleSwitchCell*)cell).switchActionBlock  = ^(BOOL isOn) {
            ACDDemoOptions.sharedOptions.enableTranslate = isOn;
            [ACDDemoOptions.sharedOptions archive];
        };
    }
//    else if (indexPath.row == 1) {
//        cell.nameLabel.text = NSLocalizedString(@"pushLanguageSetting", nil);
//        cell.detailLabel.text = ACDDemoOptions.sharedOptions.pushLanguage.languageNativeName;
//        cell.tapCellBlock = ^{
//            [weakSelf pushNotificationLanguageSettingVC];
//        };
//    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1)
        return @"Translation switch";
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(ACDDemoOptions.sharedOptions.demandLanguage.languageCode.length > 0)
        return 2;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)pushDemandLanguageSettingVC
{
    TranslateLanguageTableViewController* demandTLVC = [[TranslateLanguageTableViewController alloc] initWithNibName:@"TranslateLanguageTableViewController" bundle:nil];
    demandTLVC.pushSetting = NO;
    [self.navigationController pushViewController:demandTLVC animated:YES];
}

- (void)pushNotificationLanguageSettingVC
{
    TranslateLanguageTableViewController* pushTLVC = [[TranslateLanguageTableViewController alloc] initWithNibName:@"TranslateLanguageTableViewController" bundle:nil];
    pushTLVC.pushSetting = YES;
    [self.navigationController pushViewController:pushTLVC animated:YES];
}

@end
