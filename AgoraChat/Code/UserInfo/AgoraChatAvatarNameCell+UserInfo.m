//
//  AgoraChatAvatarNameCell+UserInfo.m
//  EaseIM
//
//  Created by lixiaoming on 2021/3/31.
//  Copyright © 2021 lixiaoming. All rights reserved.
//

#import "AgoraChatAvatarNameCell+UserInfo.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation AgoraChatAvatarNameCell (UserInfo)
-(void) refreshUserInfo:(NSString*)aUid
{
    if(aUid.length == 0)
        return;
    AgoraChatUserInfo* userInfo = [[UserInfoStore sharedInstance] getUserInfoById:aUid];
    if(userInfo) {
        if(userInfo.avatarUrl.length > 0) {
            NSURL* url = [NSURL URLWithString:userInfo.avatarUrl];
            if(url) {
                [self.avatarView sd_setImageWithURL:url completed:nil];
            }
        }
        if(userInfo.nickName.length > 0)
        {
            self.nameLabel.text = userInfo.nickName;
            self.detailLabel.text = aUid;
        }
    }else{
        [[UserInfoStore sharedInstance] fetchUserInfosFromServer:@[aUid]];
    }
}
@end
