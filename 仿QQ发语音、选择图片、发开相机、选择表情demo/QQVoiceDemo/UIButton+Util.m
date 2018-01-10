
//
//  UIButton+Util.m
//  headhunter
//
//  Created by hfzhangzhang on 15/5/13.
//  Copyright (c) 2015年 HunterOn. All rights reserved.
//

#import "UIButton+Util.h"
#import "UIImage+Extension.h"

@implementation UIButton (Util)

- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state
{
    UIImage *image =[UIImage createImageWithColor:color];
    [self setBackgroundImage:image forState:state];
}

/**
 *  初始化底部按钮
 *
 *  @param title  按钮title
 *  @param target target
 *  @param action action
 *
 *  @return self
 */
+ (UIButton *)bottomBtnWithTitle:(NSString *)title target:(id)target action:(SEL)action
{
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width -2*15, 44); //fetch default frame
    [btn setBackgroundColor:[UIColor colorWithHexString:@"ee424a"] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithHexString:@"d44442"] forState:UIControlStateHighlighted];
    [btn setBackgroundColor:[[UIColor colorWithHexString:@"fb4748"] colorWithAlphaComponent:0.3] forState:UIControlStateDisabled];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:17];
    btn.layer.cornerRadius = 4;
    btn.clipsToBounds = YES;
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


//竖向排版UIButton中的图片和文字
- (void)verticalImageAndTitle:(CGFloat)spacing
{
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    CGSize textSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height), 0);
    
}




@end
