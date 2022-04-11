//
//  TimeRulerMark.h
//  TimerDemo
//
//  Created by Ynboo on 2021/3/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : int {
    RulerMarkFrequencyhour        = 3600, //小时标记频率3600秒
    RulerMarkFrequencyminute_10   = 600,  //10分钟标记频率
    RulerMarkFrequencyminute_2    = 120,  //2分钟标记评率
    // 如需要更小时间在此添加枚举值
} RulerMarkFrequency;

@interface TimeRulerMark : NSObject

@property(nonatomic)RulerMarkFrequency frequency;  //标记频率
@property(nonatomic)CGSize  size;                   // 标记尺寸
@property(nonatomic)UIColor *color;                 //标记颜色
@property(nonatomic)UIFont  *font;
@property(nonatomic)UIColor *textColor;


@end

NS_ASSUME_NONNULL_END
