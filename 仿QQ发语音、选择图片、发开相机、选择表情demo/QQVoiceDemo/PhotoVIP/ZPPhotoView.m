//
//  ZPPhotoView.m
//  仿QQ图片选择
//
//  Created by 张鹏 on 2018/1/9.
//  Copyright © 2018年 张鹏. All rights reserved.
//

#import "ZPPhotoView.h"
#import "ZPPicCollectionViewCell.h"
#import "ZPAblumModel.h"

#define kScreen_width [UIScreen mainScreen].bounds.size.width
#define kScreen_height [UIScreen mainScreen].bounds.size.height
#define kColor_left @"0x3592EC"
#define kColor_right_nomal @"0x3592EC"
#define kColor_right_disable @"0xEBF4FD"

@interface ZPPhotoView()<UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic,retain) NSMutableArray *imageArray;

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic,strong) NSMutableArray *selectImageArray;

@property (nonatomic,strong) UIButton *leftBtn;

@property (nonatomic,strong) UIButton *rightBtn;

@end;

@implementation ZPPhotoView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _selectImageArray = [NSMutableArray array];
        [self addSubview:self.collectionView];
        [self addSubview:self.leftBtn];
        [self addSubview:self.rightBtn];
    }
    return self;
}
- (UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreen_width, kPic_Height - 44) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[ZPPicCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

//设置分区数（必须实现）
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat imageHeight = 208;
    UIImage *image = self.picImageArray[indexPath.row];
    return CGSizeMake(image.size.width *imageHeight/image.size.height, imageHeight);
}

//设置每个分区的item个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.picImageArray.count;
}

//设置返回每个item的属性必须实现）
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZPPicCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    CGFloat imageHeight = 208;
    UIImage *image = self.picImageArray[indexPath.row];
    ZPAblumModel *model = [[ZPAblumModel alloc]init];
    if ([_selectImageArray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
       NSInteger index = [_selectImageArray indexOfObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        model.text = [NSString stringWithFormat:@"%ld",(long)index + 1];
    }else{
        model.text = @"";
    }
    model.imagePic = image;
    model.imageRect = CGRectMake(0,0,image.size.width *imageHeight/image.size.height, imageHeight);
    cell.ablumModel = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    if([_selectImageArray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]){
        [_selectImageArray removeObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }else{
        [_selectImageArray addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
    }
    [collectionView reloadData];
}


- (void)setPicImageArray:(NSMutableArray *)picImageArray{
    _picImageArray = picImageArray;
    [self.collectionView reloadData];
}

#pragma mark --- getter setter

- (UIButton *)leftBtn{
    if (!_leftBtn) {
        _leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftBtn.frame = CGRectMake(0, CGRectGetMaxY(self.collectionView.frame), 66, 44);
        [_leftBtn setTitle:@"相册" forState:UIControlStateNormal];
        [_leftBtn setTitleColor:[UIColor colorWithHexString:kColor_left] forState:UIControlStateNormal];
        _leftBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_leftBtn addTarget:self action:@selector(gotoPhotos:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftBtn;
}

- (UIButton *)rightBtn{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(kScreen_width - 10 - 68, CGRectGetMaxY(self.collectionView.frame) + 7, 68, 30);
        [_rightBtn setTitle:@"发送" forState:UIControlStateNormal];
        [_rightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _rightBtn.layer.masksToBounds = YES;
        _rightBtn.layer.cornerRadius = 2;
        [_rightBtn setBackgroundColor:[UIColor colorWithHexString:kColor_right_nomal] forState:UIControlStateNormal];
        [_rightBtn setBackgroundColor:[UIColor colorWithHexString:kColor_right_disable] forState:UIControlStateDisabled];
        [_rightBtn addTarget:self action:@selector(sendPic:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

#pragma mark - 调用本地相册
- (void)gotoPhotos:(UIButton *)sender{
    _leftBtn.enabled = NO;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self.superVC presentViewController:picker animated:YES completion:^{
            _leftBtn.enabled = YES;
        }];
    }else{
        //如果没有提示用户
        [MBProgressHUD showHudAutoDisappear:nil text:@"请打开访问相册权限"];
        _leftBtn.enabled = YES;
    }
}

- (void)sendPic:(UIButton *)sender{
    
}
//清空选中状态
- (void)clearStates{
    [_selectImageArray removeAllObjects];
    [self.collectionView reloadData];
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.superVC dismissViewControllerAnimated:YES completion:nil];
}

@end
