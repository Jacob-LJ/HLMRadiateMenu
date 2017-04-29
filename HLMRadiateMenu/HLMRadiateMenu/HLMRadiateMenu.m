//
//  HLMRadiateMenu.m
//  HLMRadiateMenu
//
//  Created by Jacob on 2017/4/27.
//  Copyright © 2017年 Jacob. All rights reserved.
//

#import "HLMRadiateMenu.h"

static CGFloat const kHLMRadiateMenuDefaultNearRadius = 110.0f;
static CGFloat const kHLMRadiateMenuDefaultEndRadius = 120.0f;
static CGFloat const kHLMRadiateMenuDefaultFarRadius = 140.0f;
static CGFloat const kHLMRadiateMenuDefaultStartPointX = 160.0;
static CGFloat const kHLMRadiateMenuDefaultStartPointY = 240.0;
static CGFloat const kHLMRadiateMenuDefaultTimeOffset = 0.036f;
static CGFloat const kHLMRadiateMenuDefaultRotateAngle = 0.0;
static CGFloat const kHLMRadiateMenuDefaultMenuWholeAngle = M_PI * 2;
static CGFloat const kHLMRadiateMenuDefaultExpandRotation = M_PI;
static CGFloat const kHLMRadiateMenuDefaultCloseRotation = M_PI * 2;
static CGFloat const kHLMRadiateMenuDefaultAnimationDuration = 0.5f;
static CGFloat const kHLMRadiateMenuStartMenuDefaultAnimationDuration = 0.3f;

static CGPoint HLMRadiateMenu_RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle) {
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);
}

@interface HLMRadiateMenu ()<HLMRadiateMenuItemDelegate>

@property (strong, nonatomic) UIImageView *maskImageView;
@property (nonatomic, strong) UIView *shadowView;

@end

@implementation HLMRadiateMenu
{
    NSUInteger _flag;
    NSTimer *_timer;
    BOOL _isAnimating;
}

- (id)initWithFrame:(CGRect)frame startItem:(HLMRadiateMenuItem *)startItem menuItems:(NSArray *)menuItems {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUPInit];
        
        self.menuItems = menuItems;
        
        [self addSubview:self.maskImageView];
        [self addSubview:self.shadowView];
        
        // assign startItem to "Add" Button.
        self.startButton = startItem;
        self.startButton.delegate = self;
        self.startButton.center = self.startPoint;
        [self addSubview:self.startButton];
    }
    return self;
}

- (void)setUPInit {
    self.backgroundColor = [UIColor clearColor];
    
    self.nearRadius = kHLMRadiateMenuDefaultNearRadius;
    self.endRadius = kHLMRadiateMenuDefaultEndRadius;
    self.farRadius = kHLMRadiateMenuDefaultFarRadius;
    self.timeOffset = kHLMRadiateMenuDefaultTimeOffset;
    self.rotateAngle = kHLMRadiateMenuDefaultRotateAngle;
    self.menuWholeAngle = kHLMRadiateMenuDefaultMenuWholeAngle;
    self.startPoint = CGPointMake(kHLMRadiateMenuDefaultStartPointX, kHLMRadiateMenuDefaultStartPointY);
    self.expandRotation = kHLMRadiateMenuDefaultExpandRotation;
    self.closeRotation = kHLMRadiateMenuDefaultCloseRotation;
    self.animationDuration = kHLMRadiateMenuDefaultAnimationDuration;
    self.rotateAddButton = YES;
    
    _shadowViewColor = [UIColor colorWithWhite:0 alpha:0.8];
    _showGrayShadowView = YES;
    _coverNavBar = YES;
    
}

#pragma mark - UIView methods

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (_isAnimating) {
        return NO;
    }
    
    if (YES == self.isExpanded) {
        return YES;
    } else {
        return CGRectContainsPoint(self.startButton.frame, point);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    self.expanded = !self.isExpanded;
}

#pragma mark - HLMRadiateMenuItemDelegate
- (void)HLMRadiateMenuItemTouchesBegan:(HLMRadiateMenuItem *)item {
    if (item == self.startButton) {
        self.expanded = !self.isExpanded;
    }
}

- (void)HLMRadiateMenuItemTouchesEnd:(HLMRadiateMenuItem *)item {
    
    if (item == self.startButton) {
        return;
    }
    
    [self dismissSnapShotAndMaskView];
    
    CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
    [item.layer addAnimation:blowup forKey:@"blowup"];
    item.center = item.startPoint;
    
    // shrink other menu buttons
    for (int i = 0; i < self.menuItems.count; i ++) {
        HLMRadiateMenuItem *otherItem = [self.menuItems objectAtIndex:i];
        CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];
        if (otherItem.tag == item.tag) {
            continue;
        }
        [otherItem.layer addAnimation:shrink forKey:@"shrink"];
        otherItem.center = otherItem.startPoint;
    }
    _expanded = NO;
    
    
    float angle = [self isExpanded] ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:_animationDuration animations:^{
        self.startButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    if ([_delegate respondsToSelector:@selector(radiateMenu:didSelectIndex:)]) {
        [_delegate radiateMenu:self didSelectIndex:item.tag - 1000];
    }
}

