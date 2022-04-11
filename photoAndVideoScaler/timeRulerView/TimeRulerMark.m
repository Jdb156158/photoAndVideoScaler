//
//  TimeRulerMark.m
//  TimerDemo
//
//  Created by Ynboo on 2021/3/19.
//

#import "TimeRulerMark.h"

@implementation TimeRulerMark

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setNormal];
    }
    return self;
}

- (void)setNormal{
    
    self.color = [[UIColor alloc]initWithWhite:0.78 alpha:1.0];
    self.font = [UIFont systemFontOfSize:9.0];
    self.textColor = [[UIColor alloc]initWithWhite:0.43 alpha:1.0];
}

@end
