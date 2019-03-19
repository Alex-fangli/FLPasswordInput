//
//  OPEEnterPasswordView.m
//  OPEMVPProject
//
//  Created by liangXiaoSong on 2018/12/28.
//  Copyright © 2018 liangXiaoSong. All rights reserved.
//

#import "OPEEnterPasswordView.h"
#import "OpeUnitField.h"


@interface OPEEnterPasswordView ()
///返回按钮
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
///标题
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *inLineView;

@property (nonatomic, assign) CGFloat         fl_width;
@property (nonatomic, assign) CGFloat         fl_height;

@end

@implementation OPEEnterPasswordView

- (CGFloat)fl_width {
    return CGRectGetWidth(self.frame);
}

- (CGFloat)fl_height {
    return CGRectGetHeight(self.frame);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.titleLabel.textColor = FLHexRGB(0x4A4A4A);
    
    [self addSubview:self.field];
}

- (void)setPsdTitle:(NSString *)psdTitle {
    if (![psdTitle isKindOfClass:[NSString class]] ||
        [psdTitle isEqualToString:@""]) {
        return;
    }
    _psdTitle = psdTitle;
    self.titleLabel.text = _psdTitle;
}

- (void)setPsdTitleColor:(UIColor *)psdTitleColor {
    _psdTitleColor = psdTitleColor;
    self.titleLabel.textColor = _psdTitleColor;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];

    self.field.frame = CGRectMake(0,
                                  (self.fl_height - CGRectGetMaxY(self.inLineView.frame) - 26)/2 + CGRectGetMaxY(self.inLineView.frame),
                                  FLScreenWidth,
                                  26);
}

- (OpeUnitField *)field {
    if (!_field) {
        _field = ({
            OpeUnitField *field = [[OpeUnitField alloc] initWithInputUnitCount:6];
            field.unitSpace = FLFix(25);
            field.borderRadius = 0;
            field.textColor = FLHexRGB(0xDF3530);
            field.tintColor = [UIColor clearColor];
            field.trackTintColor = nil;
            field.palceholderColor = FLHexRGBAlpha(0xDF3530, 0.2);
            field.secureTextEntry = YES;
            field.cursorColor = nil;
            [field addTarget:self
                      action:@selector(unitFieldEditingChanged:)
            forControlEvents:UIControlEventEditingChanged];
            
            field;
        });
    }
    
    return _field;
}

- (IBAction)clickBtn:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(OPEEnterPasswordView:clickBtn:)]) {
        [self.delegate OPEEnterPasswordView:self clickBtn:sender];
    }
}

#pragma mark - Event

-(void)unitFieldEditingChanged:(OpeUnitField *)sender{
    if (sender.text.length >= 6) {
        if ([self.delegate respondsToSelector:@selector(OPEEnterPasswordView:input:)]) {
            [self.delegate OPEEnterPasswordView:self input:sender];
        }
    }
}

@end
