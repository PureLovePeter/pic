//
//  ZPEmotionView.m
//  QQVoiceDemo
//
//  Created by 张鹏 on 2018/1/9.
//  Copyright © 2018年 张鹏. All rights reserved.
//

#import "ZPEmotionView.h"
#import "ZPEmotionPageView.h"

@interface ZPEmotionView()<UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, copy)   NSArray *emotions;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *sendButton;
@end

@implementation ZPEmotionView

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"0xf4f4f4"];
        // 1.UIScollView
        [self addSubview:self.scrollView];
        
        [self addSubview:self.pageControl];
        
        [self addPageViews];
        
        [self addSubview:self.bottomView];
    }
    return self;
}

// 根据emotions，创建对应个数的表情
- (void)addPageViews
{
    // 删除之前的控件
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSUInteger count = (self.emotions.count + RSEmotionPageSize - 1) / RSEmotionPageSize;
    
    // 1.设置页数
    self.pageControl.numberOfPages = count;
    
    // 2.创建用来显示每一页表情的控件
    for (int i = 0; i<count; i++) {
        ZPEmotionPageView *pageView = [[ZPEmotionPageView alloc] init];
        // 计算这一页的表情范围
        NSRange range;
        pageView.backgroundColor = [UIColor colorWithHexString:@"0xf4f4f4"];
        range.location = i * RSEmotionPageSize;
        // left：剩余的表情个数（可以截取的）
        NSUInteger left = self.emotions.count - range.location;
        if (left >= RSEmotionPageSize) { // 这一页足够20个
            range.length = RSEmotionPageSize;
        } else {
            range.length = left;
        }
        // 设置这一页的表情
        pageView.emotions = [self.emotions subarrayWithRange:range];
        [self.scrollView addSubview:pageView];
    }
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    // 1.scrollView
    // 2.pageControl
    // 3.设置scrollView内部每一页的尺寸
    NSUInteger count = self.scrollView.subviews.count;
    for (int i = 0; i<count; i++) {
        ZPEmotionPageView *pageView = self.scrollView.subviews[i];
        pageView.height = 170; //self.scrollView.height;
        pageView.width = self.scrollView.width;
        pageView.x = pageView.width * i;
        pageView.y = 0;
    }
    
    // 4.设置scrollView的contentSize
    self.scrollView.contentSize = CGSizeMake(count * self.scrollView.width, 0);
}

#pragma mark- private methods
- (void)sendButtonClick{

}

#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    double pageNo = scrollView.contentOffset.x / scrollView.width;
    self.pageControl.currentPage = (int)(pageNo + 0.5);
}

#pragma mark- setters and getters
- (UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.frame = CGRectMake(0, 0, self.width, 170);
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIPageControl *)pageControl{
    if (_pageControl == nil) {
        // 2.pageControl
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.frame = CGRectMake(0, CGRectGetMaxY(self.scrollView.frame), self.width, 38);
        _pageControl.backgroundColor = [UIColor colorWithHexString:@"0xf4f4f4"];
        _pageControl.hidesForSinglePage = YES;
        _pageControl.userInteractionEnabled = NO;
        _pageControl.currentPageIndicatorTintColor = [UIColor colorWithHexString:@"0x666666"];
        _pageControl.pageIndicatorTintColor = [UIColor colorWithHexString:@"0x999999"];
        // 设置内部的圆点图片
        [self addSubview:_pageControl];
        self.pageControl = _pageControl;
    }
    return _pageControl;
}

- (NSArray *)emotions{
    if (_emotions ==  nil   ) {
        NSString* path=[[NSBundle mainBundle] pathForResource:@"FaceArray" ofType:@"plist"];
        _emotions = [NSArray arrayWithContentsOfFile:path];
    }
    return _emotions;
}

- (UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.height - 44, self.width, 44)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        [_bottomView addSubview:self.sendButton];
    }
    return _bottomView;
}

- (UIButton *)sendButton{
    if (_sendButton == nil) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.frame = CGRectMake(self.width - 78 , (44 - 30)/2.0f , 68, 30);
        [_sendButton setBackgroundColor:[UIColor colorWithHexString:@"0x3592EC"] forState:UIControlStateNormal];
        [_sendButton setBackgroundColor:[UIColor colorWithHexString:@"0x3592EC"] forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        _sendButton.layer.masksToBounds = YES;
        _sendButton.layer.cornerRadius = 2;
        [_sendButton addTarget:self action:@selector(sendButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}

@end
