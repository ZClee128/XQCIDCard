//
//  XQCCardModel.m
//  XQC
//
//  Created by lee on 2019/4/20.
//  Copyright © 2019 xqc. All rights reserved.
//

#import "XQCCardModel.h"

@implementation XQCCardModel

- (BOOL)isEqual:(XQCCardModel *)idInfo
{
    if (idInfo == nil) {
        return NO;
    }
    if (_type == 1) {
        if ((_type == idInfo.type) &&
            [_code isEqualToString:idInfo.code] &&
            [_name isEqualToString:idInfo.name] &&
            [_gender isEqualToString:idInfo.gender] &&
            [_gender isEqualToString:idInfo.gender] &&
            [_address isEqualToString:idInfo.address]) {
            return YES;
        }
    } else if (_type == 2) {
        if ([_issue isEqualToString:idInfo.issue] &&
            [_valid isEqualToString:idInfo.valid]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)toString {
    return [NSString stringWithFormat:@"身份证号:%@\n姓名:%@\n性别:%@\n民族:%@\n地址:%@\n签发机关:%@\n有效期:%@",
            _code, _name, _gender, _nation, _address, _issue, _valid];
}

- (BOOL)isOK {
    if (_code !=nil && _name!=nil && _gender!=nil && _nation!=nil && _address!=nil) {
        if (_code.length>0 && _name.length >0 && _gender.length>0 && _nation.length>0 && _address.length>0) {
            return YES;
        }
    }
    else if (_issue !=nil && _valid!=nil) {
        if (_issue.length>0 && _valid.length >0) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)filterBlankSpaceBankNumber
{
    return [self.bankNumber stringByReplacingOccurrencesOfString:@" " withString:@""];
}

@end
