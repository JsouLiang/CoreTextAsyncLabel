//
//  NormalTableViewCell.m
//  CoreTextAsyncLabel
//
//  Created by Liang on 2018/5/14.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import "NormalTableViewCell.h"

@interface NormalTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *label;
@end

@implementation NormalTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setContent:(NSString *)content {
	_content = [content copy];
	_label.text = content;
	[_label sizeToFit];
	_label.frame = CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 20, _label.frame.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
