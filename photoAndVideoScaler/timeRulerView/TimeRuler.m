//
//  TimeRuler.m
//  TimerDemo
//
//  Created by Ynboo on 2021/3/19.
//

#import "TimeRuler.h"


// 侧边多出部分宽度
static CGFloat sideOffset = 30.0;
// 时间尺最大宽度
static CGFloat rulerMaxWidth = 10800.0;

@interface TimeRuler()<UIScrollViewDelegate>

@property(nonatomic)int currentTime;
@property(nonatomic)CGFloat rulerWidth;
@property(nonatomic,retain)UIScrollView *scrollView;
@property(nonatomic,retain)UIView *topLine;
@property(nonatomic,retain)UIView *btmLine;
@property(nonatomic)double startScale;
@property(nonatomic)BOOL isTouch;
@property(nonatomic)CGFloat oldRulerWidth;
@property(nonatomic,retain)TimeRulerLayer *rulerLayer;


@end

@implementation TimeRuler

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self defaultValue];
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self defaultValue];
    }
    return self;
}

- (void)defaultValue{
    self.rulerWidth = 6.0 * self.bounds.size.width;
}

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setupUI];
}

- (void)setupUI{
    [self setupLineUI];
    [self setupScrollViewUI];
    [self setupRulerLayer];
    
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchAction:)];
    [self addGestureRecognizer:pinch];
}

- (void)setSelectedRange:(NSArray *)rangeArray{
    self.rulerLayer.selectedRange = rangeArray;
}

- (void)pinchAction:(UIPinchGestureRecognizer*)recoginer{
    if (recoginer.state == UIGestureRecognizerStateBegan){
        self.scrollView.scrollEnabled = NO;
        self.startScale = recoginer.scale;
    }else if (recoginer.state == UIGestureRecognizerStateChanged){
        [self updateFrame: recoginer.scale/self.startScale];
        self.startScale = recoginer.scale;
    }else if (recoginer.state == UIGestureRecognizerStateEnded){
        self.scrollView.scrollEnabled = YES;
    }
}

- (void)updateFrame:(double)scale{
    CGFloat updateRulerWidth = self.rulerLayer.bounds.size.width * scale;
    if (updateRulerWidth < self.bounds.size.width + 2 * sideOffset){
        updateRulerWidth = (self.bounds.size.width + 2 * sideOffset);
    }
    
    if (updateRulerWidth > rulerMaxWidth){
        updateRulerWidth = rulerMaxWidth;
    }
    
    self.oldRulerWidth = self.rulerWidth;
    self.rulerWidth = updateRulerWidth;
    
    [self setNeedsLayout];
}

- (void)setupLineUI{
    self.topLine = [[UIView alloc] init];
    self.btmLine = [[UIView alloc] init];
    self.topLine.backgroundColor = [[UIColor alloc] initWithWhite:0.78 alpha:1.0];
    self.btmLine.backgroundColor = [[UIColor alloc] initWithWhite:0.78 alpha:1.0];
    [self addSubview:self.topLine];
    [self addSubview:self.btmLine];
}

- (void)setupScrollViewUI{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    [self.scrollView.pinchGestureRecognizer setEnabled:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self addSubview:self.scrollView];
    
}

- (void)setupRulerLayer{
    self.rulerLayer = [[TimeRulerLayer alloc]init];
    [self.scrollView.layer addSublayer:self.rulerLayer];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat sideInset = self.bounds.size.width / 2.0;
    self.scrollView.frame = self.bounds;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, sideInset-sideOffset, 0, sideInset-sideOffset);
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.rulerLayer.frame = CGRectMake(0, 0, self.rulerWidth, self.bounds.size.height);
    [CATransaction commit];
    
    self.scrollView.contentSize = CGSizeMake(self.rulerWidth, self.bounds.size.height);
    self.topLine.frame = CGRectMake(0, 0, self.bounds.size.width, 1.0);
    self.btmLine.frame = CGRectMake(0, self.bounds.size.height - 1.0, self.bounds.size.width, 1.0);
    // 保证缩放过程中心保持不变
    self.scrollView.contentOffset = [self contentOffset:self.currentTime];
}

- (CGPoint)contentOffset:(int)current{
    CGFloat proportion = current / (24 * 3600.0);
    CGFloat proportionWidth = (self.scrollView.contentSize.width - sideOffset * 2) * proportion;
    return CGPointMake(proportionWidth - self.scrollView.contentInset.left, self.scrollView.contentOffset.y);
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    self.isTouch = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat proportionWidth = scrollView.contentOffset.x + scrollView.contentInset.left;
    CGFloat proportion = proportionWidth/(scrollView.contentSize.width - sideOffset * 2);
    int value = ceil(proportion * 24 * 3600);
    self.currentTime = value;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    self.isTouch = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate){
        self.isTouch = NO;
    }
}

@end
