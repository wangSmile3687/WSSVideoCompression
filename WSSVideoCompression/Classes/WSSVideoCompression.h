//
//  WSSVideoCompression.h
//  WSSVideoCompression
//
//  Created by smile on 2020/4/26.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, WSSVideoResolution) {
    WSSVideoResolutionPreset480x360,     //480*360
    WSSVideoResolutionPreset640x480,     //640*480
    WSSVideoResolutionPreset960x540,     //960*540
    WSSVideoResolutionPreset1280x720,    //1280*720
    WSSVideoResolutionPreset1920x1080,   //1920*1080
};
typedef NS_ENUM(NSInteger, WSSVideoBitRate) {
    WSSVideoBitRateLow,                  // (width*height*3)/4
    WSSVideoBitRateMedium,               // (width*height*3)/2
    WSSVideoBitRateHigh,                 // (width*height*3)
    WSSVideoBitRateSuper,                // (width*height*3)*2
    WSSVideoBitRateSuperHigh,            // (width*height*3)*4
};
typedef struct WSSVideoConfigurations {
    NSInteger fps;// 0~30
    WSSVideoBitRate videoBitRate;
    WSSVideoResolution videoResolution;
}WSSVideoConfigurations;
typedef NS_ENUM(NSInteger, WSSAudioSampleRate) {
    WSSAudioSampleRate8KHz = 8000,
    WSSAudioSampleRate11KHz = 11025,
    WSSAudioSampleRate16KHz = 16000,
    WSSAudioSampleRate22KHz = 22050,
    WSSAudioSampleRate32KHz = 32000,
    WSSAudioSampleRate44KHz = 44100,
    WSSAudioSampleRate48KHz = 48000,
};
typedef NS_ENUM(NSInteger, WSSAudioBitRate) {
    WSSAudioBitRate32Kbps = 32000,
    WSSAudioBitRate64Kbps = 64000,
    WSSAudioBitRate96Kbps = 96000,
    WSSAudioBitRate128Kbps = 128000,
    WSSAudioBitRate192Kbps = 192000,
    WSSAudioBitRate224Kbps = 224000,
};
typedef struct WSSAudioConfigurations {
    WSSAudioSampleRate sampleRate;
    WSSAudioBitRate bitRate;
    NSInteger numOfChannels;//1,2
    NSInteger frameSize; // 8,16,24,32
}WSSAudioConfigurations;
typedef NS_ENUM(NSInteger, WSSVideoCompressionState) {
    WSSVideoCompressionStateUnknown,
    WSSVideoCompressionStateCompressing,
    WSSVideoCompressionStateSuccess,
    WSSVideoCompressionStateFailure,
    WSSVideoCompressionStateCancel,
};
typedef void(^WSSVideoCompressionCompleteBlock)(WSSVideoCompressionState state,NSError *error);
typedef void(^WSSVideoCompressionProgressBlock)(CGFloat progress);
@interface WSSVideoCompression : NSObject
/// 输入地址
@property (nonatomic, strong) NSURL *inputUrl;
/// 输出地址
@property (nonatomic, strong) NSURL *outputUrl;
/// 视频输出类型  默认-AVFileTypeMPEG4
@property (nonatomic, copy) NSString *outputFileType;
/// 压缩进度的回调
@property (nonatomic, copy) WSSVideoCompressionProgressBlock compressionProgressBlock;
/// 初始化
- (instancetype)initWithVideoConfigurations:(WSSVideoConfigurations)videoConfigurations
                        audioConfigurations:(WSSAudioConfigurations)audioConfigurations;
/// 开始压缩
- (void)startCompressionWithCompressionBlock:(WSSVideoCompressionCompleteBlock)compressionCompleteBlock;
/// 取消压缩
- (void)cancelCompression;
@end

