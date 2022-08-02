//
//  ACDReportMessageSucceedViewController.m
//  AgoraChat
//
//  Created by 杜洁鹏 on 2022/7/14.
//  Copyright © 2022 easemob. All rights reserved.
//

#import "ACDReportMessageSucceedViewController.h"

@interface ACDReportMessageSucceedViewController ()

@end

@implementation ACDReportMessageSucceedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.doneButton.layer.cornerRadius = self.doneButton.frame.size.height / 2;
    self.doneButton.clipsToBounds = YES;
}
- (IBAction)doneAction:(id)sender {
    if (self.doneButtonBlock) {
        self.doneButtonBlock();
    }
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
