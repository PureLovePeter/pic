//
//  UIColor+Hex.m
//  headhunter
//
//  Created by hfzhangzhang on 15/5/13.
//  Copyright (c) 2015年 HunterOn. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    //如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    //如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color
{
    return [self colorWithHexString:color alpha:1.0f];
}



+ (NSArray *)separationColorToRGB:(UIColor *)color
{
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel, 1, 1, 8, 4, rgbColorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    return @[@(resultingPixel[0]/255.0f),@(resultingPixel[1]/255.0f),@(resultingPixel[2]/255.0f)];
}



+ (UIColor *)colorWIthInterpolationFromValue:(UIColor *)fromValue toValue:(UIColor *)toValue ratio:(CGFloat)ratio
{
    NSArray *fromColorArray = [self separationColorToRGB:fromValue];
    NSArray *toColorArray = [self separationColorToRGB:toValue];
    CGFloat red = [self interpolationFromValue:[fromColorArray[0] floatValue] toValue:[toColorArray[0] floatValue] ratio:ratio];
    CGFloat green = [self interpolationFromValue:[fromColorArray[1] floatValue] toValue:[toColorArray[1] floatValue] ratio:ratio];
    CGFloat blue = [self interpolationFromValue:[fromColorArray[2] floatValue] toValue:[toColorArray[2] floatValue] ratio:ratio];
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0f];
}



+ (CGFloat)interpolationFromValue:(CGFloat)from toValue:(CGFloat)to ratio:(CGFloat)ratio
{
    return from + (to - from) * ratio;
}


@end
