//
//  ViewController.m
//  VideoToolBoxExp
//
//  Created by 姜泽东 on 2017/11/22.
//  Copyright © 2017年 MaiTian. All rights reserved.
//  只支持iOS10_0以后

#import "ViewController.h"
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVFoundation.h>

static NSString * const videoUrl =
@"http://play.g3proxy.lecloud.com/vod/v2/MTk1LzI5LzExMC9sZXR2LXV0cy8xNC92ZXJfMDBfMjItMTAzNjU0NzA5NS1hdmMtMzg0MjE2LWFhYy0zMjAwMC0yOTYwMjQ4LTE1NzU0OTU0My05YzQzNzEyOGZjMTk4ZTYwYjBlMWQ3MjY2Njg3NjU2ZS0xNDYwMDg4NTk0MzYyLm1wNA==?b=425&mmsid=51338425&tm=1464600702&key=479f9a6f02032998f3d30b0e751610b5&platid=3&splatid=355&playid=0&tss=ios&vtype=13&cvid=3528594867&payff=0&pip=28ca774f67782e24a64ddbfdb9e43292";

@interface ViewController ()<AVCapturePhotoCaptureDelegate,AVCaptureVideoDataOutputSampleBufferDelegate>
{
    
    CALayer *_customPreviewLayer;
    UIImageView *_imgView;
}
@property (nonatomic,assign) BOOL isFlash;

@property (nonatomic,strong) AVCaptureSession *session;
/** iOS10_0*/
@property (nonatomic,strong) AVCaptureDeviceDiscoverySession *discoverySession;

@property (nonatomic,strong) AVCaptureInput *cinput;
/** 为’AVCaptureSession‘提供媒体数据与系统连接的设备的输入源*/
@property (nonatomic,strong) AVCaptureDeviceInput *input;
/** iOS10_0*/
@property (nonatomic,strong) AVCapturePhotoOutput *photoOutPut;
@property (nonatomic,strong) AVCaptureVideoDataOutput *videoOutPut;

@property (nonatomic,strong) AVCaptureDevice *device;

@property (nonatomic,strong) AVCaptureVideoPreviewLayer *videoCaptureLayer;

@property (nonatomic,strong) AVCapturePhotoSettings *settings;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //输入
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    //输出
    if ([self.session canAddOutput:self.photoOutPut]) {
        [self.session addOutput:self.photoOutPut];
    }
    
    
    [self.view.layer insertSublayer:self.videoCaptureLayer atIndex:0];
    
    
    AVCapturePhotoSettings *setting = [AVCapturePhotoSettings photoSettings];
    //闪光灯状态在此处设置
    if (self.isFlash) {
        setting.flashMode = AVCaptureFlashModeOn;
    }else{
        setting.flashMode = AVCaptureFlashModeOff;
    }
    
    if (@available(iOS 11.0, *)) {
        setting.livePhotoVideoCodecType = AVVideoCodecTypeH264;
    } else {
        
    }
    
    [self.photoOutPut capturePhotoWithSettings:setting delegate:self];
    
    self.videoOutPut.videoSettings =
    [NSDictionary dictionaryWithObject:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                                                forKey:(NSString *)kCVPixelBufferPixelFormatTypeKey];
    
    [self.videoOutPut setAlwaysDiscardsLateVideoFrames:YES];
    
    [self.videoOutPut setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    
    
    [self.session startRunning];
    
    
    _customPreviewLayer = [CALayer new];
    _customPreviewLayer.frame = CGRectMake(10, 310, 300, 300);
//    [self.view.layer addSublayer:_customPreviewLayer];
    
    _imgView = [UIImageView new];
    _imgView.frame = CGRectMake(10, 310, 300, 300);
    [self.view addSubview:_imgView];
}

#pragma mark -- button Action

- (IBAction)front:(UIButton *)sender {
    
}

- (IBAction)back:(UIButton *)sender {
    
    
}

- (IBAction)takePhoto:(UIButton *)sender {
    
    AVCaptureConnection *captureConnection = [self.photoOutPut connectionWithMediaType:AVMediaTypeVideo];
    if (!captureConnection) {
        NSLog(@"拍照失败");
    }
}