- (void)setMenuItems:(NSArray *)menuItems {
    if (menuItems == _menuItems) {
        return;
    }
    _menuItems = [menuItems copy];
    
    // clean subviews
    for (UIView *v in self.subviews) {
        if (v.tag >= 1000) {
            [v removeFromSuperview];
        }
    }
}

- (HLMRadiateMenuItem *)menuItemAtIndex:(NSUInteger)index {
    if (index >= self.menuItems.count) {
        return nil;
    }
    return self.menuItems[index];
}

- (void)open {
    if (_isAnimating || self.isExpanded) {
        return;
    }
    [self setExpanded:YES];
}

- (void)close {
    if (_isAnimating || !self.isExpanded) {
        return;
    }
    [self setExpanded:NO];
}

- (void)_setMenu {
    NSUInteger count = [self.menuItems count];
    for (int i = 0; i < count; i ++) {
        HLMRadiateMenuItem *item = [self.menuItems objectAtIndex:i];
        item.tag = 1000 + i;
        item.startPoint = _startPoint;
        
        if (_menuWholeAngle >= M_PI * 2) {
            _menuWholeAngle = _menuWholeAngle - _menuWholeAngle / count;
        }
        CGPoint endPoint = CGPointMake(_startPoint.x + _endRadius * sinf(i * _menuWholeAngle / (count - 1)), _startPoint.y - _endRadius * cosf(i * _menuWholeAngle / (count - 1)));
        item.endPoint = HLMRadiateMenu_RotateCGPointAroundCenter(endPoint, _startPoint, _rotateAngle);
        CGPoint nearPoint = CGPointMake(_startPoint.x + _nearRadius * sinf(i * _menuWholeAngle / (count - 1)), _startPoint.y - _nearRadius * cosf(i * _menuWholeAngle / (count - 1)));
        item.nearPoint = HLMRadiateMenu_RotateCGPointAroundCenter(nearPoint, _startPoint, _rotateAngle);
        CGPoint farPoint = CGPointMake(_startPoint.x + _farRadius * sinf(i * _menuWholeAngle / (count - 1)), _startPoint.y - _farRadius * cosf(i * _menuWholeAngle / (count - 1)));
        item.farPoint = HLMRadiateMenu_RotateCGPointAroundCenter(farPoint, _startPoint, _rotateAngle);
        item.center = item.startPoint;
        item.delegate = self;
        [self insertSubview:item belowSubview:self.startButton];
        
        /**< 第一次添加到 view 上时即进行缩放动画， 防止 item 大小不同 startButton 不能完全遮挡 */
        if (![item.layer animationKeys]) {
            CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
            scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)], [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01, 0.01, 1.0)]];
            scaleAnimation.duration = _animationDuration/4.0;
            scaleAnimation.removedOnCompletion = NO;
            scaleAnimation.fillMode = kCAFillModeBoth;
            [item.layer addAnimation:scaleAnimation forKey:@"firstScaleAnimate"];
        }
    }
}

