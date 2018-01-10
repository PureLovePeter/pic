//
//  ZPPicCollectionViewCell.m
//  QQVoiceDemo
//
//  Created by 张鹏 on 2018/1/9.
//  Copyright © 2018年 张鹏. All rights reserved.
//

#import "ZPPicCollectionViewCell.h"

@interface ZPPicCollectionViewCell()

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,strong) UILabel *selectLabel;

@end

@implementation ZPPicCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc]init];
        [self addSubview:_imageView];
        
        _selectLabel = [[UILabel alloc]init];
        _selectLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _selectLabel.layer.masksToBounds = YES;
        _selectLabel.layer.cornerRadius = 11;
        _selectLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        _selectLabel.layer.borderWidth = 1;
        _selectLabel.textAlignment = NSTextAlignmentCenter;
        _selectLabel.textColor = [UIColor whiteColor];
        _selectLabel.text = @"";
        [self addSubview:_selectLabel];
    }
    return self;
}

- (void)setAblumModel:(ZPAblumModel *)ablumModel{
    _ablumModel = ablumModel;
    _imageView.frame = ablumModel.imageRect;
    _imageView.image = ablumModel.imagePic;
    _selectLabel.frame = CGRectMake(ablumModel.imageRect.size.width - 22 - 5, 5, 22, 22);
    if (ablumModel.text&&![ablumModel.text isEqualToString:@""]) {
        _selectLabel.text = ablumModel.text;
        _selectLabel.backgroundColor = [UIColor colorWithHexString:@"0x3592EC"];
    }else{
        _selectLabel.text = @"";
        _selectLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    }

    
}
@end
