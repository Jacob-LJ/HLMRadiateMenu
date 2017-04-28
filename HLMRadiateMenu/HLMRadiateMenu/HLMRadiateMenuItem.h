//
//  HLMRadiateMenuItem.h
//  AwesomeMenu
//
//  Created by Jacob on 2017/4/27.
//  Copyright © 2017年 Jacob. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HLMRadiateMenuItem;

@protocol HLMRadiateMenuItemDelegate <NSObject>

- (void)HLMRadiateMenuItemTouchesBegan:(HLMRadiateMenuItem *)item;
- (void)HLMRadiateMenuItemTouchesEnd:(HLMRadiateMenuItem *)item;

@end

@interface HLMRadiateMenuItem : UIView

@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGPoint nearPoint;
@property (nonatomic) CGPoint farPoint;

@property (nonatomic, weak) id<HLMRadiateMenuItemDelegate> delegate;

@end
