//
//  CTLabel.m
//  CoreTextLabel
//
//  Created by Liang on 2018/5/9.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import "CTLabel.h"
#import "AsnycLayer.h"
#import "DWAsyncLayer.h"
#import "CTCalculator.h"
#import <CoreText/CoreText.h>

static NSUInteger defaultFontSize = 15;
// 省略号 UTF-8编码
static NSString* const kEllipsesCharacter = @"\u2026";

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

static NSMutableAttributedString *getMutableAttributeString(CTLabel *label, CGFloat limitWidth) {
	NSMutableAttributedString *mutableAttributeString = [[NSMutableAttributedString alloc] initWithAttributedString:label.attributedText];
	NSUInteger length = label.attributedText ? label.attributedText.length : label.text.length;

	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	[paragraphStyle setLineBreakMode:label.lineBreakMode];
	[paragraphStyle setLineSpacing:label.lineSpacing];
	[paragraphStyle setAlignment:label.textAlignment];
	
	if (!label.attributedText) {
		NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:label.text];
		[attributeStr addAttribute:NSFontAttributeName value:label.font range:NSMakeRange(0, length)];
		[attributeStr addAttribute:NSForegroundColorAttributeName value:label.textColor range:NSMakeRange(0, length)];
		[attributeStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, length)];
		mutableAttributeString = [attributeStr mutableCopy];
	} else {
		[mutableAttributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, length)];
	}
	return mutableAttributeString;
}

@interface CTLabel()
@property (nonatomic, strong) NSMutableAttributedString *drawedAttributeString;
@end

// CTRun(绘制最小单元) -> CTLine(行) -> CTFrame
@implementation CTLabel {
	NSMutableArray *_rangeArray;
	CTFrameRef _ctFrame;
	dispatch_queue_t _drawTextQueue;
	BOOL _higighting;
}

- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		[self commonInitial];
	}
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self commonInitial];
	}
	return self;
}

- (void)commonInitial {
	_higighting = NO;
	_rangeArray = [NSMutableArray array];
	_textAlignment = NSTextAlignmentLeft;
	_textColor = [UIColor blackColor];
	_font = [UIFont systemFontOfSize:defaultFontSize];
	
	_drawTextQueue = dispatch_queue_create("com.concurrentQueue.drawText", DISPATCH_QUEUE_CONCURRENT);
	
	self.layer.contentsScale = [UIScreen mainScreen].scale;
	__weak typeof(self)weakSelf = self;
	[(AsnycLayer *)self.layer setDisplayBlock:^(CGContextRef context, BOOL (^isCanceled)(void)) {
		__strong typeof(self)strongSelf = weakSelf;
		if (strongSelf) {
			[strongSelf drawTextWithContext:context canceled:isCanceled];
		}
	}];
	
	self.backgroundColor = [UIColor whiteColor];
}

+ (Class)layerClass {
	return [AsnycLayer class];
}

- (void)setNeedsDisplay {
	[super setNeedsDisplay];
	[self.layer setNeedsDisplay];
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
	_text = [text copy];
	_drawedAttributeString = nil;
//	[self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
	if (!attributedText || attributedText.length == 0) {
		return;
	}
	if ([attributedText isEqualToAttributedString:_attributedText]) {
		return ;
	}
	_attributedText = attributedText;
//	[self setNeedsDisplay];
}

- (void)setNumberOfLines:(NSUInteger)numberOfLines {
	if (_numberOfLines != numberOfLines) {
		_numberOfLines = numberOfLines;
//		[self setNeedsDisplay];
	}
}

