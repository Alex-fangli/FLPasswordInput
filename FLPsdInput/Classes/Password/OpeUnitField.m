//
//  OpeUnitField.m
//  OpeWallet
//
//  Created by EDZ on 2018/9/9.
//  Copyright © 2018年 OpeChain. All rights reserved.
//

#import "OpeUnitField.h"
#import <AudioToolbox/AudioToolbox.h>

#define DEFAULT_CONTENT_SIZE_WITH_UNIT_COUNT(c) CGSizeMake(44 * c, 44)

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
NSNotificationName const OpeUnitFieldDidBecomeFirstResponderNotification = @"OpeUnitFieldDidBecomeFirstResponderNotification";
NSNotificationName const OpeUnitFieldDidResignFirstResponderNotification = @"OpeUnitFieldDidResignFirstResponderNotification";
#else
NSString *const OpeUnitFieldDidBecomeFirstResponderNotification = @"OpeUnitFieldDidBecomeFirstResponderNotification";
NSString *const OpeUnitFieldDidResignFirstResponderNotification = @"OpeUnitFieldDidResignFirstResponderNotification";
#endif

@interface OpeUnitField ()<UIKeyInput>

@property (nonatomic, strong) NSMutableArray *string;
@property (nonatomic, strong) CALayer *cursorLayer;

@end

@implementation OpeUnitField

{
    UIColor *_backgroundColor;
    CGContextRef _ctx;
}

@synthesize secureTextEntry = _secureTextEntry;
@synthesize enablesReturnKeyAutomatically = _enablesReturnKeyAutomatically;
@synthesize keyboardType = _keyboardType;
@synthesize returnKeyType = _returnKeyType;

#pragma mark - Life

- (instancetype)initWithInputUnitCount:(NSUInteger)count {
    if (self = [super initWithFrame:CGRectZero]) {
        NSCAssert(count > 0, @"OpeUnitField must have one or more input units.");
        NSCAssert(count <= 9, @"OpeUnitField can not have more than 9 input units.");
        
        _inputUnitCount = count;
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _inputUnitCount = 4;
        [self initialize];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _inputUnitCount = 4;
        [self initialize];
    }
    
    return self;
}

- (void)initialize {
    [super setBackgroundColor:[UIColor clearColor]];
    _string = [NSMutableArray array];
    _secureTextEntry = NO;
    _unitSpace = 12;
    _borderRadius = 0;
    _borderWidth = 1;
    _textFont = [UIFont systemFontOfSize:35];
    _defaultKeyboardType = OpeKeyboardTypeNumberPad;
    _defaultReturnKeyType = UIReturnKeyDone;
    _enablesReturnKeyAutomatically = YES;
    _autoResignFirstResponderWhenInputFinished = NO;
    _textColor = [UIColor darkGrayColor];
    _tintColor = [UIColor lightGrayColor];
    _trackTintColor = [UIColor orangeColor];
    _cursorColor = [UIColor orangeColor];
    _palceholderColor = [UIColor grayColor];
    _backgroundColor = _backgroundColor ?: [UIColor clearColor];
    self.cursorLayer.backgroundColor = _cursorColor.CGColor;
    
    
    [self.layer addSublayer:self.cursorLayer];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self setNeedsDisplay];
    }];
    
    //     第一次直接弹出键盘,不需要则注释
    [self becomeFirstResponder];
}

#pragma mark - Property

- (NSString *)text {
    if (_string.count == 0) return nil;
    return [_string componentsJoinedByString:@""];
}

