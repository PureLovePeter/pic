//
//  ToolViews.m
//  QQVoiceDemo
//
//  Created by 张鹏 on 2018/1/9.
//  Copyright © 2018年 张鹏. All rights reserved.
//

#import "ToolViews.h"
#import "ZPToolViewBtn.h"
#import "CWVoiceView.h"
#import "ZPAblumPhotos.h"
#import "ZPPhotoView.h"
#import "ZPPhotoHeader.h"
#import "ZPEmotionView.h"

@interface ToolViews()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

//图片
@property (nonatomic, strong) NSArray * imageArray;
@property (nonatomic, strong) NSArray * titleArray;//文字
@property (nonatomic, strong) CWVoiceView *voiceView;//声音
@property (nonatomic, strong) ZPPhotoView *photoView;//图片
@property (nonatomic, strong) ZPEmotionView *emotionView;//表情

@property (nonatomic, copy) NSString *selectTitle;//选中的btn的
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) NSMutableArray *picImageArray;
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *sizeArray;

@end

@implementation ToolViews

- (instancetype)initWithFrame:(CGRect)frame superViewController:(UIViewController *)viewController{
    self = [super initWithFrame:frame];
    if (self) {
        _viewController = viewController;
        [self setDownAnimationView:1 Annimation:NO];
        self.backgroundColor = [UIColor whiteColor];
        CGFloat btnWidth = kScreen_width/self.imageArray.count;
        for (int i = 0 ; i < self.imageArray.count; i ++) {
            UIImage *image = [UIImage imageNamed:self.imageArray[i]];
            NSString *str  = self.titleArray[i];
            ZPToolViewBtn * btn = [ZPToolViewBtn buttonWithType:UIButtonTypeCustom];
            btn.frame = CGRectMake( btnWidth * i, 0, btnWidth, kToolView_height);
            [btn backgroundRectForBounds:CGRectMake( 0, 0, btnWidth, kToolView_height)];
            [btn contentRectForBounds:CGRectMake( 0, 0, btnWidth, kToolView_height)];
            [btn setTitle:str forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexString:@"0x999999"] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor colorWithHexString:@"0x999999"] forState:UIControlStateSelected];
            btn.titleLabel.font = [UIFont systemFontOfSize:10];
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn  setImage:image forState:UIControlStateNormal];
            btn.tag = 1000 + i;
            [btn addTarget:self action:@selector(chooseBtn:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
        _dataArr = [NSMutableArray array];
        _sizeArray = [NSMutableArray array];
        _picImageArray = [NSMutableArray array];

        if ([PHPhotoLibrary authorizationStatus] == PHAuthorizationStatusAuthorized) {
            [self loadAssets];
        }else{
            [MBProgressHUD showHudAutoDisappear:nil text:@"请打开访问相册权限"];
        }
    }
   return self;
}

- (NSArray *)imageArray{
    if (!_imageArray) {
        _imageArray = @[@"mes_voice",@"mes_pic",@"mes_camer",@"mes_face",@"mes_resume",@"mes_position",@"mes_order"];
    }
    return _imageArray;
}

- (NSArray *)titleArray{
    if (!_titleArray) {
        _titleArray = @[kmes_voice,kmes_pic,kmes_camer,kmes_face,kmes_resume,kmes_position,kmes_order];
    }
    return _titleArray;
}

