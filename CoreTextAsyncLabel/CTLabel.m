//
//  CTLabel.m
//  CoreTextLabel
//
//  Created by Liang on 2018/5/9.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import "CTLabel.h"
#import <CoreText/CoreText.h>

static NSUInteger defaultFontSize = 15;

static CTTextAlignment CTTextAlignmentFromNSTextAlignment(NSTextAlignment textAlignment) {
	switch (textAlignment) {
		case NSTextAlignmentLeft:
			return kCTTextAlignmentLeft;
		case NSTextAlignmentRight:
			return kCTTextAlignmentRight;
		case NSTextAlignmentCenter:
			return kCTTextAlignmentCenter;
		case NSTextAlignmentNatural:
			return kCTTextAlignmentNatural;
		case NSTextAlignmentJustified:
			return kCTTextAlignmentJustified;
		default:
			break;
	}
}

// CTRun(绘制最小单元) -> CTLine(行) -> CTFrame
@implementation CTLabel {
	UIImageView *_labelImageView;
	NSMutableArray *_rangeArray;
	CTFrameRef _ctFrame;
	BOOL _higighting;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		_higighting = NO;
		_rangeArray = [NSMutableArray array];
		_textAlignment = NSTextAlignmentLeft;
		_textColor = [UIColor blackColor];
		_font = [UIFont systemFontOfSize:defaultFontSize];
		
		_labelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		_labelImageView.contentMode = UIViewContentModeScaleAspectFill;
		_labelImageView.clipsToBounds = YES;
		[self addSubview:_labelImageView];
		
		self.backgroundColor = [UIColor whiteColor];
	}
	return self;
}

- (void)setFrame:(CGRect)frame {
	[super setFrame:frame];
}

- (void)setText:(NSString *)text {
	if (!text || text.length == 0) {
		return ;
	}
	if ([text isEqualToString:_text]) {
		return ;
	}
	CGRect frame = self.frame;
	dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSString *temp = text;
		_text = [text copy];
		
		UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0);
		CGContextRef context = UIGraphicsGetCurrentContext();
		[self.backgroundColor set];		// 设置“画笔”颜色
		CGContextFillRect(context, CGRectMake(0, 0, frame.size.width, frame.size.height));
		// 翻转CoreText坐标系
		CGContextSetTextMatrix(context, CGAffineTransformIdentity);
		CGContextTranslateCTM(context, 0, self.bounds.size.height);		// 上移
		CGContextScaleCTM(context, 1, -1);								// 绕X轴翻转
		
		// 创建绘制区域
		CGMutablePathRef drawPath = CGPathCreateMutable();
		CGPathAddRect(drawPath, NULL, self.bounds);
		
		UIColor *textColor = self.textColor;
		if ([temp isEqualToString:_text]) {
			NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.text];
			NSDictionary *textAttribute = @{NSFontAttributeName: self.font,
											NSForegroundColorAttributeName: self.textColor};
			[attributeString setAttributes:textAttribute range:NSMakeRange(0, temp.length)];
			CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attributeString);
			_ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, CFAttributedStringGetLength((CFAttributedStringRef)attributeString)), drawPath, NULL);
			CTFrameDraw(_ctFrame, context);
			
			CGPathRelease(drawPath);
			CFRelease(framesetter);
			
			UIImage *textImage = [UIImage imageWithCGImage:UIGraphicsGetImageFromCurrentImageContext().CGImage
													 scale:[UIScreen mainScreen].scale
											   orientation:UIImageOrientationUp];
			UIGraphicsEndImageContext();
			dispatch_async(dispatch_get_main_queue(), ^{
				if ([temp isEqualToString:_text] && CGSizeEqualToSize(textImage.size, self.frame.size)) {
					_labelImageView.image = textImage;
				}
			});
		}
	});
}

@end
