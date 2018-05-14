//
//  CTLabel.h
//  CoreTextLabel
//
//  Created by Liang on 2018/5/9.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 CoreText Label
 */
@interface CTLabel : UIView

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) NSAttributedString *attributedText;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) UIEdgeInsets contentInset;
// defaultFont is SystemFontWithSize 15
@property (nonatomic, strong) UIFont *font;
/** 行数 */
@property (nonatomic, assign) NSUInteger numberOfLines;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic, assign) NSLineBreakMode lineBreakMode;
@property (nonatomic, assign) CGFloat lineSpacing;

@end
