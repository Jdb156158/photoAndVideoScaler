//
//  JbbTestCameraCtrl.m
//  photoAndVideoScaler
//
//  Created by jdbing on 2022/7/11.
//

#import "JbbTestCameraCtrl.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <MLImageSegmentationLibrary/MLFrame.h>
#import <MLImageSegmentationLibrary/MLImageSegmentation.h>
#import <MLImageSegmentationLibrary/MLImageSegmentationSetting.h>
#import <MLImageSegmentationLibrary/MLImageSegmentationAnalyzer.h>

#import "GPUImagePicture.h"
#import "GPUImageBeautifyFilter.h"
#import "GPUImageSketchFilter.h"
#import "LFGPUImageBeautyFilter.h"
#import "SCFilterHelper.h"

@interface JbbTestCameraCtrl ()<AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) MLImageSegmentationAnalyzer *analyzer;

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

//捕获设备，通常是前置摄像头，后置摄像头，麦克风（音频输入）
@property (nonatomic,strong) AVCaptureDevice *inputDevice;
//session会话 由它把输入输出结合在一起，并开始启动捕获设备（摄像头）
@property (nonatomic,strong) AVCaptureSession *session;
//AVCaptureDeviceInput 代表输入设备，使用AVCaptureDevice 来初始化
@property (nonatomic,strong) AVCaptureDeviceInput *captureDeviceInput;
@property (nonatomic,strong) NSMutableArray *landmarksLayers;
@end

@implementation JbbTestCameraCtrl

#pragma mark - lazy

- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        _session.sessionPreset = AVCaptureSessionPresetMedium;
        if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            [_session setSessionPreset:AVCaptureSessionPreset1280x720];
        }

        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        dispatch_queue_t queue = dispatch_queue_create("video data queue", NULL);
        [output setSampleBufferDelegate:self queue:queue];
        output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey, nil];
        
        if ([_session canAddOutput:output]) {
            [_session addOutput:output];
        }
    }
    return _session;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.landmarksLayers = [[NSMutableArray alloc] init];
    
    [self initMLImage];
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusAuthorized) {
        //允许
        [self cameraChangePosition:AVCaptureDevicePositionFront];
        [self.session startRunning];
        
    }else{
        //申请权限
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                if (granted) {
                   // 申请权限成功
                } else {
                    // 申请权限失败
                }
            });
        }];
    }
    
}

- (IBAction)clickBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initMLImage {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // Do any additional setup after loading the view from its nib.
        // 方式二：使用自定义参数MLImageSegmentationSetting配置图像分割检测器。
        MLImageSegmentationSetting *setting = [[MLImageSegmentationSetting alloc] init];
        // 设置分割精细模式，YES为精细分割模式，NO为速度优先分割模式。
        [setting setExact:NO];
        // 设置分割模式为人像分割。
        //[setting setAnalyzerType:MLImageSegmentationAnalyzerTypeBody];
        [setting setAnalyzerType:MLImageSegmentationAnalyzerTypeBody];
        
        // 设置返回结果种类。
        // MLImageSegmentationSceneAll: 返回所有分割结果，包括：像素级标记信息、背景透明的人像图和人像为白色，背景为黑色的灰度图以及被分割的原图。
        // MLImageSegmentationSceneMaskOnly: 只返回像素级标记信息。
        // MLImageSegmentationSceneForegroundOnly: 只返回背景透明的人像图。
        // MLImageSegmentationSceneGrayScaleOnly: 只返回人像为白色，背景为黑色的灰度图。
        [setting setScene:MLImageSegmentationSceneForegroundOnly];
        self.analyzer = [MLImageSegmentationAnalyzer sharedInstance];
        [self.analyzer setImageSegmentationAnalyzer:setting];
    });
}

