//
//  WSSViewController.m
//  WSSVideoCompression
//
//  Created by 18566663687@163.com on 04/26/2020.
//  Copyright (c) 2020 18566663687@163.com. All rights reserved.
//

#import "WSSViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import <WSSVideoCompression/WSSVideoCompression.h>
#import <WSSProgressHUD/WSSProgressHUD.h>
#import "WSSPermissionsManager.h"

@interface WSSViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) WSSVideoCompression *videoCompression;
@end

@implementation WSSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 200, [UIScreen mainScreen].bounds.size.width-40, 40);
    btn.backgroundColor = [UIColor cyanColor];
    [btn setTitle:@"从相册中获取视频" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}
- (void)btnClick {
    [WSSPermissionsManager checkCameraPermissions:^(BOOL granted) {
           if (granted) {
               dispatch_async(dispatch_get_main_queue(), ^{
                   if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
                       [self presentViewController:self.imagePickerController animated:YES completion:nil];
                   }
               });
           }
       }];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (@available(iOS 11.0, *)) {
        [UIScrollView appearance].contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *fileUrl = info[UIImagePickerControllerMediaURL];
        AVURLAsset *asset = [AVURLAsset assetWithURL:fileUrl];
        CMTime time = asset.duration;
        CGFloat seconds = CMTimeGetSeconds(time);
        if ((NSInteger)seconds > 3*60) {
            [WSSProgressHUD showMessageWithInWindow:@"选择的视频时长不能超过3分钟"];
        } else {
            [self compressedVideoWithFileUrl:fileUrl];
        }
    } else if ([info[UIImagePickerControllerMediaType] isEqualToString:(NSString *)kUTTypeImage]) {
        
    }
}
#pragma mark - private
- (void)compressedVideoWithFileUrl:(NSURL *)fileUrl {
    [WSSProgressHUD showProgressLoading:@"正在压缩视频..." inView:[WSSProgressHUD applicationWindow]];
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    NSString *videoPath = [self getOutputFilePath];
    self.videoCompression.inputUrl = fileUrl;
    self.videoCompression.outputUrl = [NSURL fileURLWithPath:videoPath];
    [self.videoCompression startCompressionWithCompressionBlock:^(WSSVideoCompressionState state, NSError *error) {
        CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
        NSLog(@"---customCompression---duration----   %f",endTime-startTime);
        [WSSProgressHUD hideHUDWithView:[WSSProgressHUD applicationWindow]];
    }];
    self.videoCompression.compressionProgressBlock = ^(CGFloat progress) {
        NSLog(@"---progress----  %f",progress);
    };
}
- (NSString *)getOutputFilePath {
    NSString *tempPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"video"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:tempPath]) {
        [fileManager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [tempPath stringByAppendingPathComponent:[self getCurrentTimestampPath]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    return filePath;
}
- (NSString *)getCurrentTimestampPath {
    return [NSString stringWithFormat:@"atz%ld.mp4",(long)[self getCurrentTimestamp]];
}
- (NSInteger)getCurrentTimestamp {
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval timestamp = [date timeIntervalSince1970];
    return (NSInteger)timestamp;
}
#pragma mark - getter
- (UIImagePickerController *)imagePickerController {
    if (!_imagePickerController) {
        _imagePickerController = [UIImagePickerController new];
        _imagePickerController.delegate = self;
        _imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        _imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    return _imagePickerController;
}
- (WSSVideoCompression *)videoCompression {
    if (!_videoCompression) {
        WSSVideoConfigurations videoConfigurations;
        videoConfigurations.fps = 25;
        videoConfigurations.videoResolution = WSSVideoResolutionPreset640x480;
        videoConfigurations.videoBitRate = WSSVideoBitRateHigh;
        WSSAudioConfigurations audioConfigurations;
        audioConfigurations.sampleRate = WSSAudioSampleRate44KHz;
        audioConfigurations.bitRate = WSSAudioBitRate96Kbps;
        audioConfigurations.numOfChannels = 2;
        audioConfigurations.frameSize = 16;
        _videoCompression = [[WSSVideoCompression alloc] initWithVideoConfigurations:videoConfigurations audioConfigurations:audioConfigurations];
    }
    return _videoCompression;
}
@end
