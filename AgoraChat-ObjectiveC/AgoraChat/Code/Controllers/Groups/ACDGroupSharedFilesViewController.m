//
//  AgoraChatGroupSharedFilesViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 2019/1/18.
//  Copyright © 2019 XieYajie. All rights reserved.
//

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "ACDGroupSharedFilesViewController.h"
#import "ACDAvatarNameCell.h"
#import "ACDDateHelper.h"
#import "ACDGroupMemberNavView.h"
#import "ACDGroupShareFileModel.h"


@interface ACDGroupSharedFilesViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, AgoraChatGroupManagerDelegate, UIDocumentPickerDelegate,UIDocumentInteractionControllerDelegate>

@property (nonatomic, strong) AgoraChatGroup *group;

@property (nonatomic, strong) UIImagePickerController *imagePicker;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic, assign) NSInteger page;

@property (nonatomic,strong) ACDGroupMemberNavView *navView;

@property (nonatomic, strong) ACDNoDataPlaceHolderView *noDataPromptView;

@end

@implementation ACDGroupSharedFilesViewController

- (instancetype)initWithGroup:(AgoraChatGroup *)aGroup
{
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
        self.group = aGroup;
        [[AgoraChatClient sharedClient].groupManager addDelegate:self delegateQueue:nil];

    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"sharedFile", nil);
        
    self.page = 1;
    [self _fetchFilesWithPage:self.page isHeader:YES isShowHUD:YES];
    
}

- (void)placeSubViews {
    UIView *container = UIView.new;
    container.backgroundColor = UIColor.whiteColor;
    container.clipsToBounds = YES;
    
    [self.view addSubview:self.navView];
    [self.view addSubview:container];
    [self.view addSubview:self.searchBar];
    [container addSubview:self.table];
    [container addSubview:self.noDataPromptView];

    CGFloat bottom = 0;
    if (@available(iOS 11, *)) {
        bottom =  UIApplication.sharedApplication.windows.firstObject.safeAreaInsets.bottom;
    }
    
    [self.navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.right.equalTo(self.view);
    }];
    
    [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(container);
        make.left.and.right.equalTo(container);
        make.height.mas_equalTo(kSearchBarHeight);
    }];
    
    [self.table mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container).insets(UIEdgeInsetsMake(kSearchBarHeight, 0, 0,   0));
    }];

    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navView.mas_bottom).offset(5);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
        
    [self.noDataPromptView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.left.right.equalTo(container);
    }];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)dealloc
{
    [[AgoraChatClient sharedClient].groupManager removeDelegate:self];
}