- (CALayer *)cursorLayer {
    if (!_cursorLayer) {
        _cursorLayer = [CALayer layer];
        _cursorLayer.hidden = YES;
        _cursorLayer.opacity = 1;
        
        CABasicAnimation *animate = [CABasicAnimation animationWithKeyPath:@"opacity"];
        animate.fromValue = @(0);
        animate.toValue = @(1.5);
        animate.duration = 0.5;
        animate.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animate.autoreverses = YES;
        animate.removedOnCompletion = NO;
        animate.fillMode = kCAFillModeForwards;
        animate.repeatCount = HUGE_VALF;
        
        [_cursorLayer addAnimation:animate forKey:nil];
        
        //        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        ////            _cursorLayer.position = CGPointMake(CGRectGetWidth(self.bounds) / _inputUnitCount / 2, CGRectGetHeight(self.bounds) / 2);
        ////            [self layoutIfNeeded];
        //        }];
    }
    
    return _cursorLayer;
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry {
    _secureTextEntry = secureTextEntry;
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

#if TARGET_INTERFACE_BUILDER
- (void)setInputUnitCount:(NSUInteger)inputUnitCount {
    if (inputUnitCount < 1 || inputUnitCount > 9) return;
    
    _inputUnitCount = inputUnitCount;
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}
#endif

- (void)setUnitSpace:(CGFloat)unitSpace {
    if (unitSpace < 0) return;
    if (unitSpace < 2) unitSpace = 0;
    
    _unitSpace = unitSpace;
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

- (void)setTextFont:(UIFont *)textFont {
    if (textFont == nil) {
        _textFont = [UIFont systemFontOfSize:22];
    } else {
        _textFont = textFont;
    }
    
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

- (void)setTextColor:(UIColor *)textColor {
    if (textColor == nil) {
        _textColor = [UIColor blackColor];
    } else {
        _textColor = textColor;
    }
    
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

- (void)setPalceholderColor:(UIColor *)palceholderColor {
    if (palceholderColor == nil) {
        _palceholderColor = [UIColor grayColor];
    }
    else {
        _palceholderColor = palceholderColor;
    }
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

- (void)setBorderRadius:(CGFloat)borderRadius {
    if (borderRadius < 0) return;
    
    _borderRadius = borderRadius;
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if (borderWidth < 0) return;
    
    _borderWidth = borderWidth;
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (backgroundColor == nil) {
        _backgroundColor = [UIColor blackColor];
    } else {
        _backgroundColor = backgroundColor;
    }
    
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

- (void)setTintColor:(UIColor *)tintColor {
    if (tintColor == nil) {
        _tintColor = [[UIView appearance] tintColor];
    } else {
        _tintColor = tintColor;
    }
    
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

- (void)setTrackTintColor:(UIColor *)trackTintColor {
    _trackTintColor = trackTintColor;
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

- (void)setCursorColor:(UIColor *)cursorColor {
    _cursorColor = cursorColor;
    _cursorLayer.backgroundColor = _cursorColor.CGColor;
    [self _showOrHideCursorIfNeeded];
}

#pragma mark- Event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self becomeFirstResponder];
}

#pragma mark - Override

- (CGSize)intrinsicContentSize {
    [self layoutIfNeeded];
    CGSize size = self.bounds.size;
    
    if (size.width < DEFAULT_CONTENT_SIZE_WITH_UNIT_COUNT(_inputUnitCount).width) {
        size.width = DEFAULT_CONTENT_SIZE_WITH_UNIT_COUNT(_inputUnitCount).width;
    }
    
    CGFloat unitWidth = (size.width + _unitSpace) / _inputUnitCount - _unitSpace;
    size.height = unitWidth;
    
    return size;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self intrinsicContentSize];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    BOOL result = [super becomeFirstResponder];
    [self _showOrHideCursorIfNeeded];
    
    if (result ==  YES) {
        [self sendActionsForControlEvents:UIControlEventEditingDidBegin];
        [[NSNotificationCenter defaultCenter] postNotificationName:OpeUnitFieldDidBecomeFirstResponderNotification object:nil];
    }
    return result;
}

- (BOOL)canResignFirstResponder {
    return YES;
}

- (BOOL)resignFirstResponder {
    BOOL result = [super resignFirstResponder];
    [self _showOrHideCursorIfNeeded];
    
    if (result) {
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
        [[NSNotificationCenter defaultCenter] postNotificationName:OpeUnitFieldDidResignFirstResponderNotification object:nil];
    }
    return result;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    /*
     *  绘制的线条具有宽度，因此在绘制时需要考虑该因素对绘制效果的影响。
     */
    CGSize unitSize = CGSizeMake((rect.size.width + _unitSpace) / _inputUnitCount - _unitSpace, rect.size.height);
    
    _ctx = UIGraphicsGetCurrentContext();
    
    [self _fillRect:rect clip:YES];
    [self _drawBorder:rect unitSize:unitSize];
    [self _drawText:rect unitSize:unitSize];
    [self _drawTrackBorder:rect unitSize:unitSize];
    
    [self _resize];
}

#pragma mark- Private

/**
 在 AutoLayout 环境下重新指定控件本身的固有尺寸
 
 `-drawRect:`方法会计算控件完成自身的绘制所需的合适尺寸，完成一次绘制后会通知 AutoLayout 系统更新尺寸。
 */
- (void)_resize {
    [self invalidateIntrinsicContentSize];
}


/**
 绘制背景色，以及剪裁绘制区域
 
 @param rect 控件绘制的区域
 @param clip 剪裁区域同时被`borderRadius`影响
 */
- (void)_fillRect:(CGRect)rect clip:(BOOL)clip {
    [_backgroundColor setFill];
    if (clip) {
        CGContextAddPath(_ctx, [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:_borderRadius].CGPath);
        CGContextClip(_ctx);
    }
    CGContextAddPath(_ctx, [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, _borderWidth * 0.75, _borderWidth * 0.75) cornerRadius:_borderRadius].CGPath);
    CGContextFillPath(_ctx);
}

/**
 绘制边框
 
 边框的绘制分为两种模式：连续和不连续。其模式的切换由`unitSpace`属性决定。
 当`unitSpace`值小于 2 时，采用的是连续模式，即每个 input unit 之间没有间隔。
 反之，每个 input unit 会被边框包围。
 
 @see unitSpace
 
 @param rect 控件绘制的区域
 @param unitSize 单个 input unit 占据的尺寸
 */
- (void)_drawBorder:(CGRect)rect unitSize:(CGSize)unitSize {
    
    [self.tintColor setStroke];
    CGContextSetLineWidth(_ctx, _borderWidth);
    CGContextSetLineCap(_ctx, kCGLineCapRound);
    CGRect bounds = CGRectInset(rect, _borderWidth * 0.5, _borderWidth * 0.5);
    
    
    if (_unitSpace < 2) {
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:_borderRadius];
        CGContextAddPath(_ctx, bezierPath.CGPath);
        
        for (int i = 1; i < _inputUnitCount; ++i) {
            CGContextMoveToPoint(_ctx, (i * unitSize.width), 0);
            CGContextAddLineToPoint(_ctx, (i * unitSize.width), (unitSize.height));
        }
        
    } else {
        for (int i = (int)_string.count; i < _inputUnitCount; i++) {
            CGRect unitRect = CGRectMake(i * (unitSize.width + _unitSpace),
                                         0,
                                         unitSize.width,
                                         unitSize.height);
            unitRect = CGRectInset(unitRect, _borderWidth * 0.5, _borderWidth * 0.5);
            UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:unitRect cornerRadius:_borderRadius];
            CGContextAddPath(_ctx, bezierPath.CGPath);
        }
    }
    CGContextDrawPath(_ctx, kCGPathStroke);
}


/**
 绘制文本
 
 当处于密文输入模式时，会用圆圈替代文本。
 
 @param rect 控件绘制的区域
 @param unitSize 单个 input unit 占据的尺寸
 */
- (void)_drawText:(CGRect)rect unitSize:(CGSize)unitSize {
    
    
    for (int i = 0; i < _inputUnitCount; i++) {
        
        
        
        
        if (_secureTextEntry == NO) {
            NSDictionary *attr = @{NSForegroundColorAttributeName: _textColor,
                                   NSFontAttributeName: _textFont};
            CGRect unitRect = CGRectMake(i * (unitSize.width + _unitSpace),
                                         0,
                                         unitSize.width,
                                         unitSize.height);
            if (i <= _string.count -1) {
                NSString *subString = [_string objectAtIndex:i];
                
                CGSize oneTextSize = [subString sizeWithAttributes:attr];
                CGRect drawRect = CGRectInset(unitRect,
                                              (unitRect.size.width - oneTextSize.width) / 2,
                                              (unitRect.size.height - oneTextSize.height) / 2);
                [subString drawInRect:drawRect withAttributes:attr];
            }
        } else {
            CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
            CGFloat leftMargin = (screenWidth - (unitSize.height * _inputUnitCount + _unitSpace * (_inputUnitCount)))/2;
            CGFloat left;
            if (i < 3) {
                left = i * (unitSize.height + _unitSpace);
            }
            else {
                left = i * (unitSize.height + _unitSpace) + _unitSpace;
            }
            
            CGRect unitRect = CGRectMake(leftMargin + left,
                                         0,
                                         unitSize.height,
                                         unitSize.height);
            
            CGRect drawRect = unitRect;
            if (i < _string.count) {
                [_textColor setFill];
            }
            else {
                [_palceholderColor setFill];
            }
            CGContextAddEllipseInRect(_ctx, drawRect);
            CGContextFillPath(_ctx);
        }
    }
    
}


/**
 绘制跟踪框，如果指定的`trackTintColor`为 nil 则不绘制
 
 @param rect 控件绘制的区域
 @param unitSize 单个 input unit 占据的尺寸
 */
- (void)_drawTrackBorder:(CGRect)rect unitSize:(CGSize)unitSize {
    if (_trackTintColor == nil) return;
    if (_unitSpace < 2) return;
    
    
    [_trackTintColor setStroke];
    CGContextSetLineWidth(_ctx, _borderWidth);
    CGContextSetLineCap(_ctx, kCGLineCapRound);
    
    for (int i = 0; i < _string.count; i++) {
        CGRect unitRect = CGRectMake(i * (unitSize.width + _unitSpace),
                                     0,
                                     unitSize.width,
                                     unitSize.height);
        unitRect = CGRectInset(unitRect, _borderWidth * 0.5, _borderWidth * 0.5);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:unitRect cornerRadius:_borderRadius];
        CGContextAddPath(_ctx, bezierPath.CGPath);
    }
    CGContextDrawPath(_ctx, kCGPathStroke);
}

- (void)_showOrHideCursorIfNeeded {
    _cursorLayer.hidden = !self.isFirstResponder || _cursorColor == nil || _inputUnitCount == _string.count;
    
    if (_cursorLayer.hidden) return;
    
    CGSize unitSize = CGSizeMake((self.bounds.size.width + _unitSpace) / _inputUnitCount - _unitSpace, self.bounds.size.height);
    
    CGRect unitRect = CGRectMake(_string.count * (unitSize.width + _unitSpace),
                                 0,
                                 unitSize.width,
                                 unitSize.height);
    unitRect = CGRectInset(unitRect,
                           unitRect.size.width / 2 - 1,
                           (unitRect.size.height - _textFont.pointSize) / 2);
    _cursorLayer.frame = unitRect;
}

#pragma mark - UIKeyInput

- (BOOL)hasText {
    return _string != nil && _string.count > 0;
}

- (void)insertText:(NSString *)text {
    if (_string.count >= _inputUnitCount) {
        if (_autoResignFirstResponderWhenInputFinished == YES) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self resignFirstResponder];
            }];
        }
        return;
    }
    
    if ([text isEqualToString:@" "]) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(unitField:shouldChangeCharactersInRange:replacementString:)]) {
        if ([self.delegate unitField:self shouldChangeCharactersInRange:NSMakeRange(_string.count - 1, 1) replacementString:text] == NO) {
            return;
        }
    }
    
    NSRange range;
    for (int i = 0; i < text.length; i += range.length) {
        range = [text rangeOfComposedCharacterSequenceAtIndex:i];
        [_string addObject:[text substringWithRange:range]];
    }
    
    if (_string.count >= _inputUnitCount) {
        [_string removeObjectsInRange:NSMakeRange(_inputUnitCount, _string.count - _inputUnitCount)];
        [self sendActionsForControlEvents:UIControlEventEditingChanged];
        
        if (_autoResignFirstResponderWhenInputFinished == YES) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self resignFirstResponder];
            }];
        }
    } else {
        [self sendActionsForControlEvents:UIControlEventEditingChanged];
    }
    
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

