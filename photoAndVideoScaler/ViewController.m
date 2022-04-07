//
//  ViewController.m
//  photoAndVideoScaler
//
//  Created by jdbing on 2022/4/7.
//

#import "ViewController.h"
#import "JDZoomView.h"
@interface ViewController ()<JDZoomViewDelegate>
@property (nonatomic, weak) UIView *subView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor brownColor];

    JDZoomView *zooomView = [[JDZoomView alloc] initWithFrame:CGRectMake(0, 150, [UIScreen mainScreen].bounds.size.width, 600) duration:800];
    zooomView.backgroundColor = [UIColor lightGrayColor];
    zooomView.delegate = self;
    [self.view addSubview:zooomView];
    
    UIView *subView = [[UIView alloc] init];
    subView.frame = CGRectMake(50, 50, 100, 30);
    subView.backgroundColor = [UIColor yellowColor];
    [zooomView.contentView addSubview:subView];
    self.subView = subView;
}

#pragma mark - JDZoomViewDelegate

- (void)zoomView:(JDZoomView *)zoomView didChangePosition:(CGFloat)position currentTime:(NSTimeInterval)time{
    
}
- (void)zoomViewDidzoom:(JDZoomView *)zoomView atScale:(CGFloat)scale{
    NSLog(@"scale = %f",scale);
    self.subView.frame = CGRectMake(50 * scale, 50, 100 * scale, 30);
}
@end
