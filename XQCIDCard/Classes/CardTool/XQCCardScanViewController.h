//
//  XQCCardScanViewController.h
//  XQC
//
//  Created by lee on 2019/5/5.
//  Copyright © 2019 xqc. All rights reserved.
//


#import "XQCCardModel.h"
#import "XQCIDCardScaningView.h"
NS_ASSUME_NONNULL_BEGIN

@protocol XQCCardScanCompleteDelegate <NSObject>

/**
 扫描完成代理

 @param model 卡片的模型
 */
- (void)XQCScanComplete:(XQCCardModel *)model;

@end

typedef void(^CompleteBlock)(XQCCardModel *model);

@interface XQCCardScanViewController : UIViewController

@property (nonatomic,assign) id<XQCCardScanCompleteDelegate> delegate;

@property (nonatomic,assign)ScaningCardType cardtype;

@property (nonatomic,copy)CompleteBlock complete;

- (void)IDCardRecognit:(CVImageBufferRef)imageBuffer;
@end

NS_ASSUME_NONNULL_END