#pragma mark private method
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.isSearchState) {
        return [self.searchResults count];
    }
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ACDAvatarNameCell *cell = (ACDAvatarNameCell *)[tableView dequeueReusableCellWithIdentifier:@"ACDAvatarNameCell"];
    if (cell == nil) {
        cell = [[ACDAvatarNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ACDAvatarNameCell"];
        
        cell.avatarView.contentMode = UIViewContentModeScaleAspectFit;
        [cell.avatarView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(cell.contentView).offset(5);
            make.left.equalTo(cell.contentView).offset(15);
            make.bottom.equalTo(cell.contentView).offset(-5);
            make.width.equalTo(cell.avatarView.mas_height).multipliedBy(0.6);
        }];
    }
    
    AgoraChatGroupSharedFile *file = nil;
    ACDGroupShareFileModel *fileModel = nil;
    if (self.isSearchState) {
        fileModel = self.searchResults[indexPath.row];
        file = fileModel.file;
    }else {
        fileModel = [self.dataArray objectAtIndex:indexPath.row];
        file = fileModel.file;
    }
    
    cell.avatarView.image = [self fileIconWithFileName:file.fileName];
    if (file.fileName.length > 0) {
        cell.nameLabel.text = file.fileName;
    } else {
        cell.nameLabel.text = file.fileId;
    }
    
    NSString *fileCreateTime = [_dateFormatter stringFromDate:[ACDDateHelper dateWithTimeIntervalInMilliSecondSince1970:file.createTime]];
    NSString *fileOwner = [file.fileOwner length] <= 10 ? file.fileOwner : [NSString stringWithFormat:@"%@...",[file.fileOwner substringWithRange:NSMakeRange(0, 10)]];
    cell.detailLabel.text = [NSString stringWithFormat:NSLocalizedString(@"fromPrompt", nil),fileCreateTime,fileOwner,(float)file.fileSize / (1024 * 1024)];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //在iOS8.0上，必须加上这个方法才能出发左划操作
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self _deleteFileCellAction:indexPath];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *filePath = NSHomeDirectory();
    filePath = [NSString stringWithFormat:@"%@/Library/appdata/download", filePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:filePath]) {
        [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    AgoraChatGroupSharedFile *file = nil;
    ACDGroupShareFileModel *fileModel = nil;
    if (self.isSearchState) {
        fileModel = self.searchResults[indexPath.row];
        file = fileModel.file;
    }else {
        fileModel = [self.dataArray objectAtIndex:indexPath.row];
        file = fileModel.file;
    }
    
    NSString *fileName = file.fileName.length > 0 ? file.fileName : file.fileId;
    filePath = [NSString stringWithFormat:@"%@/%@", filePath, fileName];
    
    if ([fm fileExistsAtPath:filePath]) {
        [self _openFileWithPath:filePath];
    } else {
        __weak typeof(self) weakSelf = self;
        [self showHudInView:self.view hint:NSLocalizedString(@"downloadingShareFile...", nil)];
        [[AgoraChatClient sharedClient].groupManager downloadGroupSharedFileWithId:self.group.groupId filePath:filePath sharedFileId:file.fileId progress:^(int progress) {
            // NSLog(@"%d",progress);
        } completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
            [weakSelf hideHud];
            if (aError) {
                [weakSelf showHint:NSLocalizedString(@"downloadsharedFileFial", nil)];
            } else {
                [weakSelf _openFileWithPath:filePath];
            }
        }];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // we will convert it to mp4 format
        NSURL *mp4 = [self _videoConvert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self uploadAction:[mp4 path]];
    } else {
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            NSData *data = UIImageJPEGRepresentation(orgImage, 1);
            [self _uploadFileData:data fileName:nil];
        } else {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop) {
                    if (asset) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                            if (data != nil) {
                                NSURL *path = [dic objectForKey:@"PHImageFileURLKey"];
                                NSString *fileName = nil;
                                if (path) {
                                    fileName = [[path absoluteString] lastPathComponent];
                                }
                                [self _uploadFileData:data fileName:fileName];
                            }
                        }];
                    }
                }];
            } else {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                        Byte* buffer = (Byte*)malloc((size_t)[assetRepresentation size]);
                        NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:(NSUInteger)[assetRepresentation size] error:nil];
                        NSData* data = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        [self _uploadFileData:data fileName:nil];
                    }
                } failureBlock:nil];
            }
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AgoraChatGroupManagerDelegate

- (void)groupFileListDidUpdate:(AgoraChatGroup *)aGroup
               addedSharedFile:(AgoraChatGroupSharedFile *)aSharedFile
{
    if ([aGroup.groupId isEqualToString:self.group.groupId]) {
        [self _reloadDataArrayAndView];
    }
}

- (void)groupFileListDidUpdate:(AgoraChatGroup *)aGroup
             removedSharedFile:(NSString *)aFileId
{
    if ([aGroup.groupId isEqualToString:self.group.groupId]) {
        [self _reloadDataArrayAndView];
    }
}

#pragma mark - Private
- (UIImage *)fileIconWithFileName:(NSString *)fileName {
    NSString *fileIconName = @"";
    NSString *fileTypeString = [fileName componentsSeparatedByString:@"."].lastObject;
    if ([fileTypeString isEqualToString:@"jpg"]||
        [fileTypeString isEqualToString:@"mp4"]||
        [fileTypeString isEqualToString:@"docx"]||
        [fileTypeString isEqualToString:@"xlsx"]||
        [fileTypeString isEqualToString:@"pdf"]||
        [fileTypeString isEqualToString:@"zip"]||
        [fileTypeString isEqualToString:@"txt"]) {
        fileIconName = [NSString stringWithFormat:@"file_%@",fileTypeString];
    }else {
        fileIconName = @"file_unknow";
    }
    return ImageWithName(fileIconName);
}


