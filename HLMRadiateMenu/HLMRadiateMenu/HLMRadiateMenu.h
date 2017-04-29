//
//  HLMRadiateMenu.h
//  AwesomeMenu
//
//  Created by Jacob on 2017/4/27.
//  Copyright © 2017年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HLMRadiateMenuItem.h"

@class HLMRadiateMenu;

@protocol HLMRadiateMenuDelegate <NSObject>

- (void)radiateMenu:(HLMRadiateMenu *)menu didSelectIndex:(NSInteger)idx;

@optional
- (void)radiateMenuDidFinishAnimationClose:(HLMRadiateMenu *)menu;
- (void)radiateMenuDidFinishAnimationOpen:(HLMRadiateMenu *)menu;
- (void)radiateMenuWillAnimateOpen:(HLMRadiateMenu *)menu;
- (void)radiateMenuWillAnimateClose:(HLMRadiateMenu *)menu;

@end

@interface HLMRadiateMenu : UIView

@property (nonatomic, copy) NSArray *menuItems;
@property (nonatomic, strong) HLMRadiateMenuItem *startButton;

@property (nonatomic, getter = isExpanded) BOOL expanded;
@property (nonatomic, weak) id<HLMRadiateMenuDelegate> delegate;

@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGPoint startPoint; /**< 开始按钮的位置 */
@property (nonatomic, assign) CGFloat timeOffset; /**< 相邻 item 弹出时间差 */
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat menuWholeAngle;
@property (nonatomic, assign) CGFloat expandRotation;
@property (nonatomic, assign) CGFloat closeRotation;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) BOOL    rotateAddButton;

@property (nonatomic, assign) BOOL equalSize; /**< Items 的 size 是否一样 defalut Yes*/
@property (nonatomic, strong) UIColor *shadowViewColor; /**< default color is white:0 alpha:0.8 */
@property (nonatomic, assign) BOOL showGrayShadowView; /**< 是否展示灰色shadowView default yes */
@property (nonatomic, assign) BOOL coverNavBar; /**< GrayShadowView是否把NavBar遮挡 */

/**< 弹出的 item size 小于等于 startItem 使用 */
- (id)initWithFrame:(CGRect)frame startItem:(HLMRadiateMenuItem *)startItem menuItems:(NSArray *)menuItems;

- (HLMRadiateMenuItem *)menuItemAtIndex:(NSUInteger)index;

- (void)open;

- (void)close;

@end
