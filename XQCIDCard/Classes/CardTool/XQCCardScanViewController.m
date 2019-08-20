//
//  XQCCardScanViewController.m
//  XQC
//
//  Created by lee on 2019/5/5.
//  Copyright © 2019 xqc. All rights reserved.
//

#import "XQCCardScanViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "excards.h"
#import "exbankcard.h"
#import "RectManager.h"
#import "UIImage+XQCExtend.h"
#import "XQCBankSearch.h"
#import "IDCardSDKHeader.h"
#import "AlertTool.h"
#import "NavView.h"
@interface XQCCardScanViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

//身份证数据模型
@property (nonatomic,strong) XQCCardModel *model;

// 摄像头设备
@property (nonatomic,strong) AVCaptureDevice *device;
// AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
@property (nonatomic,strong) AVCaptureSession *session;
// 输出格式
@property (nonatomic,strong) NSNumber *outPutSetting;
// 出流对象
@property (nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput;
// 元数据（用于人脸识别）
@property (nonatomic,strong) AVCaptureMetadataOutput *metadataOutput;
// 队列
@property (nonatomic,strong) dispatch_queue_t queue;

// 预览图层
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer;
// 人脸检测框区域
@property (nonatomic,assign) CGRect faceDetectionFrame;
// 是否打开手电筒
@property (nonatomic,assign,getter = isTorchOn) BOOL torchOn;
@property (nonatomic,strong) UIButton *rightBtn;

@end

@implementation XQCCardScanViewController

#pragma mark - 检测是模拟器还是真机
#if TARGET_IPHONE_SIMULATOR
// 是模拟器的话，提示“请使用真机测试！！！”
-(void)viewDidLoad {
    [super viewDidLoad];
    
//    self.navigationItem.title = @"扫描";
//    [[XQCAlertTool showAlertTitle:@"模拟器没有摄像设备" message:@"请使用真机测试！！！"] subscribeNext:^(id  _Nullable x) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }];
    NavView *nav = [[NavView alloc] initWithFrame:CGRectMake(0, 0, XQCPHONE_WIDTH, XQCNAVIGATION_BAR_HEIGHT)];
    [self.view addSubview:nav];
    
    nav.click = ^(UIButton * _Nonnull btn) {
        UINavigationController *navigation = self.navigationController;
        if (navigation) {
            [navigation popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
    [AlertTool showTitle:@"模拟器没有摄像设备" Message:@"请使用真机测试！！！" cancleTitle:@"" sureTitle:@"确定" viewController:self cancle:^(UIAlertAction * _Nonnull action) {
        
    } sure:^(UIAlertAction * _Nonnull action) {
        UINavigationController *navigation = self.navigationController;
        if (navigation) {
            [navigation popViewControllerAnimated:YES];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        } 
    }];
}

#else

#pragma mark - 懒加载
#pragma mark device
-(AVCaptureDevice *)device {
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        NSError *error = nil;
        if ([_device lockForConfiguration:&error]) {
            if ([_device isSmoothAutoFocusSupported]) {// 平滑对焦
                _device.smoothAutoFocusEnabled = YES;
            }
            
            if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {// 自动持续对焦
                _device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
            }
            
            if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure ]) {// 自动持续曝光
                _device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            }
            
            if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {// 自动持续白平衡
                _device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
            }
            
            //            NSError *error1;
            //            CMTime frameDuration = CMTimeMake(1, 30); // 默认是1秒30帧
            //            NSArray *supportedFrameRateRanges = [_device.activeFormat videoSupportedFrameRateRanges];
            //            BOOL frameRateSupported = NO;
            //            for (AVFrameRateRange *range in supportedFrameRateRanges) {
            //                if (CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) && CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)) {
            //                    frameRateSupported = YES;
            //                }
            //            }
            //
            //            if (frameRateSupported && [self.device lockForConfiguration:&error1]) {
            //                [_device setActiveVideoMaxFrameDuration:frameDuration];
            //                [_device setActiveVideoMinFrameDuration:frameDuration];
            ////                [self.device unlockForConfiguration];
            //            }
            
            [_device unlockForConfiguration];
        }
    }
    
    return _device;
}

#pragma mark outPutSetting
-(NSNumber *)outPutSetting {
    if (_outPutSetting == nil) {
        _outPutSetting = @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange);
    }
    
    return _outPutSetting;
}

