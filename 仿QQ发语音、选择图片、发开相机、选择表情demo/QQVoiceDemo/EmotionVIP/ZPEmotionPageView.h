//
//  ZPEmotionPageView.h
//  QQVoiceDemo
//
//  Created by 张鹏 on 2018/1/9.
//  Copyright © 2018年 张鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

// 一页中最多3行
#define RSEmotionMaxRows 3
// 一行中最多7列
#define RSEmotionMaxCols 8
// 每一页的表情个数
#define RSEmotionPageSize ((RSEmotionMaxRows * RSEmotionMaxCols) - 1)

@interface ZPEmotionPageView : UIView

@property (nonatomic, strong) NSArray *emotions;

@end