- (void)_uploadFileData:(NSData *)aData
               fileName:(NSString *)aFileName
{
    NSString *filePath = NSHomeDirectory();
    filePath = [NSString stringWithFormat:@"%@/Library/appdata/files", filePath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:filePath]) {
        [fm createDirectoryAtPath:filePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([aFileName length] > 0) {
        filePath = [NSString stringWithFormat:@"%@/%d%@", filePath, (int)[[NSDate date] timeIntervalSince1970], aFileName];
    } else {
        filePath = [NSString stringWithFormat:@"%@/%d%d.jpg", filePath, (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
    }
    
    [aData writeToFile:filePath atomically:YES];
    
    [self uploadAction:filePath];
}

//开始上传
- (void)uploadAction:(NSString *)filePath
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSLocalizedString(@"uploadingShareFile...", nil)];
    [[AgoraChatClient sharedClient].groupManager uploadGroupSharedFileWithId:self.group.groupId filePath:filePath progress:^(int progress){
        //code
    } completion:^(AgoraChatGroupSharedFile *aSharedFile, AgoraChatError *aError) {
        [weakSelf hideHud];
        if (!aError) {
            ACDGroupShareFileModel *fileModel = [[ACDGroupShareFileModel alloc] initWithObject:aSharedFile];
            [weakSelf.dataArray insertObject:fileModel atIndex:0];
            [weakSelf updateUI];
        } else {
            [weakSelf showHint:NSLocalizedString(@"uploadsharedFileFail", nil)];
        }
    }];
}

- (void)_deleteFileCellAction:(NSIndexPath *)aIndexPath {
    
    ACDGroupShareFileModel *fileModel = [self.dataArray objectAtIndex:aIndexPath.row];
    AgoraChatGroupSharedFile *file = fileModel.file;

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Are you sure to delete" message:file.fileName preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {

    }];
    [alertController addAction:cancelAction];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style: UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self _deleteFile:file];
    }];
    [deleteAction setValue:TextLabelPinkColor forKey:@"titleTextColor"];

    [alertController addAction:deleteAction];
    
    alertController.modalPresentationStyle = 0;
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)_deleteFile:(AgoraChatGroupSharedFile *)file{
    
    ACD_WS
    [self showHudInView:self.view hint:NSLocalizedString(@"deleteShareFile...", nil)];
    [[AgoraChatClient sharedClient].groupManager removeGroupSharedFileWithId:self.group.groupId sharedFileId:file.fileId completion:^(AgoraChatGroup *aGroup, AgoraChatError *aError) {
        [weakSelf hideHud];
        if (!aError) {
            for (ACDGroupShareFileModel *fileModel in weakSelf.dataArray) {
                if ([fileModel.file.fileName isEqual:file.fileName]) {
                    [weakSelf.dataArray removeObject:fileModel];
                    break;
                }
            }
            [weakSelf updateUI];
        } else {
            [weakSelf showHint:NSLocalizedString(@"removesharedFileFail", nil)];
        }
    }];
}

- (void)_openFileWithPath:(NSString *)aPath
{
    NSURL *url = [NSURL fileURLWithPath:aPath];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[url] applicationActivities:nil];
    controller.excludedActivityTypes = @[UIActivityTypeMessage, UIActivityTypeMail, UIActivityTypeSaveToCameraRoll, UIActivityTypeAirDrop];
    [self presentViewController:controller animated:YES completion:nil];
}

- (NSURL *)_videoConvert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset presetName:AVAssetExportPresetHighestQuality];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [self _getAudioOrVideoPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        mp4Url = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

- (NSString *)_getAudioOrVideoPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
    path = [path stringByAppendingPathComponent:@"groupShareRecord"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

#pragma mark - Data
- (void)_reloadDataArrayAndView
{
    [self.dataArray removeAllObjects];
    for (AgoraChatGroupSharedFile *file in self.group.sharedFileList) {
        ACDGroupShareFileModel *model = [[ACDGroupShareFileModel alloc] initWithObject:file];
        if (model) {
            [self.dataArray addObject:model];
        }
    }
    [self updateUI];
}

- (void)_fetchFilesWithPage:(NSInteger)aPage
                   isHeader:(BOOL)aIsHeader
                  isShowHUD:(BOOL)aIsShowHUD
{
    NSInteger pageSize = 50;
    if (aIsShowHUD) {
        [self showHudInView:self.view hint:NSLocalizedString(@"fetchShareFile...", nil)];
    }
    
    __weak typeof(self) weakSelf = self;
    [[AgoraChatClient sharedClient].groupManager getGroupFileListWithId:self.group.groupId pageNumber:self.page pageSize:pageSize completion:^(NSArray *aList, AgoraChatError *aError) {
        [self endRefresh];

        if (aIsShowHUD) {
            [weakSelf hideHud];
        }
        
        if (!aError) {
            if (aIsHeader) {
                [weakSelf.dataArray removeAllObjects];
            }
            
            for (AgoraChatGroupSharedFile *file in aList) {
                ACDGroupShareFileModel *model = [[ACDGroupShareFileModel alloc] initWithObject:file];
                if (model) {
                    [weakSelf.dataArray addObject:model];
                }
            }

        } else {
            [weakSelf showHint:NSLocalizedString(@"fetchsharedFileFail", nil)];
        }
        
        if (aList.count < pageSize) {
            [self endLoadMore];
            [self loadMoreCompleted];
        } else {
            [self useLoadMore];
        }

        [self updateUI];

    }];
}

- (void)updateUI {
    self.searchSource = [NSMutableArray arrayWithArray:self.dataArray];
    [self.table reloadData];
    self.navView.leftSubLabel.text = [NSString stringWithFormat:@"(%@)",@(self.dataArray.count)];
    self.noDataPromptView.hidden = self.dataArray.count > 0 ? YES : NO;
}

#pragma mark refresh and load more
- (void)didStartRefresh {
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didStartLoadMore {
    [self tableViewDidTriggerFooterRefresh];
}


- (void)tableViewDidTriggerHeaderRefresh
{
    self.page = 1;
    [self _fetchFilesWithPage:self.page isHeader:YES isShowHUD:NO];
}

- (void)tableViewDidTriggerFooterRefresh
{
    self.page += 1;
    [self _fetchFilesWithPage:self.page isHeader:YES isShowHUD:NO];
}

#pragma mark - Action

- (void)moreAction {
   
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *changeAvatarAction = [UIAlertAction alertActionWithTitle:@"Upload Image" iconImage:ImageWithName(@"groupShareImage") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self uploadMediaAction:0];
    }];
    
    
    UIAlertAction *changeNicknameAction = [UIAlertAction alertActionWithTitle:@"Upload Video" iconImage:ImageWithName(@"groupShareVideo") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self uploadMediaAction:1];
    }];

    UIAlertAction *copyAction = [UIAlertAction alertActionWithTitle:@"Upload File" iconImage:ImageWithName(@"groupShareFile") textColor:TextLabelBlackColor alignment:NSTextAlignmentLeft completion:^{
        [self uploadFileAction];
    }];
   
    
    [alertController addAction:changeAvatarAction];
    [alertController addAction:changeNicknameAction];
    [alertController addAction:copyAction];

    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


