//
//  UIImage+XQCExtend.h
//  XQC
//
//  Created by lee on 2019/5/7.
//  Copyright © 2019 xqc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (XQCExtend)

+ (UIImage *)getImageStream:(CVImageBufferRef)imageBuffer;
+ (UIImage *)getSubImage:(CGRect)rect inImage:(UIImage*)image;

@end

NS_ASSUME_NONNULL_END
