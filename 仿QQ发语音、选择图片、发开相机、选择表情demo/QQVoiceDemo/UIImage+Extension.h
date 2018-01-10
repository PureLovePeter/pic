//
//  UIImage+Extension.h
//  headhunter
//
//  Created by 武恩泽 on 15/5/13.
//  Copyright (c) 2015年 HunterOn. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)

+ (UIImage*) createImageWithColor: (UIColor*) color;
+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;
@end