#pragma mark metadataOutput
-(AVCaptureMetadataOutput *)metadataOutput {
    if (_metadataOutput == nil) {
        _metadataOutput = [[AVCaptureMetadataOutput alloc]init];
        [_metadataOutput setMetadataObjectsDelegate:self queue:self.queue];
    }
    
    return _metadataOutput;
}

#pragma mark videoDataOutput
-(AVCaptureVideoDataOutput *)videoDataOutput {
    if (_videoDataOutput == nil) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        _videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
        _videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey:self.outPutSetting};
        
        if (self.cardtype != ScaningCardIDWithFront) {
            [_videoDataOutput setSampleBufferDelegate:self queue:self.queue];
        }
    }
    
    return _videoDataOutput;
}

#pragma mark session
-(AVCaptureSession *)session {
    if (_session == nil) {
        _session = [[AVCaptureSession alloc] init];
        
        _session.sessionPreset = AVCaptureSessionPresetHigh;
        
        // 2、设置输入：由于模拟器没有摄像头，因此最好做一个判断
        NSError *error = nil;
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
        
        if (error) {

        }else {
            if ([_session canAddInput:input]) {
                [_session addInput:input];
            }
            
            if ([_session canAddOutput:self.videoDataOutput]) {
                [_session addOutput:self.videoDataOutput];
            }
            
            if ([_session canAddOutput:self.metadataOutput]) {
                [_session addOutput:self.metadataOutput];
                // 输出格式要放在addOutPut之后，否则奔溃
                self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeFace];
                
            }
        }
    }
    
    return _session;
}

#pragma mark previewLayer
-(AVCaptureVideoPreviewLayer *)previewLayer {
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        
//        _previewLayer.frame = self.view.frame;
        _previewLayer.frame = CGRectMake(0, XQCNAVIGATION_BAR_HEIGHT, XQCPHONE_WIDTH, XQCPHONE_HEIGHT-XQCNAVIGATION_BAR_HEIGHT);
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    return _previewLayer;
}

#pragma mark queue
-(dispatch_queue_t)queue {
    if (_queue == nil) {
        //        _queue = dispatch_queue_create("AVCaptureSession_Start_Running_Queue", DISPATCH_QUEUE_SERIAL);
        _queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    
    return _queue;
}

#pragma mark - 运行session
// session开始，即输入设备和输出设备开始数据传递
- (void)runSession {
    if (![self.session isRunning]) {
        dispatch_async(self.queue, ^{
            [self.session startRunning];
        });
    }
}

#pragma mark - 停止session
// session停止，即输入设备和输出设备结束数据传递
-(void)stopSession {
    if (self.session != nil) {
        if ([self.session isRunning]) {
            dispatch_async(self.queue, ^{
                [self.session stopRunning];
            });
        }
    }
}

#pragma mark - 打开／关闭手电筒
-(void)turnOnOrOffTorch {
    self.torchOn = !self.isTorchOn;
    
    if ([self.device hasTorch]){ // 判断是否有闪光灯
        [self.device lockForConfiguration:nil];// 请求独占访问硬件设备
        
        if (self.isTorchOn) {
            self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"nav_torch_on"];
            [self.device setTorchMode:AVCaptureTorchModeOn];
        } else {
            self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"nav_torch_off"];
            [self.device setTorchMode:AVCaptureTorchModeOff];
        }
        [self.device unlockForConfiguration];// 请求解除独占访问硬件设备
    }else {
        [AlertTool showTitle:@"提示" Message:@"您的设备没有闪光设备，不能提供手电筒功能，请检查" cancleTitle:@"取消" sureTitle:@"确定" viewController:self cancle:^(UIAlertAction * _Nonnull action) {
            
        } sure:^(UIAlertAction * _Nonnull action) {
            
        }];

    }
}

#pragma mark - view即将出现时
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 将AVCaptureViewController的navigationBar调为透明
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:0];
    //    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    // 每次展现AVCaptureViewController的界面时，都检查摄像头使用权限
    [self checkAuthorizationStatus];
    
    // rightBarButtonItem设为原样
    self.torchOn = NO;
    self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"nav_torch_off"];
}

