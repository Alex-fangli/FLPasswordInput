//
//  FLPasswordView.h
//  FLTextProject
//
//  Created by liangXiaoSong on 2019/3/16.
//  Copyright © 2019 Fang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CancelInputBlock)(void);
typedef void(^PasswordInputBlock)(NSString *);

@interface FLPasswordView : UIView

- (id)initWithTitle:(NSString *)title
          superView:(UIView *)superView
        backgroundColor:(UIColor *)backgroundColor;

- (void)showPasswordView;
- (void)hidePasswordView;

@property (nonatomic, copy) PasswordInputBlock         psdInputBlock;
@property (nonatomic, copy) CancelInputBlock           cancelInputBlock;

@end

NS_ASSUME_NONNULL_END
