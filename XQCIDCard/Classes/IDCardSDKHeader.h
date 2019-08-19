//
//  Header.h
//  XQCPaySDK_Objc
//
//  Created by lee on 2019/6/12.
//

#ifndef Header_h
#define Header_h


//屏幕宽
#define XQCPHONE_WIDTH [UIScreen mainScreen].bounds.size.width
//屏幕高
#define XQCPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height

#define iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

// 状态栏高度
#define XQCSTATUS_BAR_HEIGHT (iPhoneX ? 44.f : 20.f)
// 导航栏高度
#define XQCNAVIGATION_BAR_HEIGHT (iPhoneX ? 88.f : 64.f)
// tabBar高度
#define XQCTAB_BAR_HEIGHT (iPhoneX ? (49.f+34.f) : 49.f)

#define XQCTAB_SAFE_HEIGHT (iPhoneX ? 34.f : 0.f)

#define Hex(rgbValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0])

#define WidthOfScale(x)  (x)*(XQCPHONE_WIDTH/375.0)

#define WeakSelf(type) __weak typeof(type) weak##type = type;


// iPhone5/5c/5s/SE 4英寸 屏幕宽高：320*568点 屏幕模式：2x 分辨率：1136*640像素
#define iPhone5or5cor5sorSE ([UIScreen mainScreen].bounds.size.height == 568.0)

// iPhone6/6s/7 4.7英寸 屏幕宽高：375*667点 屏幕模式：2x 分辨率：1334*750像素
#define iPhone6or6sor7 ([UIScreen mainScreen].bounds.size.height == 667.0)

// iPhone6 Plus/6s Plus/7 Plus 5.5英寸 屏幕宽高：414*736点 屏幕模式：3x 分辨率：1920*1080像素
#define iPhone6Plusor6sPlusor7Plus ([UIScreen mainScreen].bounds.size.height == 736.0)

/** 相对4.0寸屏幕宽的自动布局 */
#define KRealWidth5(value)  (long)((value)/320.0f * [UIScreen mainScreen].bounds.size.width)
#endif /* Header_h */
