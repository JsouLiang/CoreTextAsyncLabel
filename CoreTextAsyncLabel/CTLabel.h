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
@property (nonatomic, strong) UIColor *textColor;
// defaultFont is SystemFontWithSize 15
@property (nonatomic, strong) UIFont *font;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) NSInteger	lineSpace;

@end
