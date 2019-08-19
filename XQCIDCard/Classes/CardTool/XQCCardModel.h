//
//  XQCCardModel.h
//  XQC
//
//  Created by lee on 2019/4/20.
//  Copyright © 2019 xqc. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface XQCCardModel : NSObject

/** 身份证信息 */
@property (nonatomic, assign)  int type;          //1:正面  2:反面
@property (nonatomic, copy)    NSString *code;    //身份证号
@property (nonatomic, copy)    NSString *name;    //姓名
@property (nonatomic, copy)    NSString *gender;  //性别
@property (nonatomic, copy)    NSString *nation;  //民族
@property (nonatomic, copy)    NSString *address; //地址
@property (nonatomic, copy)    NSString *issue;   //签发机关
@property (nonatomic, copy)    NSString *valid;   //有效期
@property (nonatomic, strong)  UIImage *idImage;   //正反面照片

/** 银行卡信息 */
@property (nonatomic, copy)   NSString *bankNumber; //银行卡卡号
@property (nonatomic, copy)   NSString *bankName;   //银行卡名称
@property (nonatomic, strong) UIImage *bankImage;  //银行卡照片


/** 身份证字符串 */
- (NSString *)toString;

/** 是否为身份证 */
- (BOOL)isOK;

//过滤空格符后的bankNumber
- (NSString *)filterBlankSpaceBankNumber;

@end

NS_ASSUME_NONNULL_END
