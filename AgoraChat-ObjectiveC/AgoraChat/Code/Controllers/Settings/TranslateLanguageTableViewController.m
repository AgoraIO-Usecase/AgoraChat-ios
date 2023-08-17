//
//  TranslateLanguageTableViewController.m
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2023/6/14.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "TranslateLanguageTableViewController.h"
#import "ACDTitleDetailCell.h"

@interface TranslateLanguageTableViewController ()
@property (nonatomic,strong) NSArray <AgoraChatTranslateLanguage *> *languages;
@property (nonatomic) NSInteger selectedItem;
@end

@implementation TranslateLanguageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.selectedItem = -1;
    WEAK_SELF
    [AgoraChatClient.sharedClient.chatManager fetchSupportedLanguages:^(NSArray<AgoraChatTranslateLanguage *> * _Nullable languages, AgoraChatError * _Nullable error) {
        if (!error) {
            weakSelf.languages = languages;
            NSInteger index = 0;
            NSString* strSelectedLanguage = weakSelf.pushSetting ? ACDDemoOptions.sharedOptions.pushLanguage.languageCode : ACDDemoOptions.sharedOptions.demandLanguage.languageCode;
            for (AgoraChatTranslateLanguage* language in weakSelf.languages) {
                if ([strSelectedLanguage isEqualToString:language.languageCode]) {
                    weakSelf.selectedItem = index;
                    break;
                }
                index++;
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
    self.title = self.pushSetting ? NSLocalizedString(@"pushLanguages", nil) : NSLocalizedString(@"demandLanguages", nil);
    // add done button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    [self.tableView registerClass:[ACDTitleDetailCell class] forCellReuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];
}

- (void)doneButtonAction:(UIButton*)button
{
    if (self.selectedItem != -1) {
        if (self.pushSetting)
        {
            ACDDemoOptions.sharedOptions.pushLanguage = self.languages[self.selectedItem];
            [AgoraChatClient.sharedClient.pushManager setPreferredNotificationLanguage:self.languages[self.selectedItem].languageCode completion:^(AgoraChatError * _Nullable aError) {
                            
            }];
        }else
            ACDDemoOptions.sharedOptions.demandLanguage = self.languages[self.selectedItem];
        [ACDDemoOptions.sharedOptions archive];
    } else {
        if (self.pushSetting)
        {
            ACDDemoOptions.sharedOptions.pushLanguage = nil;
            [AgoraChatClient.sharedClient.pushManager setPreferredNotificationLanguage:@"" completion:^(AgoraChatError * _Nullable aError) {
                            
            }];
        }else
            ACDDemoOptions.sharedOptions.demandLanguage = nil;
        [ACDDemoOptions.sharedOptions archive];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.languages)
        return 0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.languages)
        return 0;
    return self.languages.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDTitleDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ACDTitleDetailCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[ACDTitleDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ACDTitleDetailCell"];
    }
    cell.textLabel.text = self.languages[indexPath.row].languageNativeName;
    if (indexPath.row == self.selectedItem) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.tapCellBlock = ^{
        if (indexPath.row != self.selectedItem) {
            if (self.selectedItem != -1) {
                NSIndexPath* preSelectedIndex = [NSIndexPath indexPathForRow:self.selectedItem inSection:0];
                UITableViewCell* preSelectedCell = [tableView cellForRowAtIndexPath:preSelectedIndex];
                preSelectedCell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            UITableViewCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.selectedItem = indexPath.row;
        } else {
            UITableViewCell* selectedCell = [tableView cellForRowAtIndexPath:indexPath];
            selectedCell.accessoryType = UITableViewCellAccessoryNone;
            self.selectedItem = -1;
        }
    };
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
