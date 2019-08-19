//
//  UIImage+myImage.h
//  XQCPaySDK_Objc
//
//  Created by lee on 2019/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (myImage)

+ (UIImage *)my_bundleImageNamed:(NSString *)name;
+ (UIImage *)my_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
@end

NS_ASSUME_NONNULL_END
