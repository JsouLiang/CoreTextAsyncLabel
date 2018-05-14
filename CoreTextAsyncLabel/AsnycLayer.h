//
//  AsnycLayer.h
//  CoreTextAsyncLabel
//
//  Created by Liang on 2018/5/12.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface AsnycLayer : CALayer

@property (nonatomic ,copy) void (^displayBlock)(CGContextRef context,BOOL(^isCanceled)(void));
@property (nonatomic, assign) BOOL displayAsync;

@end
