//
//  TimeRulerLayer.h
//  TimerDemo
//
//  Created by Ynboo on 2021/3/19.
//

#import <QuartzCore/QuartzCore.h>
#import "TimeRulerMark.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeRulerLayer : CALayer

// 最小标记
@property(nonatomic,retain)TimeRulerMark *minorMark;
// 中等标记
@property(nonatomic,retain)TimeRulerMark *middleMark;
// 大标记
@property(nonatomic,retain)TimeRulerMark *majorMark;

@property(nonatomic,retain)NSArray  *selectedRange;


@end

NS_ASSUME_NONNULL_END
