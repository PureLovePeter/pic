//
//  ToolViews.h
//  QQVoiceDemo
//
//  Created by 张鹏 on 2018/1/9.
//  Copyright © 2018年 张鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ToolviewType_Voice,//声音
    ToolviewType_Pic,  //照片
    ToolviewType_Camera,//相机
    ToolviewType_Face,  //表情
    ToolviewType_Resume, //简历
    ToolviewType_Position,//职位
    ToolviewType_Order, //订单
} ToolviewType;

#define kScreen_width [UIScreen mainScreen].bounds.size.width
#define kScreen_height [UIScreen mainScreen].bounds.size.height
#define kToolView_height 60.f
#define kBottom_Height    252.f

#define kmes_voice    @"语音"
#define kmes_pic      @"图片"
#define kmes_camer    @"拍摄"
#define kmes_face     @"表情"
#define kmes_resume   @"简历"
#define kmes_position @"职位"
#define kmes_order    @"订单"

@interface ToolViews : UIView

- (instancetype)initWithFrame:(CGRect)frame superViewController:(UIViewController *)viewController;

@property (nonatomic, assign) ToolviewType type;

@end