- (void)cameraChangePosition:(AVCaptureDevicePosition)position {
    
    // Judging the direction
    AVCaptureDevice *inputDevice = nil;
    if (position == AVCaptureDevicePositionFront) {
        inputDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionFront];
    } else if (position == AVCaptureDevicePositionBack) {
        inputDevice = [AVCaptureDevice defaultDeviceWithDeviceType:AVCaptureDeviceTypeBuiltInWideAngleCamera mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
    }
    self.inputDevice = inputDevice;
    
    NSLog(@"====当前聚焦值：%f===",self.inputDevice.videoZoomFactor);

    // Device input
    NSError *error = nil;
    AVCaptureDeviceInput *toChangeDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:inputDevice error:&error];
    if (error) {
        NSLog(@"AVCaptureDeviceInput error %@", error);
        return;
    }

    [self.session beginConfiguration];
    // Set input
    [self.session removeInput:self.captureDeviceInput];
    if ([self.session canAddInput:toChangeDeviceInput]) {
        [self.session addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    // Set direction
    AVCaptureConnection *videoConnect = [(AVCaptureVideoDataOutput *)self.session.outputs.firstObject connectionWithMediaType:AVMediaTypeVideo];
    if ([videoConnect isVideoOrientationSupported])
        [videoConnect setVideoOrientation:AVCaptureVideoOrientationPortrait];
    if (position == AVCaptureDevicePositionFront) {
        videoConnect.videoMirrored = YES;
    }
    
    [self.session commitConfiguration];
    
}

//最小缩放值
- (CGFloat)minZoomFactor
{
    CGFloat minZoomFactor = 1.0;
    if (@available(iOS 11.0, *)) {
        minZoomFactor = self.inputDevice.minAvailableVideoZoomFactor;
    }
    return minZoomFactor;
}

//最大缩放值
- (CGFloat)maxZoomFactor
{
    CGFloat maxZoomFactor = self.inputDevice.activeFormat.videoMaxZoomFactor;
    if (@available(iOS 11.0, *)) {
        maxZoomFactor = self.inputDevice.maxAvailableVideoZoomFactor;
    }
    
    if (maxZoomFactor > 6.0) {
        maxZoomFactor = 6.0;
    }
    return maxZoomFactor;
}

- (IBAction)sliderChangeValue:(UISlider *)sender {
    
    if (sender.value < self.maxZoomFactor && sender.value > self.minZoomFactor){
        NSError *error = nil;
        if ([self.inputDevice lockForConfiguration:&error] ) {
            self.inputDevice.videoZoomFactor = sender.value;
            [self.inputDevice unlockForConfiguration];
        }else {
            NSLog( @"Could not lock device for configuration: %@", error );
        }
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output
    didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
           fromConnection:(AVCaptureConnection *)connection {
    
    if (sampleBuffer) {
        [self updatePreviewOverlayViewWithImageBuffer:sampleBuffer];
    } else {
      NSLog(@"%@", @"Failed to get image buffer from sample buffer.");
    }
}

- (void)updatePreviewOverlayViewWithImageBuffer:(CMSampleBufferRef)imageBuffer {
    
    if (imageBuffer == nil) {
        return;
    }
    
    UIImage *image = [self imageConvert:imageBuffer];
    
    MLFrame *mlframeimage = [[MLFrame alloc] initWithImage:image];
    MLImageSegmentation * imagesegmentation = [self.analyzer analyseFrame:mlframeimage];
    UIImage *foregroundImage = [imagesegmentation getForeground];
    
    //[self gpuimageResultImage:foregroundImage];
    LFGPUImageBeautyFilter *defaultBeautifyFilter = [[LFGPUImageBeautyFilter alloc] init];
    foregroundImage = [SCFilterHelper imageWithFilter:defaultBeautifyFilter originImage:foregroundImage];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (foregroundImage!=nil) {
            __weak typeof(self) weakSelf = self;
            [self getzutise:foregroundImage callBack:^(bool isSuccess) {
                
                if (isSuccess) {
                    weakSelf.previewImageView.image = foregroundImage;
                }else{
                    weakSelf.previewImageView.image = image;//[SCFilterHelper imageWithFilter:defaultBeautifyFilter originImage:image];
                }
            }];
        }else{
            self.previewImageView.image = image;
        }
    });
}

- (UIImage *)imageConvert:(CMSampleBufferRef)sampleBuffer {
    
    CVImageBufferRef buffer;
    buffer = CMSampleBufferGetImageBuffer(sampleBuffer);

    CVPixelBufferLockBaseAddress(buffer, 0);
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = (uint8_t *)CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);

    CGColorSpaceRef colorSpace;
    CGContextRef cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);

    CGImageRef cgImage;
    UIImage *image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);

    CVPixelBufferUnlockBaseAddress(buffer, 0);
    
    return image;
}

