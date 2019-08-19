//
//  AlertTool.m
//  XQCIDCard
//
//  Created by lee on 2019/8/19.
//

#import "AlertTool.h"

@implementation AlertTool


+ (void)showTitle:(NSString *)title Message:(NSString *)message cancleTitle:(NSString *)cancleTitle sureTitle:(NSString *)sureTitle viewController:(UIViewController *)vc cancle:(nonnull void (^)(UIAlertAction * _Nonnull))cancle sure:(nonnull void (^)(UIAlertAction * _Nonnull))sure{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:cancleTitle
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             cancle(action);
                                                         }];
    
    UIAlertAction *actionDone = [UIAlertAction actionWithTitle:sureTitle
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) {
                                                           sure(action);
                                                       }];
    if ([cancleTitle isEqualToString:@""]) {
        [alert addAction:actionDone];
    }else{
        [alert addAction:actionCancel];
        [alert addAction:actionDone];
    }
    
    
    [vc presentViewController:alert animated:YES completion:nil];
}
@end
