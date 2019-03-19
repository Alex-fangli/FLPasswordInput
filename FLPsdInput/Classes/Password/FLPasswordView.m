//
//  FLPasswordView.m
//  FLTextProject
//
//  Created by liangXiaoSong on 2019/3/16.
//  Copyright © 2019 Fang. All rights reserved.
//

#import "FLPasswordView.h"
#import "OPEEnterPasswordView.h"
#import "OpeUnitField.h"


static NSInteger const passwordHeight = 141;

@interface FLPasswordView () <OPEEnterPasswordViewDelegate>

///遮盖视图
@property (nonatomic, strong) UIView          *coverView;
@property (nonatomic, strong) UIView          *superView;
@property (nonatomic, strong) UIColor         *backgroundColor;

///键盘高度
@property (nonatomic, assign) CGFloat                       keyboardHeight;
@property (nonatomic, strong) OPEEnterPasswordView         *passwordView;

@property (nonatomic, copy) NSString         *title;

@end

@implementation FLPasswordView

- (id)init {
    return [self initWithTitle:@""
                     superView:nil
               backgroundColor:nil];
}

- (id)initWithTitle:(NSString *)title
          superView:(UIView *)superView
    backgroundColor:(UIColor *)backgroundColor; {
    if (self = [super init]) {
        self.title = title;
        if (superView && [superView isKindOfClass:[UIView class]]) {
            self.superView = superView;
        }else{
            self.superView = [UIApplication sharedApplication].keyWindow;
        }
        if (backgroundColor && [backgroundColor isKindOfClass:[UIColor class]]) {
            self.backgroundColor = backgroundColor;
        }else{
            self.backgroundColor = FLHexRGBAlpha(0x000000, 0.8);
        }
        
        [self createSubviews];
        
        [self addNotification];
    }
    return self;
}


- (void)createSubviews {
    [self.coverView addSubview:self.passwordView];
    [self.superView addSubview:self.coverView];
}

- (void)clearPassword {
    [self.passwordView endEditing:YES];
    self.passwordView.hidden = YES;
    [self hideArrow];
    [self.passwordView.field clearContentAndNeedShake:NO];
}


- (void)showPasswordView {
    if (!self.superView) {
        self.superView = [UIApplication sharedApplication].keyWindow;
        [self.superView addSubview:self.coverView];
        self.coverView.frame = self.superView.bounds;
    }
    [self showArrow];
    
    [UIView animateWithDuration:0.4 animations:^{

    }completion:^(BOOL finished) {
        self.passwordView.hidden = NO;
        [self.passwordView.field becomeFirstResponder];
        self.passwordView.frame = CGRectMake(0,
                                             FLScreenHeight - self.keyboardHeight - passwordHeight,
                                             FLScreenWidth,
                                             passwordHeight);
    }];
}

- (void)hidePasswordView {
    [self clearPassword];
}

-(void)showArrow{
    [UIView beginAnimations:@"ShowArrow" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelegate:self];
    self.coverView.alpha = 0.8;
    [UIView commitAnimations];
}

- (void)hideArrow {
    [UIView beginAnimations:@"HideArrow" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.0];
    self.coverView.alpha = 0.0;
    [UIView commitAnimations];
}


- (void)addNotification {
    //增加监听，当键盘出现或改变时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

//当键盘出现或改变时调用
- (void)keyboardWillShow:(NSNotification *)aNotification {
    //获取键盘的高度
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    self.keyboardHeight = keyboardRect.size.height;
}


- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [[UIView alloc] initWithFrame:self.superView.bounds];
        _coverView.backgroundColor = self.backgroundColor;
    }
    return _coverView;
}

- (OPEEnterPasswordView *)passwordView {
    if (!_passwordView) {
        _passwordView = [[[NSBundle mainBundle] loadNibNamed:@"OPEEnterPasswordView"
                                                       owner:nil
                                                     options:nil] lastObject];
        _passwordView.hidden = YES;
        _passwordView.delegate = self;
        _passwordView.psdTitle = self.title;
    }
    return _passwordView;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


/**
 * 点击事件回调
 * @param paassworkView self
 * @param sender btn
 */
- (void)OPEEnterPasswordView:(OPEEnterPasswordView *)paassworkView
                    clickBtn:(UIButton *)sender {
    if (self.cancelInputBlock) {
        self.cancelInputBlock();
    }
}


/**
 * 输入完成成功回调
 * @param paassworkView self
 * @param input 输入框
 */
- (void)OPEEnterPasswordView:(OPEEnterPasswordView *)paassworkView
                       input:(OpeUnitField *)input {
    if (self.psdInputBlock) {
        self.psdInputBlock(input.text);
    }
}


@end