#pragma mark - view即将消失时
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 将AVCaptureViewController的navigationBar调为不透明
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
    //    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    [self stopSession];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.navigationController.title = @"扫描";
    
    NavView *nav = [[NavView alloc] initWithFrame:CGRectMake(0, 0, XQCPHONE_WIDTH, XQCNAVIGATION_BAR_HEIGHT)];
    [self.view addSubview:nav];
    
    nav.click = ^(UIButton * _Nonnull btn) {
        [self goback];
    };
    // 初始化rect
    const char *thePath = [[[NSBundle mainBundle] resourcePath] UTF8String];
    int ret = EXCARDS_Init(thePath);
    if (ret != 0) {
        NSLog(@"初始化失败：ret=%d", ret);
    }
    
    [self addPreviewLayer];
    // 添加关闭按钮
    [self addCloseButton];
    
    // 添加rightBarButtonItem为打开／关闭手电筒
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:nil style:UIBarButtonItemStylePlain target:self action:@selector(turnOnOrOffTorch)];
}


- (void)addPreviewLayer {
    // 添加预览图层
    [self.view.layer addSublayer:self.previewLayer];
    
    // 添加自定义的扫描界面（中间有一个镂空窗口和来回移动的扫描线）
    XQCIDCardScaningView *XQCIDCard = [[XQCIDCardScaningView alloc] initWithFrame:_previewLayer.frame];
    [XQCIDCard scaningCardIDWithType:(self.cardtype)];
    self.faceDetectionFrame = XQCIDCard.facePathRect;
    [self.view addSubview:XQCIDCard];

}

#pragma mark - 添加关闭按钮
-(void)addCloseButton {
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [closeBtn setImage:[UIImage imageNamed:@"idcard_back"] forState:UIControlStateNormal];
    CGFloat closeBtnWidth = 40;
    CGFloat closeBtnHeight = closeBtnWidth;
    CGRect viewFrame = self.view.frame;
    closeBtn.frame = (CGRect){CGRectGetMaxX(viewFrame) - closeBtnWidth, CGRectGetMaxY(viewFrame) - closeBtnHeight, closeBtnWidth, closeBtnHeight};
    
    [closeBtn addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:closeBtn];
}

#pragma mark 绑定“关闭按钮”的方法
-(void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 检测摄像头权限
-(void)checkAuthorizationStatus {
    AVAuthorizationStatus authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    switch (authorizationStatus) {
        case AVAuthorizationStatusNotDetermined:[self showAuthorizationNotDetermined]; break;// 用户尚未决定授权与否，那就请求授权
        case AVAuthorizationStatusAuthorized:[self showAuthorizationAuthorized]; break;// 用户已授权，那就立即使用
        case AVAuthorizationStatusDenied:[self showAuthorizationDenied]; break;// 用户明确地拒绝授权，那就展示提示
        case AVAuthorizationStatusRestricted:[self showAuthorizationRestricted]; break;// 无法访问相机设备，那就展示提示
    }
}

#pragma mark - 相机使用权限处理
#pragma mark 用户还未决定是否授权使用相机
-(void)showAuthorizationNotDetermined {
    __weak __typeof__(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        granted? [weakSelf runSession]: [weakSelf showAuthorizationDenied];
    }];
}

#pragma mark 被授权使用相机
-(void)showAuthorizationAuthorized {
    [self runSession];
}

