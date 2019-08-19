//
//  AlertTool.h
//  XQCIDCard
//
//  Created by lee on 2019/8/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertTool : NSObject

+ (void)showTitle:(NSString *)title Message:(NSString *)message cancleTitle:(NSString *)cancleTitle sureTitle:(NSString *)sureTitle viewController:(UIViewController *)vc cancle:(void (^)(UIAlertAction * _Nonnull action))cancle sure:(void(^)(UIAlertAction * _Nonnull action))sure;

@end

NS_ASSUME_NONNULL_END
