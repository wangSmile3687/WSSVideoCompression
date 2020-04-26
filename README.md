# WSSVideoCompression

[![CI Status](https://img.shields.io/travis/18566663687@163.com/WSSVideoCompression.svg?style=flat)](https://travis-ci.org/18566663687@163.com/WSSVideoCompression)
[![Version](https://img.shields.io/cocoapods/v/WSSVideoCompression.svg?style=flat)](https://cocoapods.org/pods/WSSVideoCompression)
[![License](https://img.shields.io/cocoapods/l/WSSVideoCompression.svg?style=flat)](https://cocoapods.org/pods/WSSVideoCompression)
[![Platform](https://img.shields.io/cocoapods/p/WSSVideoCompression.svg?style=flat)](https://cocoapods.org/pods/WSSVideoCompression)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
  ```
  Video Compression. Thanks to SDAVAssetExportSession.
  
  @property (nonatomic, strong) WSSVideoCompression *videoCompression;


CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
   NSString *videoPath = [self getOutputFilePath];
   self.videoCompression.inputUrl = fileUrl;
   self.videoCompression.outputUrl = [NSURL fileURLWithPath:videoPath];
   [self.videoCompression startCompressionWithCompressionBlock:^(WSSVideoCompressionState state, NSError *error) {
       CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
       NSLog(@"---customCompression---duration----   %f",endTime-startTime);
   }];
   self.videoCompression.compressionProgressBlock = ^(CGFloat progress) {
       NSLog(@"---progress----  %f",progress);
   };


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
  
  ```

## Requirements

## Installation

WSSVideoCompression is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WSSVideoCompression'
```

## Author

wangsi, 17601013687@163.com

## License

WSSVideoCompression is available under the MIT license. See the LICENSE file for more info.
