# WSSProgressHUD

[![CI Status](https://img.shields.io/travis/18566663687@163.com/WSSProgressHUD.svg?style=flat)](https://travis-ci.org/18566663687@163.com/WSSProgressHUD)
[![Version](https://img.shields.io/cocoapods/v/WSSProgressHUD.svg?style=flat)](https://cocoapods.org/pods/WSSProgressHUD)
[![License](https://img.shields.io/cocoapods/l/WSSProgressHUD.svg?style=flat)](https://cocoapods.org/pods/WSSProgressHUD)
[![Platform](https://img.shields.io/cocoapods/p/WSSProgressHUD.svg?style=flat)](https://cocoapods.org/pods/WSSProgressHUD)


## Installation

WSSProgressHUD is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WSSProgressHUD'
```

## Example
```
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

```


## Author

wangsi,17601013687@163.com

## License

WSSProgressHUD is available under the MIT license. See the LICENSE file for more info.
