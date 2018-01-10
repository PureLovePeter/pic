//
//  ZPAblumModel.h
//  仿QQ图片选择
//
//  Created by 张鹏 on 2017/12/18.
//  Copyright © 2017年 张鹏. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@interface ZPAblumModel : NSObject
/*相册名字*/
@property (nonatomic, copy)   NSString *title;
/*该相册内相片数量*/
@property (nonatomic, assign) NSInteger count;
/*相册第一张图片缩略图*/
@property (nonatomic, strong) PHAsset *headImageAsset;
/*相册集，通过该属性获取该相册集下所有照片*/
@property (nonatomic, strong) PHAssetCollection *assetCollection;

/**图片大小**/
@property (nonatomic,assign) CGRect imageRect;
/***coloction图片**/
@property (nonatomic,strong) UIImage *imagePic;
/*是否选中*/
@property (nonatomic,assign) NSString * text;
@end
