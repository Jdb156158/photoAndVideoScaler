//
//  TestView.m
//  photoAndVideoScaler
//
//  Created by jdbing on 2022/9/21.
//

#import "TestView.h"

@implementation TestView

- (void)setFrame:(CGRect)frame{
    // frame改变需要重绘
    super.frame = frame;
}

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
}

@end
