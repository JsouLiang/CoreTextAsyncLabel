//
//  AsnycLayer.m
//  CoreTextAsyncLabel
//
//  Created by Liang on 2018/5/12.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import "AsnycLayer.h"
#import <libkern/OSAtomic.h>
#import <stdatomic.h>

@interface AsnycLayer()
@property (nonatomic, assign) int32_t signal;
@end

static NSOperationQueue *queue;

@implementation AsnycLayer

- (instancetype)init {
	if (self = [super init]) {
		_signal = 0;
		_displayAsync = YES;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			queue = [[NSOperationQueue alloc] init];
			queue.maxConcurrentOperationCount = 15;
		});
	}
	return self;
}

- (void)signalIncrease {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
	OSAtomicIncrement32(&_signal);
#pragma clang diagnostic pop
}

- (void)cancelPreviousDisplayCalculate {
	[self signalIncrease];
}

- (void)display {
	super.contents = super.contents;
	[self displayAsync:self.displayAsync];
}

-(void)displayAsync:(BOOL)async {
	if (!self.displayBlock) {
		self.contents = nil;
		return ;
	}
	
	if (async) {
		int32_t signal = self.signal;
		BOOL (^isCanceled)(void) = ^BOOL(void){
			return signal != self.signal;
		};
		CGSize size = self.bounds.size;
		BOOL opaque = self.opaque;
		CGFloat scale = self.contentsScale;
		CGColorRef backgrounColor = (opaque && self.backgroundColor) ? CGColorRetain(self.backgroundColor) : NULL;
		if (size.height < 1 || size.width < 1) {
			CGImageRef image = (__bridge_retained CGImageRef)self.contents;
			self.contents = nil;
			if (image) {
				[queue addOperationWithBlock:^{
					CFRelease(image);
				}];
			}
			CGColorRelease(backgrounColor);
		}
		[queue addOperationWithBlock:^{
			if (isCanceled()) {
				CGColorRelease(backgrounColor);
				return ;
			}
			UIGraphicsBeginImageContextWithOptions(size, opaque, scale);
			CGContextRef context = UIGraphicsGetCurrentContext();
			if (opaque) {
				fillContextWithColor(context, backgrounColor, size);
				CGColorRelease(backgrounColor);
			}
			self.displayBlock(context, isCanceled);
			if (isCanceled()) {
				UIGraphicsEndImageContext();
				return ;
			}
			UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
			UIGraphicsEndImageContext();
			if (isCanceled()) {
				return ;
			}
			[[NSOperationQueue mainQueue] addOperationWithBlock:^{
				if (!isCanceled()) {
					self.contents = (__bridge id)image.CGImage;
				}
			}];
		}];
	} else {
		[self signalIncrease];
		UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, self.contentsScale);
		CGContextRef context = UIGraphicsGetCurrentContext();
		if (self.isOpaque) {
			CGSize size = self.bounds.size;
			size.width *= self.contentsScale;
			size.height *= self.contentsScale;
		}
		self.displayBlock(context, ^BOOL{ return NO; });
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		self.contents = (__bridge id)(image.CGImage);
	}
}

static inline void fillContextWithColor(CGContextRef context, CGColorRef color, CGSize size) {
	CGContextSaveGState(context);
		{
			if (color) {
				CGContextSetFillColorWithColor(context, color);
				CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
				CGContextFillPath(context);
			} else if (!color || CGColorGetAlpha(color) < 1){
				CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
				CGContextAddRect(context, CGRectMake(0, 0, size.width, size.height));
				CGContextFillPath(context);
			}
		}
	CGContextRestoreGState(context);
}

@end
