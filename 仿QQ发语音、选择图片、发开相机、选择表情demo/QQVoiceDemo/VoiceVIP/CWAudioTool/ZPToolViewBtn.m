//
//  ZPToolViewBtn.m
//  QQVoiceDemo
//
//  Created by 张鹏 on 2018/1/9.
//  Copyright © 2018年 张鹏. All rights reserved.
//

#import "ZPToolViewBtn.h"

#define ImageWidth 25.f

@implementation ZPToolViewBtn

- (CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    return CGRectMake((contentRect.size.width - ImageWidth)/2.0f, 10, ImageWidth, ImageWidth);
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    
    return CGRectMake(0, 15 + ImageWidth, contentRect.size.width, 13);
}

@end