#pragma mark 未被授权使用相机
-(void)showAuthorizationDenied {
//    NSString *title = @"相机未授权";
//    NSString *message = @"请到系统的“设置-隐私-相机”中授权此应用使用您的相机";
//
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        // 跳转到该应用的隐私设授权置界面
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
//    }];
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
//
//    [self alertControllerWithTitle:title message:message okAction:okAction cancelAction:cancelAction];
    [AlertTool showTitle:@"相机未授权" Message:@"请到系统的“设置-隐私-相机”中授权此应用使用您的相机" cancleTitle:@"取消" sureTitle:@"确定" viewController:self cancle:^(UIAlertAction * _Nonnull action) {
        
    } sure:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
}

#pragma mark 使用相机设备受限
-(void)showAuthorizationRestricted {
//    NSString *title = @"相机设备受限";
//    NSString *message = @"请检查您的手机硬件或设置";
//    
//    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
//    [self alertControllerWithTitle:title message:message okAction:okAction cancelAction:nil];
    [AlertTool showTitle:@"相机未授权" Message:@"请到系统的“设置-隐私-相机”中授权此应用使用您的相机" cancleTitle:@"取消" sureTitle:@"确定" viewController:self cancle:^(UIAlertAction * _Nonnull action) {
        
    } sure:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
#pragma mark 从输出的元数据中捕捉人脸
// 检测人脸是为了获得“人脸区域”，做“人脸区域”与“身份证人像框”的区域对比，当前者在后者范围内的时候，才能截取到完整的身份证图像
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count) {
        AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
        NSLog(@"metadataObjects>>>%@",metadataObjects);
        AVMetadataObject *transformedMetadataObject = [self.previewLayer transformedMetadataObjectForMetadataObject:metadataObject];
        CGRect faceRegion = transformedMetadataObject.bounds;

        if (metadataObject.type == AVMetadataObjectTypeFace) {
            NSLog(@"是否包含头像：%d, facePathRect: %@, faceRegion: %@",CGRectContainsRect(self.faceDetectionFrame, faceRegion),NSStringFromCGRect(self.faceDetectionFrame),NSStringFromCGRect(faceRegion));

            if (CGRectContainsRect(self.faceDetectionFrame, faceRegion)) {// 只有当人脸区域的确在小框内时，才再去做捕获此时的这一帧图像
                // 为videoDataOutput设置代理，程序就会自动调用下面的代理方法，捕获每一帧图像
                if (!self.videoDataOutput.sampleBufferDelegate) {
                    [self.videoDataOutput setSampleBufferDelegate:self queue:self.queue];
                }
            }
        }
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
#pragma mark 从输出的数据流捕捉单一的图像帧
// AVCaptureVideoDataOutput获取实时图像，这个代理方法的回调频率很快，几乎与手机屏幕的刷新频率一样快
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if ([self.outPutSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange]] || [self.outPutSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]]) {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        
        if ([captureOutput isEqual:self.videoDataOutput]) {
            // 身份证信息识别
            if (self.cardtype == ScaningCardIDWithBank) {
                @synchronized(self) {
                    CVBufferRetain(imageBuffer);
                    if(CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
                        [self parseBankImageBuffer:imageBuffer];
                    }
                    CVBufferRelease(imageBuffer);
                }
            }else {
                [self IDCardRecognit:imageBuffer];
            }
            // 身份证信息识别完毕后，就将videoDataOutput的代理去掉，防止频繁调用AVCaptureVideoDataOutputSampleBufferDelegate方法而引起的“混乱”
//            if (self.videoDataOutput.sampleBufferDelegate) {
//                [self.videoDataOutput setSampleBufferDelegate:nil queue:self.queue];
//            }
        }
    } else {
        NSLog(@"输出格式不支持");
    }
}

