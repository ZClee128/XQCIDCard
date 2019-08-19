//
//  UIImage+myImage.m
//  XQCPaySDK_Objc
//
//  Created by lee on 2019/6/12.
//

#import "UIImage+myImage.h"
#import "NSBundle+loadImage.h"
@implementation UIImage (myImage)

+ (UIImage *)my_bundleImageNamed:(NSString *)name {
    return [self my_imageNamed:name inBundle:[NSBundle my_myLibraryBundle]];
}


+ (UIImage *)my_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle {
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_8_0
    return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
#elif __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_8_0
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:@"png"]];
#else
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        return [UIImage imageNamed:name inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageWithContentsOfFile:[bundle pathForResource:name ofType:@"png"]];
    }
#endif
}

@end
