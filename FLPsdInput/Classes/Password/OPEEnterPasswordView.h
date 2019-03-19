//
//  OPEEnterPasswordView.h
//  OPEMVPProject
//
//  Created by liangXiaoSong on 2018/12/28.
//  Copyright © 2018 liangXiaoSong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define FLHexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define FLHexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define FLScreenWidth     [UIScreen mainScreen].bounds.size.width
#define FLScreenHeight    [UIScreen mainScreen].bounds.size.height

#define FLFix(width) width * (FLScreenWidth / 375.0)

@class OPEEnterPasswordView,OpeUnitField;

@protocol OPEEnterPasswordViewDelegate <NSObject>

/**
 * 点击事件回调
 * @param paassworkView self
 * @param sender btn
 */
- (void)OPEEnterPasswordView:(OPEEnterPasswordView *)paassworkView clickBtn:(UIButton *)sender;


/**
 * 输入完成成功回调
 * @param paassworkView self
 * @param input 输入框
 */
- (void)OPEEnterPasswordView:(OPEEnterPasswordView *)paassworkView input:(OpeUnitField *)input;

@end

/**
 * 确认订单输入密码视图
 */
@interface OPEEnterPasswordView : UIView

@property (copy, nonatomic) NSString      *psdTitle;
@property (strong, nonatomic) UIColor      *psdTitleColor;

@property (strong, nonatomic) OpeUnitField      *field;

@property (nonatomic, weak) id<OPEEnterPasswordViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