//上传图片/视频
- (void)uploadMediaAction:(NSInteger)tag
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle = UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (tag == 0) {
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    } else {
        self.imagePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    }
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
}

//上传文件（icloud driver文件）
- (void)uploadFileAction
{
    NSArray *documentTypes = @[@"public.content", @"public.text", @"public.source-code", @"public.image", @"public.jpeg", @"public.png", @"com.adobe.pdf", @"com.apple.keynote.key", @"com.microsoft.word.doc", @"com.microsoft.excel.xls", @"com.microsoft.powerpoint.ppt"];
    UIDocumentPickerViewController *picker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeOpen];
    picker.delegate = self;
    picker.modalPresentationStyle = 0;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls
{
    BOOL fileAuthorized = [urls.firstObject startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        [self selectedDocumentAtURLs:urls[0] reName:nil];
        [urls.firstObject stopAccessingSecurityScopedResource];
    } else {
        [self showHint:NSLocalizedString(@"rightFail", nil)];
    }
}
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    BOOL fileAuthorized = [url startAccessingSecurityScopedResource];
    if (fileAuthorized) {
        [self selectedDocumentAtURLs:url reName:nil];
        [url stopAccessingSecurityScopedResource];
    } else {
        [self showHint:NSLocalizedString(@"rightFail", nil)];
    }
}

//icloud
- (void)selectedDocumentAtURLs:(NSURL *)url reName:(NSString *)rename
{
    NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc]init];
    NSError *error;
    [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL * _Nonnull newURL) {
        //读取文件
        NSString *fileName = [newURL lastPathComponent];
        NSError *error = nil;
        NSData *fileData = [NSData dataWithContentsOfURL:newURL options:NSDataReadingMappedIfSafe error:&error];
        if (error) {
            [self showHint:NSLocalizedString(@"readFileFail", nil)];;
        }else {
            NSLog(@"fileName: %@\nfileUrl: %@", fileName, newURL);
            [self _uploadFileData:fileData fileName:fileName];
        };
    }];
}

#pragma mark getter and setter
//- (NSMutableArray *)dataArray {
//    if (_dataArray == nil) {
//        _dataArray = NSMutableArray.new;
//    }
//    return _dataArray;
//}

- (ACDGroupMemberNavView *)navView {
    if (_navView == nil) {
        _navView = [[ACDGroupMemberNavView alloc] init];
        _navView.leftLabel.text = @"Group Files";

        ACD_WS
        _navView.leftButtonBlock = ^{
            [weakSelf backAction];
        };
        _navView.rightButtonBlock = ^{
            [weakSelf moreAction];
        };
        [_navView.rightButton setImage:ImageWithName(@"chat_nav_add") forState:UIControlStateNormal];

    }
    
    return _navView;
}

- (ACDNoDataPlaceHolderView *)noDataPromptView {
    if (_noDataPromptView == nil) {
        _noDataPromptView = ACDNoDataPlaceHolderView.new;
        [_noDataPromptView.noDataImageView setImage:ImageWithName(@"no_search_result")];
        _noDataPromptView.prompt.text = @"";
        _noDataPromptView.hidden = YES;
    }
    return _noDataPromptView;
}

@end
