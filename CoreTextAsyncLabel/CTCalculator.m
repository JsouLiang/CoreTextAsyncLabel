//
//  CTCalculator.m
//  CoreTextAsyncLabel
//
//  Created by Liang on 2018/5/14.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import "CTCalculator.h"

@implementation CTCalculator

+ (CFRange)lastLineRange:(CTFrameRef)frame numberOfLines:(NSUInteger)numberOfLines visibleRange:(CFRange)visibleRange {
	CFRange range = CFRangeMake(0, 0);
	NSRange visRange = NSMakeRange(visibleRange.location, visibleRange.length);
	if (numberOfLines == 0) {
		numberOfLines = ULONG_MAX;
	}
	CFArrayRef lines = CTFrameGetLines(frame);
	CFIndex lineCount = CFArrayGetCount(lines);
	if (lineCount > 0) {
		NSUInteger lineNum = 0;
		if (numberOfLines <= lineCount) {
			lineNum = numberOfLines;
			CTLineRef line = CFArrayGetValueAtIndex(lines, lineNum - 1);
			range = CTLineGetStringRange(line);
		} else {
			for (int index = 0; index < lineCount; index++) {
				CTLineRef line = CFArrayGetValueAtIndex(lines, index);
				CFRange tempRange = CTLineGetStringRange(line);
				if (NSLocationInRange(NSMaxRange(NSMakeRange(tempRange.location, tempRange.length - 1)), visRange)) {
					range = tempRange;
				} else {
					break;
				}
			}
		}
	}
	return range;
}

+ (CFRange)visibleRangeFromLastRange:(CFRange)lastRange visibleRange:(CFRange)visibleRange {
	CFRange range = CFRangeMake(0, 0);
	
	range.location = MIN(visibleRange.location, lastRange.location);
	NSUInteger visibleMaxLocation = visibleRange.location + visibleRange.length;
	NSUInteger lastMaxLocation = lastRange.location + lastRange.length;
	range.length = MIN(visibleMaxLocation, lastMaxLocation) - range.location;
	return range;
}

@end
