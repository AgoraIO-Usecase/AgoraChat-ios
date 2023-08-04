//
//  AgoraChatMessage+ShowText.m
//  AgoraChat-Demo
//
//  Created by 朱继超 on 2023/8/3.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "AgoraChatMessage+ShowText.h"

@implementation AgoraChatMessage (ShowText)

- (NSString *)showText
{
    switch (self.body.type) {
        case AgoraChatMessageBodyTypeText: {
            return ((AgoraChatTextMessageBody *)self.body).text;
        }
        case AgoraChatMessageBodyTypeLocation:
            return @"[Location]";
        case AgoraChatMessageBodyTypeImage:
            return @"[Image]";
        case AgoraChatMessageBodyTypeCombine:
            return [NSString stringWithFormat:@"%@%@", @"[Chat History]", ((AgoraChatCombineMessageBody *)self.body).title];
        case AgoraChatMessageBodyTypeFile:
            return [NSString stringWithFormat:@"%@%@", @"[File]", ((AgoraChatFileMessageBody *)self.body).displayName];
        case AgoraChatMessageBodyTypeVoice:
            return [NSString stringWithFormat:@"%@%d”", @"[Audio]", ((AgoraChatVoiceMessageBody *)self.body).duration];
        case AgoraChatMessageBodyTypeVideo:
            return @"[Video]";
        default:
            return @"unknow message";
    }
}


@end
