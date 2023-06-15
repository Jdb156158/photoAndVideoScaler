//
//  visionCameraViewController.m
//  photoAndVideoScaler
//
//  Created by jdbing on 2022/7/19.
//

#import "visionCameraViewController.h"
#import "FaceBeautyRecorder.h"

@interface visionCameraViewController ()

@property (nonatomic,strong) FaceBeautyRecorder *recorder;

@end

@implementation visionCameraViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.recorder startCaptureSession];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.recorder stopCaptureSession];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.bounds = [UIScreen mainScreen].bounds;
    self.recorder = [[FaceBeautyRecorder alloc] init];
    self.recorder.showLankmarks = YES;
    [self.recorder setupPreview:self.view];
}

- (IBAction)clickBackBtn:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