- (void)setExpanded:(BOOL)expanded {
    
    if (expanded) {
        [self _setMenu];
        if(self.delegate && [self.delegate respondsToSelector:@selector(radiateMenuWillAnimateOpen:)]){
            [self.delegate radiateMenuWillAnimateOpen:self];
        }
        
        [self showSnapShotAndMaskView];
    } else {
        if(self.delegate && [self.delegate respondsToSelector:@selector(radiateMenuWillAnimateClose:)]){
            [self.delegate radiateMenuWillAnimateClose:self];
        }
        [self dismissSnapShotAndMaskView];
    }
    
    _expanded = expanded;
    
    if (self.rotateAddButton) {
        float angle = [self isExpanded] ? -M_PI_4 : 0.0f;
        [UIView animateWithDuration:kHLMRadiateMenuStartMenuDefaultAnimationDuration animations:^{
            self.startButton.transform = CGAffineTransformMakeRotation(angle);
        }];
    }
    
    
    if (!_timer) {
        _flag = self.isExpanded ? 0 : (self.menuItems.count - 1);
        SEL selector = self.isExpanded ? @selector(_expandAnimation) : @selector(_closeAnimation);
        
        _timer = [NSTimer timerWithTimeInterval:_timeOffset target:self selector:selector userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        _isAnimating = YES;
    }
}

#pragma mark - Private methods

- (void)_expandAnimation {
    
    if (_flag == self.menuItems.count) {
        _isAnimating = NO;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    NSUInteger tag = 1000 + _flag;
    HLMRadiateMenuItem *item = (HLMRadiateMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01, 0.01, 1.0)], [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    scaleAnimation.duration = _animationDuration/2.0;
    
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = @[[NSNumber numberWithFloat:_expandRotation],[NSNumber numberWithFloat:0.0f]];
    rotateAnimation.duration = _animationDuration;
    rotateAnimation.keyTimes = @[
                                [NSNumber numberWithFloat:.3],
                                [NSNumber numberWithFloat:.4],
                                ];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = _animationDuration;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y);
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = @[scaleAnimation, positionAnimation, rotateAnimation];
    animationgroup.duration = _animationDuration;
    animationgroup.fillMode = kCAFillModeBoth;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = (id)self;
    if(_flag == self.menuItems.count - 1) {
        [animationgroup setValue:@"firstAnimation" forKey:@"id"];
    }
    
    [item.layer removeAllAnimations];
    [item.layer addAnimation:animationgroup forKey:@"Expand"];
    item.center = item.endPoint;
    
    _flag++;
    
}

- (void)_closeAnimation {
    if (_flag == -1) {
        _isAnimating = NO;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    NSUInteger tag = 1000 + _flag;
    HLMRadiateMenuItem *item = (HLMRadiateMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)], [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    scaleAnimation.duration = _animationDuration;
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = @[[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:_closeRotation],[NSNumber numberWithFloat:0.0f]];
    rotateAnimation.duration = _animationDuration;
    rotateAnimation.keyTimes = @[
                                [NSNumber numberWithFloat:.0],
                                [NSNumber numberWithFloat:.4],
                                [NSNumber numberWithFloat:.5],
                                ];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = _animationDuration;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = @[scaleAnimation,positionAnimation, rotateAnimation];
    animationgroup.duration = _animationDuration;
    animationgroup.removedOnCompletion = NO;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = (id)self;
    if(_flag == 0) {
        [animationgroup setValue:@"lastAnimation" forKey:@"id"];
    }
    
    [item.layer addAnimation:animationgroup forKey:@"Close"];
    item.center = item.startPoint;
    
    _flag--;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if([[anim valueForKey:@"id"] isEqual:@"lastAnimation"]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(radiateMenuDidFinishAnimationClose:)]) {
            [self.delegate radiateMenuDidFinishAnimationClose:self];
        }
    }
    if([[anim valueForKey:@"id"] isEqual:@"firstAnimation"]) {
        if(self.delegate && [self.delegate respondsToSelector:@selector(radiateMenuDidFinishAnimationOpen:)]) {
            [self.delegate radiateMenuDidFinishAnimationOpen:self];
        }
    }
}

- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p {
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(2, 2, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = _animationDuration;
    animationgroup.removedOnCompletion = NO;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p {
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = _animationDuration;
    animationgroup.removedOnCompletion = NO;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}

- (void)showSnapShotAndMaskView {
    self.maskImageView.hidden = NO;
    if (_showGrayShadowView) {
        self.shadowView.hidden = NO;
    }
    self.maskImageView.image = [self snapshotWithWindow];
    //    if ([self _viewController]) {
    //        [[self _viewController].view bringSubviewToFront:self];
    //    }
    if (_coverNavBar) {
        if ([self _viewController]) {
            if ([self _viewController].navigationController) {
                [self _viewController].navigationController.navigationBarHidden = YES;
            }
        }
    }

    
}

- (void)dismissSnapShotAndMaskView {
    self.maskImageView.hidden = YES;
    self.shadowView.hidden = YES;
    if (_coverNavBar) {
        if ([self _viewController]) {
            //             [[self _viewController].view sendSubviewToBack:self];
            if ([self _viewController].navigationController) {
                [self _viewController].navigationController.navigationBarHidden = NO;
            }
        }
    }
}

#pragma mark - Background
- (UIImage *)snapshotWithWindow {
    
    CGFloat width = self.frame.size.width;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, 64), YES, 2);
    [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImageView *)maskImageView {
    if (!_maskImageView) {
        self.maskImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 64)];
    }
    return _maskImageView;
}

- (UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        _shadowView.backgroundColor = _shadowViewColor;
        _shadowView.hidden = YES;
    }
    return _shadowView;
}

- (void)setShadowViewColor:(UIColor *)shadowViewColor {
    _shadowViewColor = shadowViewColor;
    self.shadowView.backgroundColor = self.shadowViewColor;
}

- (UIViewController *)_viewController {
    UIResponder *nextRes = [self nextResponder];
    
    do {
        if ([nextRes isKindOfClass:[UIViewController class]]) {
            return  (UIViewController *)nextRes;
            
        }
        nextRes = [nextRes nextResponder];
    } while (nextRes != nil);
    return nil;
}

#pragma mark - setter & getter
- (void)setStartPoint:(CGPoint)startPoint {
    _startPoint = startPoint;
    self.startButton.center = startPoint;
}


- (void)dealloc {
    NSLog(@"👻%s ---> %@", __PRETTY_FUNCTION__, self.class);
}

@end
