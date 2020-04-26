//
//  WSSProgressHUD.m
//  WSSProgressHUD
//
//  Created by smile on 2019/8/22.
//

#import "WSSProgressHUD.h"

#import <MBProgressHUD/MBProgressHUD.h>

typedef NS_ENUM(NSInteger,WSSProgressHUDMode){
    WSSProgressModeHUDOnlyText = 0,             //文字
    WSSProgressModeHUDLoading,                  //加载菊花
    WSSProgressModeHUDCustomerImage,            //自定义图片
};

@interface WSSProgressHUD ()
//@property (nonatomic, strong)   MBProgressHUD   *hud;
@end
@implementation WSSProgressHUD
+ (void)showMessage:(NSString *)msg inView:(UIView *)view {
    [self showMessage:msg inView:view style:WSSProgressModeHUDStyleBlack];
}
+ (void)showMessage:(NSString *)msg inView:(UIView *)view delayTime:(NSTimeInterval)delay {
    [self showMessage:msg inView:view delayTime:delay style:WSSProgressModeHUDStyleBlack];
}
+ (void)showMessageWithInWindow:(NSString *)msg {
    [self showMessageWithInWindow:msg style:WSSProgressModeHUDStyleBlack];
}
+ (void)showMessageWithInWindow:(NSString *)msg delayTime:(NSTimeInterval)delay {
    [self showMessageWithInWindow:msg delayTime:delay style:WSSProgressModeHUDStyleBlack];
}
+ (void)showProgressLoading:(NSString *)msg inView:(UIView *)view {
    [self showProgressLoading:msg inView:view style:WSSProgressModeHUDStyleBlack];
}
+ (void)showCustomImageWithMessage:(NSString *)msg customImage:(UIImage *)customImg inview:(UIView *)view {
    [self showCustomImageWithMessage:msg customImage:customImg inview:view style:WSSProgressModeHUDStyleBlack];
}
+ (void)showCustomAnimationWithMessage:(NSString *)msg withImgArry:(NSArray<UIImage *> *)imgArry inview:(UIView *)view {
    [self showCustomAnimationWithMessage:msg withImgArry:imgArry inview:view style:WSSProgressModeHUDStyleBlack];
}
+ (void)showMessage:(NSString *)msg inView:(UIView *)view style:(WSSProgressHUDStyle)style {
    [self showMessage:msg inView:view delayTime:1.5 customImage:nil mode:WSSProgressModeHUDOnlyText style:style];
}
+ (void)showMessage:(NSString *)msg inView:(UIView *)view delayTime:(NSTimeInterval)delay style:(WSSProgressHUDStyle)style {
    [self showMessage:msg inView:view delayTime:delay customImage:nil mode:WSSProgressModeHUDOnlyText style:style];
}
+ (void)showMessageWithInWindow:(NSString *)msg style:(WSSProgressHUDStyle)style {
    [self showMessage:msg inView:[self applicationWindow] delayTime:1.5 customImage:nil mode:WSSProgressModeHUDOnlyText style:style];
}
+ (void)showMessageWithInWindow:(NSString *)msg delayTime:(NSTimeInterval)delay style:(WSSProgressHUDStyle)style {
    [self showMessage:msg inView:[self applicationWindow] delayTime:delay customImage:nil mode:WSSProgressModeHUDOnlyText style:style];
}
+ (void)showProgressLoading:(NSString *)msg inView:(UIView *)view style:(WSSProgressHUDStyle)style {
    [self showMessage:msg inView:view delayTime:0 customImage:nil mode:WSSProgressModeHUDLoading style:style];
}
+ (void)showCustomImageWithMessage:(NSString *)msg customImage:(UIImage *)customImg inview:(UIView *)view style:(WSSProgressHUDStyle)style {
    UIImageView *customImgView = [[UIImageView alloc] initWithImage:customImg];
    [self showMessage:msg inView:view delayTime:0 customImage:customImgView mode:WSSProgressModeHUDCustomerImage style:style];
}
+ (void)showCustomAnimationWithMessage:(NSString *)msg withImgArry:(NSArray<UIImage *> *)imgArry inview:(UIView *)view style:(WSSProgressHUDStyle)style {
    UIImageView *customImgView = [[UIImageView alloc] init];
    customImgView.animationImages = imgArry;
    [customImgView setAnimationRepeatCount:0];
    [customImgView setAnimationDuration:(imgArry.count + 1) * 0.075];
    [customImgView startAnimating];
    [self showMessage:msg inView:view delayTime:0 customImage:customImgView mode:WSSProgressModeHUDCustomerImage style:style];
}
+ (void)showMessage:(NSString *)msg inView:(UIView *)view delayTime:(NSTimeInterval)delay customImage:(UIImageView *)customImgView mode:(WSSProgressHUDMode)mode style:(WSSProgressHUDStyle)style {
    MBProgressHUD *hud = [self createMBProgressHUDWithMessage:msg inView:view];
    if (style == WSSProgressModeHUDStyleWhite) {
        hud.bezelView.style = MBProgressHUDBackgroundStyleBlur;
        hud.bezelView.blurEffectStyle = UIBlurEffectStyleLight;
        hud.bezelView.color = [UIColor colorWithWhite:0.8f alpha:0.6f];
        hud.contentColor = [UIColor colorWithWhite:0.f alpha:0.7f];
    } else {
        hud.bezelView.color = [UIColor colorWithWhite:0.f alpha:0.8f];
        hud.contentColor = [UIColor whiteColor];
        hud.bezelView.blurEffectStyle = UIBlurEffectStyleLight;
    }
    switch (mode) {
        case WSSProgressModeHUDOnlyText:{
            hud.mode = MBProgressHUDModeText;
            if (delay == 0) {
                delay = 1.5;
            }
            [hud hideAnimated:YES afterDelay:delay];
        }
            break;
        case WSSProgressModeHUDLoading:{
            hud.mode = MBProgressHUDModeIndeterminate;
        }
            break;
        case WSSProgressModeHUDCustomerImage:{
            hud.mode = MBProgressHUDModeCustomView;
            hud.square = YES;
            hud.customView = customImgView;
        }
            break;
        default:
            break;
    }
}
+ (void)hideHUDWithView:(UIView *)view {
    [MBProgressHUD hideHUDForView:view animated:YES];
}
+ (void)hideHUDWithWindow {
    [MBProgressHUD hideHUDForView:(UIView *)[self applicationWindow] animated:YES];
}
+ (MBProgressHUD*)createMBProgressHUDWithMessage:(NSString*)message inView:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (![view isKindOfClass:[UIWindow class]]) {
        hud.userInteractionEnabled = NO;
    }
    hud.detailsLabel.text = message;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
    hud.bezelView.color = [UIColor blackColor];
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}
+ (UIWindow *)applicationWindow {
    UIWindow *applicationWindow;
    if ([[[UIApplication sharedApplication] delegate] respondsToSelector:@selector(window)]) {
        applicationWindow = [[[UIApplication sharedApplication] delegate] window];
    } else {
        applicationWindow = [[UIApplication sharedApplication] keyWindow];
    }
    return applicationWindow;
}
@end
