//
//  ViewController.m
//  photoAndVideoScaler
//
//  Created by jdbing on 2022/4/7.
//

#import "ViewController.h"
#import "JDZoomView.h"
#import "BottomFrameZoomView.h"
#import "TimeRuler.h"

// 拿到xib中的view
#define XIBBundleView(bundle, xibName, _owner) [[bundle loadNibNamed:xibName owner:_owner options:nil] firstObject]

@interface ViewController ()<JDZoomViewDelegate>
@property (nonatomic, weak) UIView *subView;
@property (nonatomic, strong) BottomFrameZoomView *bottomFramesZoomView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //self.view.backgroundColor = [UIColor brownColor];
    
//    self.bottomFramesZoomView.imageCount = 8;
//    [self.view addSubview:self.bottomFramesZoomView];

//    JDZoomView *zooomView = [[JDZoomView alloc] initWithFrame:CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 600) duration:200];
//    zooomView.backgroundColor = [UIColor lightGrayColor];
//    zooomView.delegate = self;
//    zooomView.imageCount = 200;
//    [self.view addSubview:zooomView];
//
//    UIView *subView = [[UIView alloc] init];
//    subView.frame = CGRectMake(50, 50, 100, 30);
//    subView.backgroundColor = [UIColor yellowColor];
//    [zooomView.contentView addSubview:subView];
//    self.subView = subView;
    
    TimeRuler *time = [[TimeRuler alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height * 0.5 - 40.0, self.view.bounds.size.width, 180)];
    NSArray *array = @[@{@"start": @60,@"end": @300},
                       @{@"start": @500,@"end": @800},
                       @{@"start": @3600,@"end": @4800},
                       @{@"start": @8501,@"end": @10000},
                       @{@"start": @12000,@"end": @12312}];
    [time setSelectedRange:array];
    [self.view addSubview:time];
}

//#pragma mark - JDZoomViewDelegate
//
//- (void)zoomView:(JDZoomView *)zoomView didChangePosition:(CGFloat)position currentTime:(NSTimeInterval)time{
//
//}
//- (void)zoomViewDidzoom:(JDZoomView *)zoomView atScale:(CGFloat)scale{
//    NSLog(@"scale = %f",scale);
//    self.subView.frame = CGRectMake(50 * scale, 50, 100 * scale, 30);
//}
//
////创建header
//- (BottomFrameZoomView *)bottomFramesZoomView {
//    if (!_bottomFramesZoomView) {
//        _bottomFramesZoomView = XIBBundleView([NSBundle bundleForClass:[self class]], @"BottomFrameZoomView", nil);
//        _bottomFramesZoomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-250, [UIScreen mainScreen].bounds.size.width, 250);
//    }
//    return _bottomFramesZoomView;
//}
@end
