//
//  TimeRulerLayer.m
//  TimerDemo
//
//  Created by Ynboo on 2021/3/19.
//

#import "TimeRulerLayer.h"

// 侧边多出部分宽度
static CGFloat sideOffset = 30.0;

@implementation TimeRulerLayer

// 最小标记
- (TimeRulerMark*)minorMark{
    if (!_minorMark){
        _minorMark = [[TimeRulerMark alloc] init];
        _minorMark.frequency = RulerMarkFrequencyminute_2;
        _minorMark.size = CGSizeMake(1.0, 4.0);
    }
    return _minorMark;
}

// 中等标记
- (TimeRulerMark*)middleMark{
    if (!_middleMark){
        _middleMark = [[TimeRulerMark alloc] init];
        _middleMark.frequency = RulerMarkFrequencyminute_10;
        _middleMark.size = CGSizeMake(1.0, 8.0);
    }
    return _middleMark;
}

// 大标记
- (TimeRulerMark*)majorMark{
    if (!_majorMark){
        _majorMark = [[TimeRulerMark alloc] init];
        _majorMark.frequency = RulerMarkFrequencyhour;
        _majorMark.size = CGSizeMake(1.0, 13.0);
    }
    return _majorMark;
}


// 选中区域
- (void)setSelectedRange:(NSArray *)selectedRange{
    _selectedRange = selectedRange;
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame{
    // frame改变需要重绘
    super.frame = frame;
    [self setNeedsDisplay];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor].CGColor;
    }
    return self;
}

- (void)display{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self drawToImage];
    [CATransaction commit];
}

- (void)drawToImage{
    RulerMarkFrequency frequency = RulerMarkFrequencyminute_10;
    // 每小时占用的宽度
    CGFloat hourWidth = (self.bounds.size.width - sideOffset*2)/24.0;
    
    // 根据宽度来判断显示标记的级别
    if (hourWidth/30.0 >= 8.0){
        frequency = RulerMarkFrequencyminute_2;
    }else if (hourWidth / 6.0 >= 5.0){
        frequency = RulerMarkFrequencyminute_10;
    }else{
        frequency = RulerMarkFrequencyhour;
    }
    
    int numberOfLine = 24 * 3600 / frequency;
    CGFloat lineOffset = (self.bounds.size.width - sideOffset * 2) / numberOfLine;
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, UIScreen.mainScreen.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIFont *font = [UIFont systemFontOfSize:11.0];
    //行间距和字体
    NSDictionary *dict1 = @{NSFontAttributeName:font};
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:@"00:00" attributes:dict1];
    // 计算文字最宽宽度
    CGFloat hourTextWidth = attrString.size.width;
    
    if (self.selectedRange.count > 0){
        
        CGContextSetFillColorWithColor(ctx, [[UIColor alloc]initWithRed:238.0/255.0 green:165.0/255 blue:133.0/255 alpha:1.0].CGColor);
        for (NSDictionary *selectedItem in self.selectedRange) {
            int startSecond = [[selectedItem valueForKey:@"start"] intValue];
            int endSecond = [[selectedItem valueForKey:@"end"] intValue];
            CGFloat x = startSecond / (24 * 3600.0) * (self.bounds.size.width - sideOffset * 2) + sideOffset;
            CGFloat width = (endSecond - startSecond) / (24 * 3600.0) * (self.bounds.size.width - sideOffset * 2);
            CGRect rect = CGRectMake(x, 0, width, self.bounds.size.height);
            CGContextFillRect(ctx, rect);
        }
        
        for(int i = 0; i <= numberOfLine; i++){
            // 计算每个标记的属性
            CGFloat position = i * lineOffset;
            int timeSecond = i * frequency;
            BOOL showText = NO;
            NSString *timeString = @"00:00";
            TimeRulerMark *mark = self.minorMark;
            
            if (timeSecond % 3600 == 0){
                // 小时标尺
                mark = self.majorMark;
                if (hourWidth > (hourTextWidth + 5.0)){
                    // 每小时都能画时间
                    showText = YES;
                }
                else if ((hourWidth * 3) > ((hourTextWidth + 5) * 2)){
                    // 每两小时画一个时间
                    showText = timeSecond % (3600 * 2) == 0;
                }
                else{
                    // 每四小时画一个时间
                    showText = timeSecond % (3600 * 4) == 0;
                }
            }else if (timeSecond % 600 == 0){
                // 每10分钟的标尺
                mark = self.middleMark;
                showText = frequency == RulerMarkFrequencyminute_2;
            }
            
            int hour = timeSecond / 3600;
            int min = timeSecond % 3600 / 60;
            
            timeString = [NSString stringWithFormat:@"%02d:%02d", hour, min];
            [self drawMarkIn:ctx position:position timeString:timeString mark:mark showText:showText];
        }
        
        UIImage *imageToDraw = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        self.contents = (__bridge id _Nullable)(imageToDraw.CGImage);
    }
}

- (void)drawMarkIn:(CGContextRef)context position:(CGFloat)position timeString:(NSString*)timeString mark:(TimeRulerMark*)mark showText:(BOOL)showText{
        
    //行间距和字体
    NSDictionary *textAttribute = @{NSFontAttributeName:mark.font,
                           NSFontAttributeName:mark.textColor};
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:timeString attributes:textAttribute];
    CGSize textSize = attributeString.size;
    CGFloat rectX = position + sideOffset - mark.size.width * 0.5;
    CGFloat rectY = 0;
    
    // 上标记rect
    CGRect rect = CGRectMake(rectX, rectY, mark.size.width, mark.size.height);
    
    //下标记rect
    CGRect btmRect = CGRectMake(rectX, self.bounds.size.height-mark.size.height, mark.size.width, mark.size.height);
    
    CGContextSetFillColorWithColor(context, mark.color.CGColor);
    
    CGContextFillRect(context, rect);
    CGContextFillRect(context, btmRect);

//    CGContextFillRects(context, btmRect, 2);

    if (showText){
        CGFloat textRectX = position + sideOffset - textSize.width * 0.5;
        CGFloat textRectY = CGRectGetMaxY(rect) + 4.0;
        if ((textRectY + textSize.height * 0.5) > (self.bounds.size.height * 0.5)){
            textRectY = (self.bounds.size.height - textSize.height) * 0.5;
        }
        CGRect textRect = CGRectMake(textRectX, textRectY, textSize.width, textSize.height);
        NSString *ocString = timeString;
        [ocString drawInRect:textRect withAttributes:textAttribute];
    }
}


@end
    
