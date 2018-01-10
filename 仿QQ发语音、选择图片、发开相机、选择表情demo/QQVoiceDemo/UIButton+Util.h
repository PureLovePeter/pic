//
//  UIButton+Util.h
//  headhunter
//
//  Created by hfzhangzhang on 15/5/13.
//  Copyright (c) 2015年 HunterOn. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIButton (Util)
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state;

+ (UIButton *)bottomBtnWithTitle:(NSString *)title target:(id)target action:(SEL)action;


//竖向排版UIButton中的图片和文字
- (void)verticalImageAndTitle:(CGFloat)spacing;


@end
