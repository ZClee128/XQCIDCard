//
//  NavView.h
//  XQCIDCard
//
//  Created by lee on 2019/8/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NavView : UIView

@property (nonatomic,copy)void(^click)(UIButton *btn);
@end

NS_ASSUME_NONNULL_END
