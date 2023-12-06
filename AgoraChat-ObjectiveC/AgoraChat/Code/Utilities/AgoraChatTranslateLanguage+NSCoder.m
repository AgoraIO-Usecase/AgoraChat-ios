//
//  AgoraChatTranslateLanguage+NSCoder.m
//  AgoraChat-Demo
//
//  Created by li xiaoming on 2023/8/8.
//  Copyright © 2023 easemob. All rights reserved.
//

#import "AgoraChatTranslateLanguage+NSCoder.h"

@implementation AgoraChatTranslateLanguage (NSCoder)
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.languageCode forKey:@"languageCode"];
    [coder encodeObject:self.languageNativeName forKey:@"languageNativeName"];
    [coder encodeObject:self.languageName forKey:@"languageName"];
}
- (nullable instancetype)initWithCoder:(NSCoder *)coder
{
    if(self = [super init]) {
        self.languageCode = [coder decodeObjectForKey:@"languageCode"];
        self.languageName = [coder decodeObjectForKey:@"languageName"];
        self.languageNativeName = [coder decodeObjectForKey:@"languageNativeName"];
    }
    return self;
}
@end
