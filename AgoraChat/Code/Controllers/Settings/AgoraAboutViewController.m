/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import "AgoraAboutViewController.h"
#import "ACDTitleDetailCell.h"
#import <UIKit/UIKit.h>
#import "ACDWebViewController.h"

@interface AgoraAboutViewController ()

@end

@implementation AgoraAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"";
    [self setNavBar];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = UIColor.whiteColor;
}

- (void)setNavBar {
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 8, 15)];
    [backButton setImage:[UIImage imageNamed:@"black_goBack"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    [backButton setTitle:@"About" forState:UIControlStateNormal];
    [backButton setTitleColor:TextLabelBlackColor forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDTitleDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:[ACDTitleDetailCell reuseIdentifier]];
    if (!cell) {
        cell = [[ACDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];
    }
    if (indexPath.row == 0) {
        
        cell.nameLabel.attributedText = [self titleAttribute:@"UI Library Version"];
        NSString *ver = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        NSString *detailContent = [NSString stringWithFormat:@"AgoraChat v:%@",ver];
        cell.detailLabel.attributedText = [self detailAttribute:detailContent];
        
    } else if (indexPath.row == 1) {
        
        cell.nameLabel.attributedText = [self titleAttribute:@"SDK Version"];
        NSString *detailContent = [NSString stringWithFormat:@"AgoraChat v:%@",[[AgoraChatClient sharedClient] version]];
        cell.detailLabel.attributedText = [self detailAttribute:detailContent];
    }else if (indexPath.row == 2) {
        
        cell.nameLabel.attributedText = [self titleAttribute:@"More"];
        
        NSAttributedString *attributeString = [ACDUtil attributeContent:@"Agora.io" color:TextLabelBlueColor font:Font(@"PingFang SC",16.0)];
        cell.detailLabel.attributedText = attributeString;
        ACD_WS
        cell.tapCellBlock = ^{
            [weakSelf goAgoraOffical];
        };
    }
    
    return cell;
}


- (void)goAgoraOffical {
    NSString *urlString = @"https://www.agora.io/en";
    ACDWebViewController *webVC = [[ACDWebViewController alloc] initWithURLString:urlString];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (NSAttributedString *)titleAttribute:(NSString *)title {
    return [ACDUtil attributeContent:title color:TextLabelBlack2Color font:Font(@"PingFang SC",16.0)];
}

- (NSAttributedString *)detailAttribute:(NSString *)detail {
    return [ACDUtil attributeContent:detail color:TextLabelGrayColor font:Font(@"PingFang SC",16.0)];
}

 
@end
