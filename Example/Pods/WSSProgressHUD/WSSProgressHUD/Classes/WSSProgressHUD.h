//
//  WSSProgressHUD.h
//  WSSProgressHUD
//
//  Created by smile on 2019/8/22.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,WSSProgressHUDStyle){
    WSSProgressModeHUDStyleBlack = 0,       //黑底白字
    WSSProgressModeHUDStyleWhite,           //白底黑字
};
@interface WSSProgressHUD : NSObject
/** 显示提示（1.5秒后消失 默认黑底白字） */
+ (void)showMessage:(NSString *)msg inView:(UIView *)view;
/** 显示提示（N秒后消失 默认黑底白字） */
+ (void)showMessage:(NSString *)msg inView:(UIView *)view delayTime:(NSTimeInterval)delay;
/** window显示（1.5秒后消失 默认黑底白字）*/
+ (void)showMessageWithInWindow:(NSString *)msg;
/** window显示（N秒后消失 默认黑底白字）*/
+ (void)showMessageWithInWindow:(NSString *)msg delayTime:(NSTimeInterval)delay;
/** 显示进度(菊花 默认黑底白字) */
+ (void)showProgressLoading:(NSString *)msg inView:(UIView *)view;
/** 显示图片 默认黑底白字 */
+ (void)showCustomImageWithMessage:(NSString *)msg customImage:(UIImage *)customImg inview:(UIView *)view;
/** 显示自定义动画 默认黑底白字 */
+ (void)showCustomAnimationWithMessage:(NSString *)msg withImgArry:(NSArray<UIImage *> *)imgArry inview:(UIView *)view;
/** 显示提示（1.5秒后消失） */
+ (void)showMessage:(NSString *)msg inView:(UIView *)view style:(WSSProgressHUDStyle)style;
/** 显示提示（N秒后消失） */
+ (void)showMessage:(NSString *)msg inView:(UIView *)view delayTime:(NSTimeInterval)delay style:(WSSProgressHUDStyle)style;
/** window显示（1.5秒后消失）*/
+ (void)showMessageWithInWindow:(NSString *)msg style:(WSSProgressHUDStyle)style;
/** window显示（N秒后消失）*/
+ (void)showMessageWithInWindow:(NSString *)msg delayTime:(NSTimeInterval)delay style:(WSSProgressHUDStyle)style;
/** 显示进度(菊花) */
+ (void)showProgressLoading:(NSString *)msg inView:(UIView *)view style:(WSSProgressHUDStyle)style;
/** 显示图片 */
+ (void)showCustomImageWithMessage:(NSString *)msg customImage:(UIImage *)customImg inview:(UIView *)view style:(WSSProgressHUDStyle)style;
/** 显示自定义动画 */
+ (void)showCustomAnimationWithMessage:(NSString *)msg withImgArry:(NSArray<UIImage *> *)imgArry inview:(UIView *)view style:(WSSProgressHUDStyle)style;
/** 隐藏 */
+ (void)hideHUDWithView:(UIView *)view;
/** 隐藏 Window*/
+ (void)hideHUDWithWindow;
/// 获取window
+ (UIWindow *)applicationWindow;
@end

