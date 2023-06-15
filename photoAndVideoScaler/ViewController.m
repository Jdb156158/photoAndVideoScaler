//
//  ViewController.m
//  photoAndVideoScaler
//
//  Created by jdbing on 2022/4/7.
//

#import "ViewController.h"
#import "JDZoomView.h"
#import "BottomFrameZoomView.h"
#import "JbbTestCameraCtrl.h"
#import "visionCameraViewController.h"
#import "TestView.h"
// 拿到xib中的view
#define XIBBundleView(bundle, xibName, _owner) [[bundle loadNibNamed:xibName owner:_owner options:nil] firstObject]

@interface ViewController ()<JDZoomViewDelegate>
@property (nonatomic, weak) UIView *subView;
@property (nonatomic, strong) BottomFrameZoomView *bottomFramesZoomView;
@property (nonatomic, strong) TestView *test1view;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UIButton *nextBtn = [[UIButton alloc] init];
    nextBtn.frame = CGRectMake(self.view.frame.size.width/2.0-50, self.view.frame.size.height/2.0-50, 100, 100);
    [nextBtn setTitle:@"拍照" forState:UIControlStateNormal];
    [nextBtn addTarget:self
                    action:@selector(clickNextBtn2)
          forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:nextBtn];
    
    self.test1view = XIBBundleView([NSBundle bundleForClass:[self class]], @"TestView", nil);
    //self.test1view.frame = CGRectMake(0, 130, [UIScreen mainScreen].bounds.size.width, 20);
    self.test1view.frame =  CGRectMake(0, 130, 100, 100);
    [self.view addSubview:self.test1view];
    
    self.bottomFramesZoomView.imageCount = 8;
    [self.view addSubview:self.bottomFramesZoomView];

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
//创建header
- (BottomFrameZoomView *)bottomFramesZoomView {
    if (!_bottomFramesZoomView) {
        _bottomFramesZoomView = XIBBundleView([NSBundle bundleForClass:[self class]], @"BottomFrameZoomView", nil);
        _bottomFramesZoomView.frame = CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 10);
    }
    return _bottomFramesZoomView;
}

//- (TestView *)test1view{
//    if (!_test1view) {
//        _test1view = XIBBundleView([NSBundle bundleForClass:[self class]], @"TestView", nil);
//        _test1view.frame = CGRectMake(0, 130, [UIScreen mainScreen].bounds.size.width, 100);
//    }
//    return _test1view;
//}

- (IBAction)clickNextBtn:(id)sender {
    JbbTestCameraCtrl *next = [[JbbTestCameraCtrl alloc] init];
    [self.navigationController pushViewController:next animated:YES];
}

-(void)clickNextBtn2{
    JbbTestCameraCtrl *next = [[JbbTestCameraCtrl alloc] init];
    [self.navigationController pushViewController:next animated:YES];
}
@end
