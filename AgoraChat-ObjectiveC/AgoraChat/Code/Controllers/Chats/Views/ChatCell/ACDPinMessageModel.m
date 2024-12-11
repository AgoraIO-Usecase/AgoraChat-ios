//
//  ACDPinMessageModel.m
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2024/3/12.
//  Copyright © 2024 easemob. All rights reserved.
//

#import "ACDPinMessageModel.h"

@interface ACDPinMessageModel()

@end

@implementation ACDPinMessageModel

- (instancetype)initWithMessage:(AgoraChatMessage *)message
{
    self = [super init];
    if (self) {
        _message = message;
    }
    return self;
}

-(NSString *)title
{
    return [NSString stringWithFormat:@"%@ pinned %@'s message",self.message.pinnedInfo.operatorId,self.message.from];
}

- (NSString *)dateString
{
    if (!_dateString) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.message.pinnedInfo.pinTime/1000];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale currentLocale]];
        [dateFormatter setDateFormat:@"MM-dd, HH:mm"];
        _dateString = [dateFormatter stringFromDate:date];
    }
    return _dateString;
}

- (NSUInteger)contentHeight
{
    switch (_message.body.type) {
        case AgoraChatMessageBodyTypeText:
        case AgoraChatMessageBodyTypeFile:
        case AgoraChatMessageBodyTypeVoice:
        case AgoraChatMessageBodyTypeCombine:
        case AgoraChatMessageBodyTypeLocation:
            return 65;
        case AgoraChatMessageBodyTypeImage:
        {
            AgoraChatImageMessageBody* imageBody = (AgoraChatImageMessageBody*)_message.body;
            if (imageBody.thumbnailSize.height > 0)
                return 45 + imageBody.thumbnailSize.height;
            else
                return 45 + 100;
        }
            break;
        case AgoraChatMessageBodyTypeVideo:
        {
            AgoraChatVideoMessageBody* videoBody = (AgoraChatVideoMessageBody*)_message.body;
            if (videoBody.thumbnailSize.height > 0)
                return 45 + videoBody.thumbnailSize.height;
            else
                return 45 + 100;
        }
            break;
            
        default:
            break;
    }
    return 50;
}

@end