- (void)setUpAnimationView:(ToolviewType)type{
    switch (type) {
        case ToolviewType_Voice:
        {
            [_photoView clearStates];
            [_viewController.view addSubview:self.voiceView];
            [UIView animateWithDuration:0.25 animations:^{
                self.frame = CGRectMake(0, kScreen_height - kToolView_height - kBottom_Height, kScreen_width, kToolView_height);
                _voiceView.frame = CGRectMake(0, kScreen_height - kBottom_Height, kScreen_width, kBottom_Height);
            }];
        }
        break;
        case ToolviewType_Pic:
        {
            [_photoView clearStates];
            [_viewController.view addSubview:self.photoView];
            [UIView animateWithDuration:0.25 animations:^{
                self.frame = CGRectMake(0, kScreen_height - kToolView_height - kBottom_Height, kScreen_width, kToolView_height);
                _photoView.frame = CGRectMake(0, kScreen_height - kBottom_Height, kScreen_width, kBottom_Height);
            }];
            
        }
            break;
        case ToolviewType_Face:
        {
            [_photoView clearStates];
            [_viewController.view addSubview:self.emotionView];
            [UIView animateWithDuration:0.25 animations:^{
                self.frame = CGRectMake(0, kScreen_height - kToolView_height - kBottom_Height, kScreen_width, kToolView_height);
                _emotionView.frame = CGRectMake(0, kScreen_height - kBottom_Height, kScreen_width, kBottom_Height);
            }];
            
        }
            break;
        case ToolviewType_Camera:
        case ToolviewType_Resume:
        case ToolviewType_Position:
        case ToolviewType_Order:
            break;
        default:
            break;
    }
}

- (void)setDownAnimationView:(ToolviewType)type Annimation:(BOOL)annimation{
    if (annimation) {
        switch (type) {
            case ToolviewType_Voice:
            {
                [UIView animateWithDuration:0.25 animations:^{
                    self.frame = CGRectMake(0, kScreen_height - kToolView_height , kScreen_width, kToolView_height);
                _voiceView.frame = CGRectMake(0, kScreen_height, kScreen_width, kBottom_Height);
                }completion:^(BOOL finished) {
                    [_photoView clearStates];
                    [_voiceView removeFromSuperview];
                }];
            }
                break;
            case ToolviewType_Pic:
            {
                [UIView animateWithDuration:0.25 animations:^{
                    self.frame = CGRectMake(0, kScreen_height - kToolView_height , kScreen_width, kToolView_height);
                    _photoView.frame = CGRectMake(0, kScreen_height, kScreen_width, kBottom_Height);
                }completion:^(BOOL finished) {
                    [_photoView clearStates];
                    [_photoView removeFromSuperview];
                }];
                
            }
                break;
            case ToolviewType_Face:
            {
                [UIView animateWithDuration:0.25 animations:^{
                    self.frame = CGRectMake(0, kScreen_height - kToolView_height , kScreen_width, kToolView_height);
                    _emotionView.frame = CGRectMake(0, kScreen_height, kScreen_width, kBottom_Height);
                }completion:^(BOOL finished) {
                    [_photoView clearStates];
                    [_emotionView removeFromSuperview];
                }];
            }
                break;
            case ToolviewType_Camera:
            case ToolviewType_Resume:
            case ToolviewType_Position:
            case ToolviewType_Order:
                break;
            default:
                break;
        }
    }else{
        self.frame = CGRectMake(0, kScreen_height - kToolView_height , kScreen_width, kToolView_height);
    }
}

- (void)changeUpView:(ToolviewType)type{
    switch (type) {
        case ToolviewType_Voice:
        {
            [self clearViews];
            [_viewController.view addSubview:self.voiceView];
            _voiceView.frame = CGRectMake(0, kScreen_height - kBottom_Height, kScreen_width, kBottom_Height);

        }
            break;
        case ToolviewType_Pic:
        {
            [self clearViews];
            [_viewController.view addSubview:self.photoView];
            _photoView.frame = CGRectMake(0, kScreen_height - kBottom_Height, kScreen_width, kBottom_Height);
        }
            break;
        case ToolviewType_Face:
        {
            [self clearViews];
            [_viewController.view addSubview:self.emotionView];
            _emotionView.frame = CGRectMake(0, kScreen_height - kBottom_Height, kScreen_width, kBottom_Height);
            
        }
        case ToolviewType_Camera:
        case ToolviewType_Resume:
        case ToolviewType_Position:
        case ToolviewType_Order:
            break;
        default:
            break;
    }
}