/**
 *获得图片指定单位像素ARGB值
 */
-(void)getzutise:(UIImage *)fromiamge callBack:(void(^)(bool isSuccess))callBack{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 第一步 先把图片缩小 加快计算速度. 但越小结果误差可能越大
        int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
        CGSize thumbSize = CGSizeMake(40, 40);
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(NULL,thumbSize.width,thumbSize.height, 8, thumbSize.width*4, colorSpace,bitmapInfo);
        CGRect drawRect = CGRectMake(0, 0, thumbSize.width, thumbSize.height);
        CGContextDrawImage(context, drawRect, fromiamge.CGImage);
        CGColorSpaceRelease(colorSpace);
        
        // 第二步 取每个点的像素值
        unsigned char* data = CGBitmapContextGetData (context);
        if (data == NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                callBack(NO);
            });
        };
        NSCountedSet* cls = [NSCountedSet setWithCapacity: thumbSize.width * thumbSize.height];
        for (int x = 0; x < thumbSize.width; x++) {
            for (int y = 0; y < thumbSize.height; y++) {
                int offset = 4 * (x * y);
                int red = data[offset];
                int green = data[offset + 1];
                int blue = data[offset + 2];
                int alpha =  data[offset + 3];
                // 过滤透明的、基本白色、基本黑色
                if (alpha > 0 && (red < 250 && green < 250 && blue < 250) && (red > 5 && green > 5 && blue > 5)) {
                    NSArray *clr = @[@(red),@(green),@(blue),@(alpha)];
                    [cls addObject:clr];
                }
            }
        }
        CGContextRelease(context);
        
        //第三步 找到出现次数最多的那个颜色
        NSEnumerator *enumerator = [cls objectEnumerator];
        NSArray *curColor = nil;
        NSArray *MaxColor = nil;
        NSUInteger MaxCount = 0;
        while ((curColor = [enumerator nextObject]) != nil){
            NSUInteger tmpCount = [cls countForObject:curColor];
            if ( tmpCount < MaxCount ) continue;
            MaxCount = tmpCount;
            MaxColor = curColor;
        }
//        UIColor * subjectColor = [UIColor colorWithRed:([MaxColor[0] intValue]/255.0f) green:([MaxColor[1] intValue]/255.0f) blue:([MaxColor[2] intValue]/255.0f) alpha:([MaxColor[3] intValue]/255.0f)];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"MaxColor[0]===%d",[MaxColor[0] intValue]);
            NSLog(@"MaxColor[1]===%d",[MaxColor[1] intValue]);
            NSLog(@"MaxColor[2]===%d",[MaxColor[2] intValue]);
            NSLog(@"MaxColor[3]===%d",[MaxColor[3] intValue]);
            if ([MaxColor[0] intValue]>0 || [MaxColor[1] intValue]>0 ||[MaxColor[2] intValue]>0 ||[MaxColor[3] intValue]>0) {
                callBack(YES);
            }else{
                callBack(NO);
            }
        });
    });
}

-(UIImage *)gpuimageResultImage:(UIImage *)image{
    
    if (image == nil) {
        return image;
    }
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc]initWithImage:image];
    
    GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
    beautifyFilter.intensity = 0.9;
    [stillImageSource addTarget:beautifyFilter];
    
    [stillImageSource processImage];
    
    UIImage *newImage = [beautifyFilter imageFromCurrentFramebuffer];
    return newImage;
}

@end
