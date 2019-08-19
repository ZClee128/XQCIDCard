//
//  XQCBankSearch.h
//  XQC
//
//  Created by lee on 2019/5/7.
//  Copyright © 2019 xqc. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XQCBankSearch : NSObject

+ (NSString *)getBankNameByBin:(char *)numbers count:(int)nCount;
@end

NS_ASSUME_NONNULL_END
