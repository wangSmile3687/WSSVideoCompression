//
//  WSSPermissionsManager.m
//  WSSVideoCompression_Example
//
//  Created by smile on 2020/4/26.
//  Copyright © 2020 18566663687@163.com. All rights reserved.
//

#import "WSSPermissionsManager.h"
#import <AVFoundation/AVFoundation.h>

@implementation WSSPermissionsManager
+ (void)checkCameraPermissions:(PermissionsBlock)permissionsBlock {
    [self authorizationWithMediaType:AVMediaTypeVideo alertMessage:@"去设置中打开相机权限?" permissionsBlock:permissionsBlock];
}
+ (void)authorizationWithMediaType:(AVMediaType)mediaType alertMessage:(NSString *)alertMessage permissionsBlock:(PermissionsBlock)permissionsBlock {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"权限提醒" message:alertMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *ensureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alert addAction:cancelAction];
        [alert addAction:ensureAction];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        if (permissionsBlock) {
            permissionsBlock(NO);
        }
    } else if (status == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if (permissionsBlock) {
                permissionsBlock(granted);
            }
        }];
    } else {
        if (permissionsBlock) {
            permissionsBlock(YES);
        }
    }
}
@end
