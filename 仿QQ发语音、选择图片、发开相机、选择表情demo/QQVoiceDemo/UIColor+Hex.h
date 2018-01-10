//
//  UIColor+Hex.h
//  headhunter
//
//  Created by hfzhangzhang on 15/5/13.
//  Copyright (c) 2015年 HunterOn. All rights reserved.
//
#define RGBA_COLOR(R, G, B, A) [UIColor colorWithRed:((R) / 255.0f) green:((G) / 255.0f) blue:((B) / 255.0f) alpha:A]
#define RGB_COLOR(R, G, B) [UIColor colorWithRed:((R) / 255.0f) green:((G) / 255.0f) blue:((B) / 255.0f) alpha:1.0f]

#import <UIKit/UIKit.h>

@interface UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)color;

//从十六进制字符串获取颜色，
//color:支持@“#123456”、 @“0X123456”、 @“123456”三种格式
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;









/**
 *  颜色转化成RGB值组成的数组
 *
 *  @param color 待转化的颜色
 *
 *  @return 转化后的数组
 */
+ (NSArray *)separationColorToRGB:(UIColor *)color;



/**
 *  插值两种颜色返回中间的颜色
 *
 *  @param from  起始颜色
 *  @param to    终止颜色
 *  @param ratio 插值比例
 *
 *  @return 插值色
 */
+ (UIColor *)colorWIthInterpolationFromValue:(UIColor *)fromValue toValue:(UIColor *)toValue ratio:(CGFloat)ratio;







@end
