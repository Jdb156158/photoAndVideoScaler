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

- (void)setImageCount:(NSInteger)imageCount{
    _imageCount = imageCount;
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
    
    //NSLog(@"当前可用宽度:%f",self.bounds.size.width);
    if (self.imageCount == 0) {
        return;
    }
    
    bool isEven;
    if (self.imageCount%2==0) {
        //如果是偶数
        isEven = YES;
    }else{
        //如果是奇数
        isEven = NO;
    }
    
    NSLog(@"当前图片数量:%ld",(long)self.imageCount);
    CGFloat biaozhun = [UIScreen mainScreen].bounds.size.width/2.0/4.0;
    CGFloat enbleShowImageCount = self.bounds.size.width/biaozhun;
    NSLog(@"当前宽度能显示的图片数量:%f",enbleShowImageCount);
    int scanel = ceil(self.imageCount/enbleShowImageCount);
    NSLog(@"当前缩放倍速：%d",scanel);
    
    NSInteger numberOfLine = self.imageCount;
    //CGFloat lineOffset = (self.bounds.size.width - sideOffset * 2) / numberOfLine;
    if (scanel!=1) {
        //
        numberOfLine = ceil(self.imageCount/scanel);
        NSLog(@"当前宽度应该显示的图片数量:%ld",(long)numberOfLine);
        //lineOffset = biaozhun;
    }else{
        //按照当前需要缩小的宽度来显示
        //NSLog(@"当前刻度间接值:%f",self.bounds.size.width/self.imageCount);
    }

    CGFloat lineOffset = (self.bounds.size.width - sideOffset * 2) / numberOfLine;
    
    
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, UIScreen.mainScreen.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    
    if (self.selectedRange.count > 0){
        
        for(int i = 0; i <= numberOfLine; i++){
            // 计算每个标记的属性
            CGFloat position = i * lineOffset;
            BOOL showText = YES;
            NSString *timeString = @"0";
            TimeRulerMark *mark = self.minorMark;
            
            if (i==numberOfLine) {
                timeString = [NSString stringWithFormat:@"%ldf", (long)self.imageCount];
            }else{
                timeString = [NSString stringWithFormat:@"%df", i*scanel];
            }
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
    
