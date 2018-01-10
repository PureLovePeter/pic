//
//  ZPEmotionPageView.m
//  QQVoiceDemo
//
//  Created by 张鹏 on 2018/1/9.
//  Copyright © 2018年 张鹏. All rights reserved.
//

#import "ZPEmotionPageView.h"

@interface ZPEmotionPageView()
/** 删除按钮 */
@property (nonatomic, strong) UIButton *deleteButton;
@end

@implementation ZPEmotionPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // 1.删除按钮
        [self addSubview:self.deleteButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 内边距(四周)
    CGFloat inset = 20;
    NSUInteger count = self.emotions.count;
    CGFloat btnW = (self.width - 2 * inset) / RSEmotionMaxCols;
    CGFloat btnH = (self.height - inset) / RSEmotionMaxRows;
    for (int i = 0; i<count; i++) {
        UIButton *btn = self.subviews[i + 1];
        btn.width = btnW;
        btn.height = btnH;
        btn.x = inset + (i%RSEmotionMaxCols) * btnW;
        btn.y = inset + (i/RSEmotionMaxCols) * btnH;
    }
    
    // 删除按钮
    self.deleteButton.width = 25;
    self.deleteButton.height = 25;
    
    self.deleteButton.y = self.height - btnH + (btnH - 25)/2.0f;
    self.deleteButton.x = self.width - inset - btnW;
}

#pragma mark- private event
/**
 *  监听删除按钮点击
 */
- (void)deleteClick
{

}

- (void)btnClick:(UIButton *)btn
{

}

/**
 *  选中某个表情，发出通知
 *
 *  @param emotion 被选中的表情
 */
- (void)selectEmotion:(UIButton *)emotion
{
   
}

#pragma mark- setters and getters
- (void)setEmotions:(NSArray *)emotions
{
    _emotions = emotions;
    NSUInteger count = emotions.count;
    for (int i = 0; i<count; i++) {
        NSDictionary *dic = emotions[i];
        UIButton *btn = [[UIButton alloc] init];
        NSString *imageName = [NSString stringWithFormat:@"%@",dic[@"imageName"]];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:dic[@"text"] forState:UIControlStateNormal];
        btn.titleLabel.alpha = 0;
        [self addSubview:btn];
    }
}

- (UIButton *)deleteButton{
    if (_deleteButton == nil) {
        _deleteButton = [[UIButton alloc] init];
        [_deleteButton setImage:[UIImage imageNamed:@"emotion_delete_highlighted"] forState:UIControlStateHighlighted];
        [_deleteButton setImage:[UIImage imageNamed:@"emotion_delete"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}

@end
