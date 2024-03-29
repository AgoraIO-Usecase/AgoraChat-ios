//
//  AutoTranslateLanguageTableViewController.m
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2023/6/14.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "AutoTranslateLanguageTableViewController.h"
#import "ACDTitleDetailCell.h"

@interface AutoTranslateLanguageTableViewController ()
@property (nonatomic,strong) NSArray <AgoraChatTranslateLanguage *> *languages;
@property (nonatomic) NSInteger selectedItem;
@end

@implementation AutoTranslateLanguageTableViewController

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
            AgoraChatTranslateLanguage* currentLanguage = [ACDDemoOptions.sharedOptions.autoLanguages objectForKey:weakSelf.conversationId];
            if (currentLanguage) {
                for (AgoraChatTranslateLanguage* language in weakSelf.languages) {
                    if ([language.languageCode isEqualToString:currentLanguage.languageCode]) {
                        weakSelf.selectedItem = index;
                        break;
                    }
                    index++;
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        
    }];
    self.title = NSLocalizedString(@"autoLanguageSetting", nil);
    // add done button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonAction:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithHexString:@"154dfe"];
    [self.tableView registerClass:[ACDTitleDetailCell class] forCellReuseIdentifier:[ACDTitleDetailCell reuseIdentifier]];
}

- (void)doneButtonAction:(UIButton*)button
{
    
    NSMutableDictionary* dic =  [ACDDemoOptions.sharedOptions.autoLanguages mutableCopy];
    if (self.selectedItem != -1) {
        AgoraChatTranslateLanguage* language = [self.languages objectAtIndex:self.selectedItem];
        if (language)
            [dic setObject:language forKey:self.conversationId];
    } else {
        [dic removeObjectForKey:self.conversationId];
    }
    ACDDemoOptions.sharedOptions.autoLanguages = dic;
    [ACDDemoOptions.sharedOptions archive];
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.languages[indexPath.row].languageNativeName;
    if (self.selectedItem == indexPath.row ) {
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

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
