//
//  ViewController.m
//  HLMRadiateMenu
//
//  Created by Jacob on 2017/4/28.
//  Copyright © 2017年 Jacob. All rights reserved.
//

#import "ViewController.h"
#import "HLMRadiateMenu.h"

@interface ViewController ()<HLMRadiateMenuDelegate>

@property (nonatomic, weak) HLMRadiateMenu *menu;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    HLMRadiateMenuItem *item1 = [[HLMRadiateMenuItem alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    item1.backgroundColor = [UIColor redColor];
    item1.layer.cornerRadius = 25.0;
    item1.layer.masksToBounds = YES;
    
    HLMRadiateMenuItem *item2 = [[HLMRadiateMenuItem alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    item2.backgroundColor = [UIColor yellowColor];
    item2.layer.cornerRadius = 50.0;
    item2.layer.masksToBounds = YES;
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 100, 30)];
    label2.text = @"中间按钮";
    label2.textAlignment = NSTextAlignmentCenter;
    label2.backgroundColor = [UIColor orangeColor];
    [item2 addSubview:label2];
    
    HLMRadiateMenuItem *item3 = [[HLMRadiateMenuItem alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    item3.backgroundColor = [UIColor blueColor];
    item3.layer.cornerRadius = 25.0;
    item3.layer.masksToBounds = YES;
    
    HLMRadiateMenuItem *startItem = [[HLMRadiateMenuItem alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    startItem.backgroundColor = [UIColor purpleColor];
    startItem.layer.cornerRadius = 25.0;
    startItem.layer.masksToBounds = YES;
    
    
    
    HLMRadiateMenu *hlmMenu = [[HLMRadiateMenu alloc] initWithFrame:self.view.bounds startItem:startItem menuItems:@[item1, item2, item3]];
    
    hlmMenu.delegate = self;
    
    hlmMenu.nearRadius = 90.0f;
    hlmMenu.endRadius = 100.0f;
    hlmMenu.farRadius = 110.0f;
    hlmMenu.startPoint = CGPointMake(200.0, 350.0);
    hlmMenu.animationDuration = 0.3f;
    hlmMenu.timeOffset = 0.1;
    hlmMenu.menuWholeAngle = M_PI * (3.0/5.0);
    hlmMenu.rotateAngle = -(M_PI_2 * (54.0/90.0));
    
    [self.view addSubview:hlmMenu];
    self.menu = hlmMenu;
}

- (void)radiateMenu:(HLMRadiateMenu *)menu didSelectIndex:(NSInteger)idx {
    NSLog(@"Select the index : %ld",idx);
}

- (void)radiateMenuDidFinishAnimationClose:(HLMRadiateMenu *)menu {
    NSLog(@"Menu was closed!");
}
- (void)radiateMenuDidFinishAnimationOpen:(HLMRadiateMenu *)menu {
    NSLog(@"Menu is open!");
}
- (void)radiateMenuWillAnimateOpen:(HLMRadiateMenu *)menu {
    NSLog(@"radiateMenuWillAnimateOpen");
}
- (void)radiateMenuWillAnimateClose:(HLMRadiateMenu *)menu {
    NSLog(@"radiateMenuWillAnimateClose");
}




- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"disnji");
}

@end