- (void)deleteBackward {
    if ([self hasText] == NO)
        return;
    
    if ([self.delegate respondsToSelector:@selector(unitField:shouldChangeCharactersInRange:replacementString:)]) {
        if ([self.delegate unitField:self shouldChangeCharactersInRange:NSMakeRange(_string.count - 1, 0) replacementString:@""] == NO) {
            return;
        }
    }
    
    [_string removeLastObject];
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
    
    [self setNeedsDisplay];
    [self _showOrHideCursorIfNeeded];
}

- (UIKeyboardType)keyboardType {
    if (_defaultKeyboardType == OpeKeyboardTypeASCIICapable) {
        return UIKeyboardTypeASCIICapable;
    }
    
    return UIKeyboardTypeNumberPad;
}

- (UITextAutocorrectionType)autocorrectionType {
    return UITextAutocorrectionTypeNo;
}

- (UIReturnKeyType)returnKeyType {
    return _defaultReturnKeyType;
}

//===========================OpeWallet=================================//
//===========================OpeWallet=================================//
//===========================OpeWallet=================================//
//===============modify by Samuel   Data  =============================//
-(void)clearContentAndNeedShake:(BOOL)needShake{
    
    for (NSInteger i = 0; i < 6; ++i) {
        [self deleteBackward];
    }
    
    if (needShake) {
        [self shake];
        //调用系统的震动SoundId
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
}

//===========================OpeWallet=================================//
//===========================OpeWallet=================================//
//===========================OpeWallet=================================//

/**
 * @brief 抖动
 */
- (void) shake
{
    CAKeyframeAnimation *animationKey = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [animationKey setDuration:0.5f];
    
    NSArray *array = [[NSArray alloc] initWithObjects:
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x-5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x+5, self.center.y)],
                      [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.center.y)],
                      nil];
    [animationKey setValues:array];
    //    [array release];
    
    NSArray *times = [[NSArray alloc] initWithObjects:
                      [NSNumber numberWithFloat:0.1f],
                      [NSNumber numberWithFloat:0.2f],
                      [NSNumber numberWithFloat:0.3f],
                      [NSNumber numberWithFloat:0.4f],
                      [NSNumber numberWithFloat:0.5f],
                      [NSNumber numberWithFloat:0.6f],
                      [NSNumber numberWithFloat:0.7f],
                      [NSNumber numberWithFloat:0.8f],
                      [NSNumber numberWithFloat:0.9f],
                      [NSNumber numberWithFloat:1.0f],
                      nil];
    [animationKey setKeyTimes:times];
    //    [times release];
    
    [self.layer addAnimation:animationKey forKey:@"TextFieldShake"];
}

@end
