//
//  BottomFrameZoomView.m
//  photoAndVideoScaler
//
//  Created by jdbing on 2022/4/8.
//

#import "BottomFrameZoomView.h"
#import "TimeRuler.h"
@interface BottomFrameZoomView()
@property (weak, nonatomic) IBOutlet UIView *centeredLineView;

@end

@implementation BottomFrameZoomView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor greenColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        TimeRuler *time = [[TimeRuler alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        time.imageCount = 200;
        NSArray *array = @[@{@"start": @60,@"end": @300},
                           @{@"start": @500,@"end": @800},
                           @{@"start": @3600,@"end": @4800},
                           @{@"start": @8501,@"end": @10000},
                           @{@"start": @12000,@"end": @12312}];
        [time setSelectedRange:array];
        [self addSubview:time];
        
        [self bringSubviewToFront:self.centeredLineView];
    });
    
}



@end
