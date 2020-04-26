//
//  WSSPermissionsManager.h
//  WSSVideoCompression_Example
//
//  Created by smile on 2020/4/26.
//  Copyright © 2020 18566663687@163.com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^PermissionsBlock)(BOOL granted);
@interface WSSPermissionsManager : NSObject
+ (void)checkCameraPermissions:(PermissionsBlock)permissionsBlock;
@end

