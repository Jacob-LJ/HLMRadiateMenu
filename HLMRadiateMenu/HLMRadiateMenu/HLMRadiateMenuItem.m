//
//  HLMRadiateMenuItem.m
//  AwesomeMenu
//
//  Created by Jacob on 2017/4/27.
//  Copyright © 2017年 Jacob. All rights reserved.
//

#import "HLMRadiateMenuItem.h"

static inline CGRect HLMRadiateMenuItem_ScaleRect(CGRect rect, float n) {
    CGFloat x = (rect.size.width - rect.size.width * n) / 2;
    CGFloat y = (rect.size.height - rect.size.height * n) / 2;
    CGFloat width = rect.size.width * n;
    CGFloat heitht = rect.size.height * n;
    return CGRectMake(x, y, width, heitht);
}

@implementation HLMRadiateMenuItem

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([_delegate respondsToSelector:@selector(HLMRadiateMenuItemTouchesBegan:)]) {
        [_delegate HLMRadiateMenuItemTouchesBegan:self];
    }
    
}

//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
//    // if move out of 2x rect, cancel highlighted.
//    CGPoint location = [[touches anyObject] locationInView:self];
//    if (!CGRectContainsPoint(HLMRadiateMenuItem_ScaleRect(self.bounds, 2.0f), location)) {
//        
//    }
//    
//}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // if stop in the area of 2x rect, response to the touches event.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(HLMRadiateMenuItem_ScaleRect(self.bounds, 2.0f), location)) {
        if ([_delegate respondsToSelector:@selector(HLMRadiateMenuItemTouchesEnd:)]) {
            [_delegate HLMRadiateMenuItemTouchesEnd:self];
        }
    }
}

//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
//    
//}

@end