- (IBAction)takeVideo:(UIButton *)sender {
    
    
    if ([self.session canAddOutput:self.videoOutPut]) {
        [self.session addOutput:self.videoOutPut];
    }else{
        [self.session removeOutput:self.photoOutPut];
        [self.session addOutput:self.videoOutPut];
    }
    AVCaptureConnection *videoConnection = [self.videoOutPut connectionWithMediaType:AVMediaTypeAudio];
    if (!videoConnection) {
        NSLog(@"录像错误");
    }

}

#pragma mark -- AVCapturePhotoCaptureDelegate
/** iOS10*/
- (void)captureOutput:(AVCapturePhotoOutput *)output
didFinishProcessingPhotoSampleBuffer:(nullable CMSampleBufferRef)photoSampleBuffer
            previewPhotoSampleBuffer:(nullable CMSampleBufferRef)previewPhotoSampleBuffer
                    resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
                     bracketSettings:(nullable AVCaptureBracketedStillImageSettings *)bracketSettings
                               error:(nullable NSError *)error
{
    
    NSData *imageData = [AVCapturePhotoOutput JPEGPhotoDataRepresentationForJPEGSampleBuffer:photoSampleBuffer
                                                                     previewPhotoSampleBuffer:previewPhotoSampleBuffer];
    
    UIImage *image = [UIImage imageWithData:imageData];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
}

/** NS_AVAILABLE_IOS(11.0) 去掉只支持iOS11的警告*/
- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error NS_AVAILABLE_IOS(11.0)
{
    NSData *data = [photo fileDataRepresentation];
    UIImage *image = [UIImage imageWithData:data];
    
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishRecordingLivePhotoMovieForEventualFileAtURL:(NSURL *)outputFileURL resolvedSettings:(AVCaptureResolvedPhotoSettings *)resolvedSettings
{
    
    
}

#pragma mark -- AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"录像啦");
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    size_t width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0);
    size_t height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0);
    //视频缓冲区中是YUV格式的,要从缓冲区中提取luma部分
    uint8_t *lumaBuffer = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);

    CGColorSpaceRef grayColorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate(lumaBuffer, width, height, 8, bytesPerRow, grayColorSpace, kCGImageAlphaNone);

    CGImageRef dstImage = CGBitmapContextCreateImage(context);

    // 解锁pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    UIImage *image = [UIImage imageWithCGImage:dstImage scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp*3];
    _imgView.image = image;
//    NSLog(@"%@",image);
//    _customPreviewLayer.contents = (__bridge id _Nullable)(image.CGImage);
    
    CGImageRelease(dstImage);
    CGContextRelease(context);
    CGColorSpaceRelease(grayColorSpace);
}

- (void)captureOutput:(AVCaptureOutput *)output didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    NSLog(@"录像le啦");
}


#pragma mark -- getters

- (AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureDevice *)device
{
    if (!_device) {
        AVCaptureDeviceDiscoverySession *discoverySession =
        [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera]
                                                               mediaType:AVMediaTypeVideo
                                                                position:AVCaptureDevicePositionBack];
        
        if (discoverySession.devices.count > 0) {
            _device = discoverySession.devices.firstObject;
        }
    }
    return _device;
}

- (AVCaptureDeviceInput *)input
{
    if (!_input) {
        NSError *error = nil;
        _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
        if (error) {
            NSLog(@"获取设备输入错误");
            return nil;
        }
    }
    return _input;
}

- (AVCapturePhotoOutput *)photoOutPut
{
    if (!_photoOutPut) {
        _photoOutPut = [[AVCapturePhotoOutput alloc] init];
    }
    return _photoOutPut;
}

- (AVCaptureVideoPreviewLayer *)videoCaptureLayer
{
    
    if (!_videoCaptureLayer) {
        _videoCaptureLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _videoCaptureLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, 300);
        _videoCaptureLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _videoCaptureLayer;
}

- (AVCapturePhotoSettings *)settings
{
    if (!_settings) {
        _settings = [AVCapturePhotoSettings photoSettings];
    }
    return _settings;
}

- (AVCaptureVideoDataOutput *)videoOutPut
{
    if (!_videoOutPut) {
        _videoOutPut = [[AVCaptureVideoDataOutput alloc] init];
    }
    return _videoOutPut;
}

@end
