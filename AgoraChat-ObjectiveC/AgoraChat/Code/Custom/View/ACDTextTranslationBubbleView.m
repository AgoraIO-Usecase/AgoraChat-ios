//
//  ACDTextTranslationBubbleView.m
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2023/7/19.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "ACDTextTranslationBubbleView.h"
#import "EaseMessageModel+Translation.h"

@implementation ACDTextTranslationBubbleView

- (NSString*)showText
{
    AgoraChatTextMessageBody *body = (AgoraChatTextMessageBody *)self.model.message.body;
    if (self.model.showTranslation) {
        if (body.translations.count > 0) {
            // fetch first translation
            NSString* translation = [body.translations.allValues firstObject];
            return translation;
        }
    }
    return body.text;
}

@end
