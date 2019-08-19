//
//  XQCIDCardScaningView.h
//  XQC
//
//  Created by lee on 2019/4/28.
//  Copyright © 2019 xqc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ScaningCardType)
{
    ScaningCardIDWithFront,     // 身份证正面
    ScaningCardIDWithDown,      // 身份证反面
    ScaningCardIDWithBank       // 银行卡
};

@interface XQCIDCardScaningView : UIView

@property (nonatomic,assign) CGRect facePathRect;
@property (nonatomic,assign) CGRect bankPathRect;

/** 扫描类型 */
- (void)scaningCardIDWithType:(ScaningCardType)type;

@end

NS_ASSUME_NONNULL_END