#pragma mark - 身份证信息识别
- (void)IDCardRecognit:(CVImageBufferRef)imageBuffer {
    CVBufferRetain(imageBuffer);
    
    // Lock the image buffer
    if (CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
        size_t width= CVPixelBufferGetWidth(imageBuffer);// 1920
        size_t height = CVPixelBufferGetHeight(imageBuffer);// 1080
        
        CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
        size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
        size_t rowBytes = NSSwapBigIntToHost(planar->componentInfoY.rowBytes);
        unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
        unsigned char* pixelAddress = baseAddress + offset;
        
        static unsigned char *buffer = NULL;
        if (buffer == NULL) {
            buffer = (unsigned char *)malloc(sizeof(unsigned char) * width * height);
        }
        
        memcpy(buffer, pixelAddress, sizeof(unsigned char) * width * height);
        
        unsigned char pResult[1024];
        int ret = EXCARDS_RecoIDCardData(buffer, (int)width, (int)height, (int)rowBytes, (int)8, (char*)pResult, sizeof(pResult));
        if (ret <= 0) {
            NSLog(@"ret=[%d]", ret);
        } else {
            NSLog(@"ok---ret=[%d]", ret);
            
            // 播放一下“拍照”的声音，模拟拍照
            AudioServicesPlaySystemSound(1108);
            
            if ([self.session isRunning]) {
                [self.session stopRunning];
            }
            
            char ctype;
            char content[256];
            int xlen;
            int i = 0;
            
            XQCCardModel *model = [[XQCCardModel alloc] init];
            
            ctype = pResult[i++];
            
            
            model.type = ctype;
            
            NSLog(@"ctype====%c",model.type);
            
            while(i < ret){
                ctype = pResult[i++];
                for(xlen = 0; i < ret; ++i){
                    if(pResult[i] == ' ') { ++i; break; }
                    content[xlen++] = pResult[i];
                }
                
                content[xlen] = 0;
                
                if(xlen) {
                    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                    if(ctype == 0x21) {
                        model.code = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x22) {
                        model.name = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x23) {
                        model.gender = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x24) {
                        model.nation = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x25) {
                        model.address = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x26) {
                        model.issue = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    } else if(ctype == 0x27) {
                        model.valid = [NSString stringWithCString:(char *)content encoding:gbkEncoding];
                    }
                }
            }
            
            if (model) {// 读取到身份证信息，实例化出IDInfo对象后，截取身份证的有效区域，获取到图像
//                NSLog(@"\n正面\n姓名：%@\n性别：%@\n民族：%@\n住址：%@\n公民身份证号码：%@\n\n反面\n签发机关：%@\n有效期限：%@",iDInfo.name,iDInfo.gender,iDInfo.nation,iDInfo.address,iDInfo.code,iDInfo.issue,iDInfo.valid);
                NSLog(@"model?>>>>>>>>%@",model);
                if (self.cardtype == ScaningCardIDWithDown) {
                    if (model.name != nil && ![model.name isEqualToString:@""] ) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [AlertTool showTitle:@"" Message:@"请切换身份证背面" cancleTitle:@"" sureTitle:@"确定" viewController:self cancle:^(UIAlertAction * _Nonnull action) {
                                
                            } sure:^(UIAlertAction * _Nonnull action) {
                                [self runSession];
                            }];
                        });
                        return;
                    }
                }
                CGRect effectRect = [RectManager getEffectImageRect:CGSizeMake(width, height)];
                CGRect rect = [RectManager getGuideFrame:effectRect];
                
                UIImage *image = [UIImage getImageStream:imageBuffer];
                UIImage *subImage = [UIImage getSubImage:rect inImage:image];
                model.idImage = subImage;
                if (self.complete) {
                    self.complete(model);
                }
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self goback];
                });
            }
        }
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    }
    
    CVBufferRelease(imageBuffer);
}

#pragma mark - 银行卡信息识别
- (void)parseBankImageBuffer:(CVImageBufferRef)imageBuffer {
    size_t width_t= CVPixelBufferGetWidth(imageBuffer);
    size_t height_t = CVPixelBufferGetHeight(imageBuffer);
    CVPlanarPixelBufferInfo_YCbCrBiPlanar *planar = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t offset = NSSwapBigIntToHost(planar->componentInfoY.offset);
    
    unsigned char* baseAddress = (unsigned char *)CVPixelBufferGetBaseAddress(imageBuffer);
    unsigned char* pixelAddress = baseAddress + offset;
    
    size_t cbCrOffset = NSSwapBigIntToHost(planar->componentInfoCbCr.offset);
    uint8_t *cbCrBuffer = baseAddress + cbCrOffset;
    
    CGSize size = CGSizeMake(width_t, height_t);
    CGRect effectRect = [RectManager getEffectImageRect:size];
    CGRect rect = [RectManager getGuideFrame:effectRect];
    
    int width = ceilf(width_t);
    int height = ceilf(height_t);
    
    unsigned char result [512];
    int resultLen = BankCardNV12(result, 512, pixelAddress, cbCrBuffer, width, height, rect.origin.x, rect.origin.y, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
    
    if(resultLen > 0) {
        
        int charCount = [RectManager docode:result len:resultLen];
        if(charCount > 0) {
            CGRect subRect = [RectManager getCorpCardRect:width height:height guideRect:rect charCount:charCount];
            UIImage *image = [UIImage getImageStream:imageBuffer];
            __block UIImage *subImg = [UIImage getSubImage:subRect inImage:image];
            
            char *numbers = [RectManager getNumbers];
            
            NSString *numberStr = [NSString stringWithCString:numbers encoding:NSASCIIStringEncoding];
            NSString *bank = [XQCBankSearch getBankNameByBin:numbers count:charCount];
            
            NSLog(@"numberStr%@",numberStr);
            NSLog(@"bank%@",bank);
            //            NSLog(@"%@",)
            
            XQCCardModel *model = [XQCCardModel new];
            
            model.bankNumber = numberStr;
            model.bankName = bank;
            model.bankImage = subImg;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                if (self.complete) {
                    self.complete(model);
                }
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self goback];
                });
            });
        }
    }
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
}

- (void)goback {
    UINavigationController *navigation = self.navigationController;
    if (navigation) {
        [navigation popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#endif

@end
