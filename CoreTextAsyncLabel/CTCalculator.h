//
//  CTCalculator.h
//  CoreTextAsyncLabel
//
//  Created by Liang on 2018/5/14.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface CTCalculator : NSObject

+ (CFRange)lastLineRange:(CTFrameRef)frame numberOfLines:(NSUInteger)numberOfLines visibleRange:(CFRange)visibleRange;

+ (CFRange)visibleRangeFromLastRange:(CFRange)lastRange visibleRange:(CFRange)visibleRange;

@end
