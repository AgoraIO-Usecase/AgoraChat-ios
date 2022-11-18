//
//  ACDTextViewCell.m
//  ChatDemo-UI3.0
//
//  Created by liang on 2021/10/22.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "ACDTextViewCell.h"

#define TextViewLimit 500

@interface ACDTextViewCell() <UITextViewDelegate>
@property (nonatomic, strong) UITextView *contentTextView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UILabel *textCountLabel;

@end

@implementation ACDTextViewCell


- (CGFloat)height {
    return 100.0f;
}

- (void)prepare {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.contentTextView];
    [self.contentView addSubview:self.placeholderLabel];
    [self.contentView addSubview:self.textCountLabel];
    [self.contentView addSubview:self.bottomLine];
}

- (void)placeSubViews {
    [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(10.0f);
        make.bottom.equalTo(self.contentView).offset(-10.0f);
        make.left.equalTo(self.contentView).offset(16.0);
        make.right.equalTo(self.contentView).offset(-16.0);
    }];
    
    [self.placeholderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentTextView).offset(8.0f);
        make.left.equalTo(self.contentTextView);
    }];
    
    [self.textCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.contentView).offset(-5.0);
        make.right.equalTo(self.contentView).offset(-16.0);
    }];
 
    [self.bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentTextView);
        make.right.equalTo(self.contentTextView);
        make.height.mas_equalTo(ACD_ONE_PX);
        make.bottom.equalTo(self.contentView);
    }];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    self.placeholderLabel.hidden = textView.text.length > 0;

   if(textView.markedTextRange == nil){
   //    记录光标位置
       NSRange rang = textView.selectedRange;
       if(textView.text.length > TextViewLimit){
           textView.text = [textView.text substringToIndex:TextViewLimit];
       }
   //截取后还原光标位置
       textView.selectedRange =rang;
       [textView scrollRangeToVisible:rang];
       
       self.textCountLabel.text = [NSString stringWithFormat:@"%@/%@",[@(textView.text.length) stringValue],[@(TextViewLimit) stringValue]];
   }
    
}


#pragma mark getter
- (UILabel *)placeholderLabel {
    if (!_placeholderLabel) {
        _placeholderLabel = UILabel.new;
        _placeholderLabel.font = NFont(14.0);
        _placeholderLabel.textColor = COLOR_HEX(0xE6E6E6);
        _placeholderLabel.text = @"Group Description, not required";
    }
    return _placeholderLabel;
}

- (UITextView *)contentTextView {
    if (!_contentTextView) {
        _contentTextView = UITextView.new;
        _contentTextView.delegate = self;
        _contentTextView.font = NFont(14.0);
        _contentTextView.textColor = COLOR_HEX(0x000000);
    }
    return _contentTextView;
}

- (UILabel *)textCountLabel {
    if (_textCountLabel == nil) {
        _textCountLabel = UILabel.new;
        _textCountLabel.textColor = COLOR_HEX(0xE6E6E6);
        _textCountLabel.textAlignment = NSTextAlignmentCenter;
        _textCountLabel.font = NFont(14.0);
        _textCountLabel.text = [NSString stringWithFormat:@"0/%@",[@(TextViewLimit) stringValue]];
    }
    return _textCountLabel;
}


@end

#undef TextViewLimit
