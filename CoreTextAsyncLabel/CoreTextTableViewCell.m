//
//  CoreTextTableViewCell.m
//  CoreTextAsyncLabel
//
//  Created by Liang on 2018/5/14.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import "CoreTextTableViewCell.h"
#import "CTLabel.h"
@interface CoreTextTableViewCell()
@property (weak, nonatomic) IBOutlet CTLabel *coreTextLabel;

@end

@implementation CoreTextTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setContent:(NSString *)content {
	_content = [content copy];
	_coreTextLabel.text = content;
	_coreTextLabel.frame = CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 20, 40);
}

@end