- (void)drawTextWithContext:(CGContextRef)context canceled:(BOOL (^)(void))canceled {
	dispatch_barrier_sync(_drawTextQueue, ^{
		CGContextSaveGState(context);
		CGContextSetTextMatrix(context, CGAffineTransformIdentity);
		CGContextTranslateCTM(context, 0, self.bounds.size.height);		// 上移
		CGContextScaleCTM(context, 1, -1);								// 绕X轴翻转
		
		CGFloat	residueWidth = CGRectGetWidth(self.bounds) - self.contentInset.left - self.contentInset.right;
		CGFloat residueHeight = CGRectGetHeight(self.bounds) - self.contentInset.top - self.contentInset.bottom;
		CGFloat limitWidth = residueWidth > 0 ? residueWidth : 0;
		CGFloat limitHeight = residueHeight > 0 ? residueHeight : 0;
		BOOL needDrawText = self.attributedText.length || self.text.length;
		
		if (canceled()) {
			return ;
		}
		if (needDrawText) {
			self.drawedAttributeString = getMutableAttributeString(self, limitWidth);
		}
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathAddRect(path, NULL, self.bounds);
		CTFramesetterRef framesetter4Cal = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.drawedAttributeString);
		CTFrameRef frameRef4Cal = CTFramesetterCreateFrame(framesetter4Cal, CFRangeMake(0, 0), path, NULL);
		
		CFRange visibleRange = CTFrameGetVisibleStringRange(frameRef4Cal);
		CFRange lastRange = [CTCalculator lastLineRange:frameRef4Cal
										  numberOfLines:self.numberOfLines
										   visibleRange:visibleRange];
		visibleRange = [CTCalculator visibleRangeFromLastRange:lastRange visibleRange:visibleRange];
		if (canceled()) {
			[self resetFramesetter:framesetter4Cal frame:frameRef4Cal path:path];
			return ;
		}
		if (needDrawText) {
			[self addTruncateWIthLastLineRange:lastRange attributeString:self.drawedAttributeString];
		}
		[self resetFramesetter:framesetter4Cal frame:frameRef4Cal path:NULL];

		CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.drawedAttributeString);
		CFRange drawRange = CFRangeMake(0, visibleRange.length < self.drawedAttributeString.length ? visibleRange.length + 1 : self.drawedAttributeString.length);
		CTFrameRef visibleFrame = CTFramesetterCreateFrame(framesetter, drawRange, path, NULL);
		
		CTFrameDraw(visibleFrame, context);
		[self resetFramesetter:framesetter frame:visibleFrame path:path];
		
		CGContextRestoreGState(context);
	});
}

- (void)addTruncateWIthLastLineRange:(CFRange)lastLineRange attributeString:(NSMutableAttributedString *)attributedString {
	NSRange range = NSMakeRange(lastLineRange.location, lastLineRange.length);
	NSDictionary *textAttribute = [attributedString attributesAtIndex:NSMaxRange(range) - 1 effectiveRange:NULL];
	NSMutableParagraphStyle *paragraphStyle = [textAttribute[NSParagraphStyleAttributeName] mutableCopy];
	if (!paragraphStyle) {
		paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	}
	paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
	[attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:range];
}

- (void)resetFramesetter:(CTFramesetterRef)framesetter frame:(CTFrameRef)frame path:(CGPathRef)path {
	if (frame) {
		CFRelease(frame);
	}
	if (framesetter) {
		CFRelease(framesetter);
	}
	
	if (path) {
		CGPathRelease(path);
	}
}

- (void)drawText:(NSString *)text {
	UIGraphicsBeginImageContextWithOptions(self.frame.size, YES, 0);
	CGContextRef context = UIGraphicsGetCurrentContext();
	[self.backgroundColor set];		// 设置“画笔”颜色
	CGContextFillRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
	// 翻转CoreText坐标系
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextTranslateCTM(context, 0, self.bounds.size.height);		// 上移
	CGContextScaleCTM(context, 1, -1);								// 绕X轴翻转
	
	// 创建绘制区域
	CGMutablePathRef drawPath = CGPathCreateMutable();
	CGPathAddRect(drawPath, NULL, self.bounds);
	
	UIColor *textColor = self.textColor;
	if ([text isEqualToString:_text]) {
		NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.text];
		NSDictionary *textAttribute = @{NSFontAttributeName: self.font,
										NSForegroundColorAttributeName: self.textColor};
		[attributeString setAttributes:textAttribute range:NSMakeRange(0, text.length)];
		// Frame
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
			if ([text isEqualToString:_text] && CGSizeEqualToSize(textImage.size, self.frame.size)) {
			}
		});
	}
}

@end
