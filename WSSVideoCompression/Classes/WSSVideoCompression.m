//
//  WSSVideoCompression.m
//  WSSVideoCompression
//
//  Created by smile on 2020/4/26.
//

#import "WSSVideoCompression.h"
#import <AVFoundation/AVFoundation.h>

@interface WSSVideoCompression ()
@property (nonatomic, assign) WSSVideoConfigurations videoConfigurations;
@property (nonatomic, assign) WSSAudioConfigurations audioConfigurations;
@property (nonatomic, assign) CGFloat targetWidth;
@property (nonatomic, assign) CGFloat targetHeight;
@property (nonatomic, strong) AVAsset *asset;
@property (nonatomic, strong) AVAssetReader *reader;
@property (nonatomic, strong) AVAssetReaderVideoCompositionOutput *videoOutput;
@property (nonatomic, strong) AVAssetReaderAudioMixOutput *audioOutput;
@property (nonatomic, strong) AVAssetWriter *writer;
@property (nonatomic, strong) AVAssetWriterInput *videoInput;
@property (nonatomic, strong) AVAssetWriterInput *audioInput;
@property (nonatomic, strong) dispatch_queue_t inputQueue;
@property (nonatomic, assign) CMTimeRange timeRange;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CMTime lastSamplePresentationTime;
@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, copy) WSSVideoCompressionCompleteBlock compressionCompleteBlock;
@property (nonatomic, assign) WSSVideoCompressionState status;
@property (nonatomic, strong) NSError *error;
@end
@implementation WSSVideoCompression
- (instancetype)initWithVideoConfigurations:(WSSVideoConfigurations)videoConfigurations audioConfigurations:(WSSAudioConfigurations)audioConfigurations {
    if (self = [super init]) {
        self.videoConfigurations = videoConfigurations;
        self.audioConfigurations = audioConfigurations;
        self.timeRange = CMTimeRangeMake(kCMTimeZero, kCMTimePositiveInfinity);
        self.outputFileType = AVFileTypeMPEG4;
        [self getTargetWidthAndTargetHeight];
    }
    return self;
}
- (void)dealloc {
    NSLog(@"---dealloc---UCVideoCompression-------");
}
/// 开始压缩
- (void)startCompressionWithCompressionBlock:(WSSVideoCompressionCompleteBlock)compressionCompleteBlock {
    [self cancelCompression];
    self.compressionCompleteBlock = compressionCompleteBlock;
    if (self.inputUrl && self.outputUrl) {
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.inputUrl options:nil];
        self.asset = asset;
        NSError *readerError;
        self.reader = [AVAssetReader assetReaderWithAsset:self.asset error:&readerError];
        if (readerError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.compressionCompleteBlock) {
                    self.compressionCompleteBlock(WSSVideoCompressionStateFailure,readerError);
                }
            });
            return;
        }
        NSError *writerError;
        self.writer = [AVAssetWriter assetWriterWithURL:self.outputUrl fileType:self.outputFileType error:&writerError];
        if (writerError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.compressionCompleteBlock) {
                    self.compressionCompleteBlock(WSSVideoCompressionStateFailure,writerError);
                }
            });
            return;
        }
        
        self.reader.timeRange = self.timeRange;
        self.writer.shouldOptimizeForNetworkUse = YES;
        
        if (CMTIME_IS_VALID(self.timeRange.duration) && !CMTIME_IS_POSITIVE_INFINITY(self.timeRange.duration)) {
            self.duration = CMTimeGetSeconds(self.timeRange.duration);
        } else {
            self.duration = CMTimeGetSeconds(self.asset.duration);
        }
        
        /// 视频轨道
        NSArray *videoTracks = [self.asset tracksWithMediaType:AVMediaTypeVideo];
        if (videoTracks.count > 0) {
            AVAssetTrack *videoTrack = videoTracks.firstObject;
            NSDictionary *videoInputSetting = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
            self.videoOutput = [AVAssetReaderVideoCompositionOutput assetReaderVideoCompositionOutputWithVideoTracks:videoTracks videoSettings:videoInputSetting];
            self.videoOutput.alwaysCopiesSampleData = NO;
            self.videoOutput.videoComposition = [self configurationDefaultVideoCompositionWithVideoTrack:videoTrack];
            
            if ([self.reader canAddOutput:self.videoOutput]) {
                [self.reader addOutput:self.videoOutput];
            }
            CGFloat estimatedDataRate = videoTrack.estimatedDataRate;
            self.videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:    [self getVideoOutputSettingsWithEstimatedDataRate:estimatedDataRate]];
            self.videoInput.expectsMediaDataInRealTime = NO;
            if ([self.writer canAddInput:self.videoInput]) {
                [self.writer addInput:self.videoInput];
            }
        }
        
        /// 音频轨道
        NSArray *audioTracks = [self.asset tracksWithMediaType:AVMediaTypeAudio];
        if (audioTracks.count > 0) {
            self.audioOutput = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:audioTracks audioSettings:nil];
            self.audioOutput.alwaysCopiesSampleData = NO;
            if ([self.reader canAddOutput:self.audioOutput]) {
                [self.reader addOutput:self.audioOutput];
            }
        } else {
            self.audioOutput = nil;
        }
        if (self.audioOutput) {
            self.audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:[self getAudioOutputSettings]];
            self.audioInput.expectsMediaDataInRealTime = NO;
            if ([self.writer canAddInput:self.audioInput]) {
                [self.writer addInput:self.audioInput];
            }
        }
        
        [self.reader startReading];
        [self.writer startWriting];
        [self.writer startSessionAtSourceTime:self.timeRange.start];
        
        
        __block BOOL videoCompleted = NO;
        __block BOOL audioCompleted = NO;
        __weak typeof(self) weakSelf = self;
        self.inputQueue = dispatch_queue_create("VideoCompressionInputQueue", DISPATCH_QUEUE_SERIAL);
        if (videoTracks.count > 0) {
            [self.videoInput requestMediaDataWhenReadyOnQueue:self.inputQueue usingBlock:^{
                if (![weakSelf encodeReadySamplesFromOutput:weakSelf.videoOutput toInput:weakSelf.videoInput]) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    @synchronized(strongSelf) {
                        videoCompleted = YES;
                        if (audioCompleted) {
                            [strongSelf finish];
                        }
                    }
                }
            }];
        } else {
            videoCompleted = YES;
        }
        if (!self.audioOutput) {
            audioCompleted = YES;
        } else {
            [self.audioInput requestMediaDataWhenReadyOnQueue:self.inputQueue usingBlock:^{
                if (![weakSelf encodeReadySamplesFromOutput:weakSelf.audioOutput toInput:weakSelf.audioInput]) {
                    __strong typeof(weakSelf) strongSelf = weakSelf;
                    @synchronized(strongSelf) {
                        audioCompleted = YES;
                        if (videoCompleted) {
                            [strongSelf finish];
                        }
                    }
                }
            }];
        }
    } else {
        NSError *error = [NSError errorWithDomain:AVFoundationErrorDomain code:AVErrorExportFailed userInfo:@{NSLocalizedDescriptionKey:@"Input or Output URL not set"}];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.compressionCompleteBlock) {
                self.compressionCompleteBlock(WSSVideoCompressionStateFailure,error);
            }
        });
    }
}
/// 取消压缩
- (void)cancelCompression {
    if (self.inputQueue) {
        [self.writer cancelWriting];
        [self.reader cancelReading];
        [self reset];
    }
}
#pragma mark - private method
/// 获取默认配置的VideoComposition
- (AVMutableVideoComposition *)configurationDefaultVideoCompositionWithVideoTrack:(AVAssetTrack *)videoTrack {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    CGFloat trackFrameRate = 0.0;
    if (self.videoConfigurations.fps > 0) {
        trackFrameRate = self.videoConfigurations.fps;
    } else {
        trackFrameRate = videoTrack.nominalFrameRate;
    }
    if (trackFrameRate == 0) {
        trackFrameRate = 30;
    }
    videoComposition.frameDuration = CMTimeMake(1, trackFrameRate);
    CGSize naturalSize = [videoTrack naturalSize];
    CGAffineTransform transform = videoTrack.preferredTransform;
    CGRect rect = {{0, 0}, naturalSize};
    CGRect transformedRect = CGRectApplyAffineTransform(rect, transform);
    transform.tx -= transformedRect.origin.x;
    transform.ty -= transformedRect.origin.y;
    if (transform.ty == -560) {
        transform.ty = 0;
    }
    if (transform.tx == -560) {
        transform.tx = 0;
    }
    CGFloat videoAngleInDegree  = atan2(transform.b, transform.a) * 180 / M_PI;
    if (videoAngleInDegree == 90 || videoAngleInDegree == -90) {
        CGFloat width = naturalSize.width;
        naturalSize.width = naturalSize.height;
        naturalSize.height = width;
    }
    videoComposition.renderSize = naturalSize;
    if (naturalSize.height * naturalSize.width < self.targetWidth * self.targetHeight) {
        self.targetHeight = naturalSize.height;
        self.targetWidth = naturalSize.width;
    } else {
        self.targetWidth = self.targetHeight * naturalSize.width / naturalSize.height;
    }
    AVMutableVideoCompositionInstruction *passThroughInstruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    passThroughInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, self.asset.duration);
    AVMutableVideoCompositionLayerInstruction *passThroughLayer = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:videoTrack];
    [passThroughLayer setTransform:transform atTime:kCMTimeZero];
    passThroughInstruction.layerInstructions = @[passThroughLayer];
    videoComposition.instructions = @[passThroughInstruction];
    return videoComposition;
}
/// 获取视频输出配置
- (NSMutableDictionary *)getVideoOutputSettingsWithEstimatedDataRate:(CGFloat)estimatedDataRate {
    NSMutableDictionary *videoOutputSettings = [NSMutableDictionary new];
    if (@available(iOS 11.0, *)) {
        videoOutputSettings[AVVideoCodecKey] = AVVideoCodecTypeH264;
    } else {
        videoOutputSettings[AVVideoCodecKey] = AVVideoCodecH264;
    }
    videoOutputSettings[AVVideoWidthKey] = @(self.targetWidth);
    videoOutputSettings[AVVideoHeightKey] = @(self.targetHeight);
    
    NSMutableDictionary *propertiesParams= [NSMutableDictionary new];
    propertiesParams[AVVideoAverageNonDroppableFrameRateKey] = @(self.videoConfigurations.fps);
    propertiesParams[AVVideoProfileLevelKey] = AVVideoProfileLevelH264HighAutoLevel;
    CGFloat configurationsBitRate = [self getVideoConfigurationsBitRate];
    if (estimatedDataRate > configurationsBitRate) {
        propertiesParams[AVVideoAverageBitRateKey] = @(configurationsBitRate);
    }
    videoOutputSettings[AVVideoCompressionPropertiesKey] = propertiesParams;
    NSLog(@"---estimatedDataRate----  %f,----configurationsBitRate----  %f",estimatedDataRate,configurationsBitRate);
    return videoOutputSettings;
}
/// 获取音频输出配置
- (NSMutableDictionary *)getAudioOutputSettings {
    NSMutableDictionary *audioOutputSettings = [NSMutableDictionary new];
    audioOutputSettings[AVFormatIDKey] = @(kAudioFormatMPEG4AAC);
    audioOutputSettings[AVNumberOfChannelsKey] = @(self.audioConfigurations.numOfChannels);
    audioOutputSettings[AVSampleRateKey] = @(self.audioConfigurations.sampleRate);
    audioOutputSettings[AVEncoderBitRateKey] = @(self.audioConfigurations.bitRate);
    return audioOutputSettings;
}
/// 获取目标尺寸
- (void)getTargetWidthAndTargetHeight {
    switch (self.videoConfigurations.videoResolution) {
        case WSSVideoResolutionPreset480x360:{
            self.targetHeight = 480;
            self.targetWidth = 360;
        }
            break;
        case WSSVideoResolutionPreset640x480:{
            self.targetHeight = 640;
            self.targetWidth = 480;
        }
            break;
        case WSSVideoResolutionPreset960x540:{
            self.targetHeight = 960;
            self.targetWidth = 540;
        }
            break;
        case WSSVideoResolutionPreset1280x720:{
            self.targetHeight = 1280;
            self.targetWidth = 720;
        }
            break;
        case WSSVideoResolutionPreset1920x1080:{
            self.targetHeight = 1920;
            self.targetWidth = 1080;
        }
            break;
        default:
            break;
    }
}
/// 获取videoBitRate
- (CGFloat)getVideoConfigurationsBitRate {
    CGFloat bitRate = [self calculateBitRateWithWidth:self.targetWidth height:self.targetHeight];
    return bitRate;
}
/// 计算videoBitRate
- (CGFloat)calculateBitRateWithWidth:(CGFloat)width height:(CGFloat)height {
    CGFloat bitRate = 0.0;
    switch (self.videoConfigurations.videoBitRate) {
        case WSSVideoBitRateLow:{
            bitRate = (width * height * 3) / 4;
        }
            break;
        case WSSVideoBitRateMedium:{
            bitRate = (width * height * 3) / 2;
        }
            break;
        case WSSVideoBitRateHigh:{
            bitRate = (width * height * 3) ;
        }
            break;
        case WSSVideoBitRateSuper:{
            bitRate = (width * height * 3) * 2;
        }
            break;
        case WSSVideoBitRateSuperHigh:{
            bitRate = (width * height * 3) * 4;
        }
            break;
        default:
            break;
    }
    return bitRate;
}
- (BOOL)encodeReadySamplesFromOutput:(AVAssetReaderOutput *)output toInput:(AVAssetWriterInput *)input {
    while (input.isReadyForMoreMediaData) {
        CMSampleBufferRef sampleBuffer = [output copyNextSampleBuffer];
        if (sampleBuffer) {
            BOOL handled = NO;
            BOOL error = NO;
            if (self.reader.status != AVAssetReaderStatusReading || self.writer.status != AVAssetWriterStatusWriting) {
                handled = YES;
                error = YES;
            }
            if (!handled && self.videoOutput == output) {
                self.lastSamplePresentationTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                self.lastSamplePresentationTime = CMTimeSubtract(self.lastSamplePresentationTime, self.timeRange.start);
                self.progress = self.duration == 0 ? 1 : CMTimeGetSeconds(self.lastSamplePresentationTime) / self.duration;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.compressionProgressBlock) {
                        self.compressionProgressBlock(self.progress);
                    }
                });
            }
            if (!handled && ![input appendSampleBuffer:sampleBuffer]) {
                error = YES;
            }
            CFRelease(sampleBuffer);
            if (error) {
                return NO;
            }
        } else {
            [input markAsFinished];
            if (self.reader.status == AVAssetReaderStatusCompleted) {
                self.progress = 1.0;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.compressionProgressBlock) {
                    self.compressionProgressBlock(self.progress);
                }
            });
            return NO;
        }
    }
    return YES;
}
- (void)finish {
    if (self.reader.status == AVAssetReaderStatusCancelled || self.writer.status == AVAssetWriterStatusCancelled) {
        return;
    }
    if (self.writer.status == AVAssetWriterStatusFailed) {
        [self complete];
    } else if (self.reader.status == AVAssetReaderStatusFailed) {
        [self.writer cancelWriting];
        [self complete];
    } else {
        __weak typeof(self) weakSelf = self;
        [self.writer finishWritingWithCompletionHandler:^{
            [weakSelf complete];
        }];
    }
}
- (void)complete {
    if (self.writer.status == AVAssetWriterStatusFailed || self.writer.status == AVAssetWriterStatusCancelled) {
        [NSFileManager.defaultManager removeItemAtURL:self.outputUrl error:nil];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.compressionCompleteBlock) {
            self.compressionCompleteBlock([self status], self.error);
        }
    });
}
- (void)reset {
    _error = nil;
    self.progress = 0;
    self.reader = nil;
    self.videoOutput = nil;
    self.audioOutput = nil;
    self.writer = nil;
    self.videoInput = nil;
    self.audioInput = nil;
    self.inputQueue = nil;
    self.compressionCompleteBlock = nil;
}
#pragma mark - getter
- (WSSVideoCompressionState)status {
    switch (self.writer.status) {
        case AVAssetWriterStatusUnknown:
            return WSSVideoCompressionStateUnknown;
            break;
        case AVAssetWriterStatusWriting:
            return WSSVideoCompressionStateCompressing;
            break;
        case AVAssetWriterStatusFailed:
            return WSSVideoCompressionStateFailure;
            break;
        case AVAssetWriterStatusCompleted:
            return WSSVideoCompressionStateSuccess;
            break;
        case AVAssetWriterStatusCancelled:
            return WSSVideoCompressionStateCancel;
            break;
        default:
            return WSSVideoCompressionStateUnknown;
            break;
    }
}
- (NSError *)error {
    return self.writer.error ? : self.reader.error;
}
@end
