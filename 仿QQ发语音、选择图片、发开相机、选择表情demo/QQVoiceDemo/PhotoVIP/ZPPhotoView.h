//
//  ZPPhotoView.h
//  仿QQ图片选择
//
//  Created by 张鹏 on 2018/1/9.
//  Copyright © 2018年 张鹏. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kPic_Height    252.f

@interface ZPPhotoView : UIView

@property (nonatomic,strong) NSMutableArray *picImageArray;

@property (nonatomic,strong) UIViewController *superVC;

- (void)clearStates;

@end
