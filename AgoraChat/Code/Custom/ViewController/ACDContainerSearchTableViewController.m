//
//  ACDContainerSearchTableViewController.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/29.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDContainerSearchTableViewController.h"
#import "MISScrollPage.h"

@interface ACDContainerSearchTableViewController ()<MISScrollPageControllerContentSubViewControllerDelegate>

@end

@implementation ACDContainerSearchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


#pragma mark - MISScrollPageControllerContentSubViewControllerDelegate
- (BOOL)hasAlreadyLoaded{
    return NO;
}

- (void)viewDidLoadedForIndex:(NSUInteger)index{
    
}

- (void)viewWillAppearForIndex:(NSUInteger)index{
    [self cancelSearchState];

}

- (void)viewDidAppearForIndex:(NSUInteger)index{
}

- (void)viewWillDisappearForIndex:(NSUInteger)index{
    self.editing = NO;
    [self cancelSearchState];
}

- (void)viewDidDisappearForIndex:(NSUInteger)index{
    
}


@end
