//
//  BottomFrameZoomView.m
//  photoAndVideoScaler
//
//  Created by jdbing on 2022/4/8.
//

#import "BottomFrameZoomView.h"
#import "UIView+Frame.h"
#import "JDScaleView.h"

#define K_ZOOMW [UIScreen mainScreen].bounds.size.width
#define K_ZOOMH [UIScreen mainScreen].bounds.size.height
@interface BottomFrameZoomView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) JDScaleView *scaleView;
@property (nonatomic, assign) CGFloat defaultWidth;
@property (nonatomic, assign) CGFloat currentScale;
@property (nonatomic, assign) CGFloat maxScale;
@property (nonatomic, assign) CGFloat minScale;
@end

@implementation BottomFrameZoomView

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    [self addSubview:self.contentScrollView];
    [self.contentScrollView addSubview:self.scaleView];
    
    //添加捏合手势
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.contentScrollView addGestureRecognizer:pin];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentScrollView.frame = self.bounds;
}

- (void)setImageCount:(NSInteger)imageCount{
    
    _imageCount = imageCount;
    
    //计算出每帧的宽度，默认最小颗粒：1帧，最小颗粒的时候：每帧宽度K_ZOOMW/4
    //设置内容的可显示范围
    CGFloat allSizeWidth = K_ZOOMW+((K_ZOOMW/2)/4)*imageCount;
    self.defaultWidth = allSizeWidth;
    self.contentScrollView.contentSize = CGSizeMake(allSizeWidth, 0);
    self.scaleView.frame = CGRectMake(K_ZOOMW/2, 0, allSizeWidth-K_ZOOMW, 30);
    self.scaleView.secondPerPoint = ((K_ZOOMW/2)/4);
    
    self.currentScale = 1;
    self.maxScale = 1;
    self.minScale = (K_ZOOMW+K_ZOOMW/2)/allSizeWidth;
    
}

- (UIScrollView *)contentScrollView
{
    if (_contentScrollView == nil) {
        _contentScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _contentScrollView.bouncesZoom = NO;
        _contentScrollView.multipleTouchEnabled = YES;
        _contentScrollView.alwaysBounceVertical = NO;
        _contentScrollView.alwaysBounceHorizontal = YES;
        _contentScrollView.delaysContentTouches  = NO;
        _contentScrollView.canCancelContentTouches = YES;
        _contentScrollView.userInteractionEnabled = YES;
        _contentScrollView.backgroundColor = [UIColor clearColor];
        _contentScrollView.directionalLockEnabled = YES;
        _contentScrollView.delegate = self;
    }
    return _contentScrollView;
}

- (JDScaleView *)scaleView{
    if (_scaleView == nil) {
        _scaleView = [[JDScaleView alloc] initWithFrame:CGRectMake(K_ZOOMW/2, 0, K_ZOOMW/2, 30)];
        _scaleView.backgroundColor = [UIColor redColor];
    }
    return _scaleView;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //[self.scaleView setNeedsDisplay];
}

#pragma mark - 捏合手势
- (void)pinchGesture:(UIPinchGestureRecognizer *)pinch{
    
    static CGFloat tempScale;
    static CGFloat scale;
    static CGFloat originalOffsetX;
    static CGFloat originalCenterX;
    if (pinch.state == UIGestureRecognizerStateBegan) {
        
        tempScale = self.currentScale;
        scale = 0;
        originalOffsetX = self.contentScrollView.contentOffset.x;
        if (pinch.numberOfTouches == 2) {
            CGPoint p1 = [pinch locationOfTouch:0 inView:pinch.view.superview];
            CGPoint p2 = [pinch locationOfTouch:1 inView:pinch.view.superview];
            originalCenterX = (p1.x + p2.x) / 2;
        }
    } else if (pinch.state == UIGestureRecognizerStateChanged){
        
        scale = tempScale + pinch.scale - 1;
        if (scale > self.maxScale) {
            scale = self.maxScale;
            NSLog(@"=====超过最大缩放值:%f====",scale);
        }
        if (scale < self.minScale) {
            scale = self.minScale;
            NSLog(@"=====超过最小缩放值:%f====",scale);
        }
        self.currentScale = scale;
        NSLog(@"=====当前缩放值:%f====",self.currentScale);
        self.scaleView.currentScale = scale;
        if (pinch.numberOfTouches == 2) {

            CGPoint p1 = [pinch locationOfTouch:0 inView:pinch.view.superview];
            CGPoint p2 = [pinch locationOfTouch:1 inView:pinch.view.superview];
            CGFloat centerX = (p1.x + p2.x) / 2;
            CGFloat offsetX = originalOffsetX +  2 * (originalCenterX - centerX); // 根据手指滑动的位置调整offset
            originalOffsetX = offsetX; // 重新赋值，调整基准
            originalCenterX = centerX;
            self.contentScrollView.contentSize = CGSizeMake(self.defaultWidth * scale, 0);
            self.scaleView.frame = CGRectMake(self.scaleView.frame.origin.x, 0, self.defaultWidth * scale-K_ZOOMW, 30);
            if (offsetX > 0) {
                [self.contentScrollView setContentOffset:CGPointMake(offsetX, 0)];
            } else {
                [self.scaleView setNeedsDisplay];
            }
            [self setNeedsLayout];
        }
    } else if (pinch.state == UIGestureRecognizerStateEnded){
        [self.scaleView setNeedsDisplay];
    }
}

@end