- (void)clearViews{
    [_voiceView removeFromSuperview];
    _voiceView = nil;
    [_photoView clearStates];
    [_photoView removeFromSuperview];
    _photoView = nil;
}

- (void)chooseBtn:(UIButton *)sender{
    NSArray *changeViewArray = @[kmes_voice,kmes_pic,kmes_face];//声音，图片，表情需要切换视图
    NSString *str = sender.titleLabel.text;
    if ([changeViewArray containsObject:str]) {
        if (_selectTitle&&[_selectTitle isEqualToString:str]) {
            _selectTitle = nil;
            [self setDownAnimationView:sender.tag - 1000 Annimation:YES];
        }else if(_selectTitle&&![_selectTitle isEqualToString:str]){
            [self changeUpView:sender.tag - 1000];
            _selectTitle = str;
        }else{
            [self setUpAnimationView:sender.tag - 1000];
            _selectTitle = str;
        }
    }else{
        if ([str isEqualToString:kmes_camer]) {
            [self openCarema];// 拍照
        }else if ([str isEqualToString:kmes_resume]){
            
        }else if ([str isEqualToString:kmes_position]){
            
        }else if ([str isEqualToString:kmes_order]){
            
        }
    }
}

#pragma mark --- setter getter
- (CWVoiceView *)voiceView{
    if (!_voiceView) {
        _voiceView = [[CWVoiceView alloc] initWithFrame:CGRectMake(0, kScreen_height ,kScreen_width, kBottom_Height)];
    }
    return _voiceView;
}

- (ZPPhotoView *)photoView{
    if (!_photoView) {
        _photoView = [[ZPPhotoView alloc]initWithFrame:CGRectMake(0, kScreen_height, kScreen_width, kPic_Height)];
        _photoView.picImageArray = self.picImageArray;
        _photoView.superVC = self.viewController;
    }
    return _photoView;
}

- (ZPEmotionView *)emotionView{
    if (!_emotionView) {
        _emotionView = [[ZPEmotionView alloc]initWithFrame:CGRectMake(0, kScreen_height, kScreen_width, kBottom_Height)];
    }
    return _emotionView;
}


#pragma mark ---- 加载缩略图片
- (void)loadAssets {
    [_dataArr addObjectsFromArray:[[ZPAblumPhotos shareAblumPhoto] getAllAssetInPhotoAblumWithAscending:NO]];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (PHAsset *sset in _dataArr) {
            [self getImageWithAsset:sset completion:^(UIImage *image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_picImageArray addObject:image];
                    if (_photoView) {
                        _photoView.picImageArray = self.picImageArray;
                    }
                });
            }];
        }
    });
}

//从这个回调中获取所有的图片
- (void)getImageWithAsset:(PHAsset *)asset completion:(void (^)(UIImage *image))completion
{
    CGSize size = [self getSizeWithAsset:asset];
    [[ZPAblumPhotos shareAblumPhoto] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completion:completion];
}

#pragma mark - 获取图片及图片尺寸的相关方法
- (CGSize)getSizeWithAsset:(PHAsset *)asset
{
    CGFloat width  = (CGFloat)asset.pixelWidth;
    CGFloat height = (CGFloat)asset.pixelHeight;
    CGFloat scale = width/height;
    [_sizeArray addObject:@(208*scale)];
    return CGSizeMake(208*scale, 208);
}

#pragma mark- 打开摄像头拍照
-(void)openCarema
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.viewController presentViewController:picker animated:YES completion:^{}];
    }else{
        //如果没有提示用户
        [MBProgressHUD showHudAutoDisappear:nil text:@"请打开访问相机权限"];
    }
}

#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
    
    UIImage *image = info[UIImagePickerControllerOriginalImage];

}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.viewController dismissViewControllerAnimated:YES completion:nil];
}
@end
