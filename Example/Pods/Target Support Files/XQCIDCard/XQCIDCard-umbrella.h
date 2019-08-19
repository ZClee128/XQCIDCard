#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "BankCard.h"
#import "commondef.h"
#import "exbankcard.h"
#import "exbankcardcore.h"
#import "excards.h"
#import "publicClass.h"
#import "RectManager.h"
#import "XQCBankSearch.h"
#import "XQCCardModel.h"
#import "XQCCardScanViewController.h"
#import "XQCIDCardScaningView.h"
#import "NSBundle+loadImage.h"
#import "UIImage+myImage.h"
#import "UIImage+XQCExtend.h"
#import "IDCardSDKHeader.h"

FOUNDATION_EXPORT double XQCIDCardVersionNumber;
FOUNDATION_EXPORT const unsigned char XQCIDCardVersionString[];

