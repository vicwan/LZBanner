//
//  LZBannerView.m
//  LZBanner
//
//  Created by liuzhixiong on 2018/8/31.
//  Copyright © 2018年 liuzhixiong. All rights reserved.
//

#import "LZBannerView.h"
#import "LZBannerCell.h"

#define kLZ_Bannerinterval 3

@interface LZBannerView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView    * bannerCollectionView;
@property (nonatomic,strong) UIPageControl        *pageControl;
@property (nonatomic, strong) NSMutableArray    * dataArray;
@property (nonatomic, strong) NSTimer *                timer;
@property (nonatomic, assign) NSInteger                currentPage;//当前页数
@property (nonatomic, assign) CGFloat                   bannerCellWidth; // banner图的宽度
@property (nonatomic, assign) CGFloat                   bannerCellHeight; //banner图的高度
@property (nonatomic, assign) CGFloat                   itemSpacing;// cell之间的距离
@property (nonatomic, assign) CGFloat                   itemInsetSpacing; // banner图在正中间时候，距离左右间距
@property (nonatomic, assign) NSInteger                virtualCellCount;//虚拟的数据源 banner图个数

@property (nonatomic, strong) LZBannerConfig *config;

@end


@implementation LZBannerView

- (instancetype)initWithFrame:(CGRect)frame config:(LZBannerConfig *)config {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        self.config = config;
        [self setupPageControl];
    }
    return self;
}

- (void)setConfig:(LZBannerConfig *)config {
    _config = config;
    _bannerCellWidth = CGRectGetWidth(self.frame) - config.itemInsetSpacing * 2;
    _bannerCellHeight = _bannerCellWidth / config.imageWidth * config.imageHeight;
    _itemInsetSpacing = config.itemInsetSpacing;
    _itemSpacing = config.itemInterSpacing;
    
    [self.bannerCollectionView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), _bannerCellHeight)];
    [self.bannerCollectionView setContentInset:UIEdgeInsetsMake(0, _itemInsetSpacing, 0, _itemInsetSpacing)];
}

- (void)setupPageControl {
    CGFloat w = CGRectGetWidth(self.bounds) * 0.8;
    CGFloat h = 20;
    CGFloat x = CGRectGetWidth(self.bounds) / 2 - 0.5 * w;
    CGFloat y = CGRectGetHeight(self.bannerCollectionView.bounds) - h - 5;
    CGRect frame = CGRectMake(x, y, w, h);
    [self.pageControl setFrame:frame];
}

- (void)setupBannerData:(NSArray *)models {
    if (!models || models.count == 0) return;
    
    //配置数据
    self.dataArray = [NSMutableArray arrayWithArray:models];
    if (models.count == 1){
        self.virtualCellCount = 1;
        self.currentPage = 0;
    }else{
        self.virtualCellCount = 10000;
        self.currentPage = self.dataArray.count * self.virtualCellCount / 2;
        [self addTimer];
    }
    [self.bannerCollectionView reloadData];
    
    //默认滚动到指定位置
    [self layoutIfNeeded];
    [self.bannerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    //配置pageControl
    self.pageControl.numberOfPages = self.dataArray.count;
}

#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count * self.virtualCellCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LZBannerCell  *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LZBannerCell class]) forIndexPath:indexPath];
    LZBannerModel *cellModel = self.dataArray[indexPath.item % self.dataArray.count];
    [cell setupBannerModel:cellModel];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.bannerCellWidth, self.bannerCellHeight);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return _itemSpacing;
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self removeTimer];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    //1. 计算滚动一页的偏移量。  第一个cell因为有contentInset影响，所以和后面每滚动一页有一个contentInset的区别
    CGFloat firstCellOffset = CGRectGetWidth(self.frame) - 3 * _itemInsetSpacing + _itemSpacing ;
    CGFloat otherCellOffsetX = CGRectGetWidth(self.frame) - 2 * _itemInsetSpacing + _itemSpacing;
    
    //2. 此处判断是否需要改变页数
    if (fabs(velocity.x) <= 0.3) {
        CGFloat currentOffsetX = scrollView.contentOffset.x;
        self.currentPage = (currentOffsetX-firstCellOffset)/otherCellOffsetX+1+0.5;
    }else{
        if (velocity.x > 0) {
            self.currentPage ++;
        }else{
            self.currentPage --;
        }
    }
    
    //3.  如果，当然只是如果，一般来说只要虚拟个数设置过大，基本不可能滚动到头；若真到头了就只好重置currentPage的值喽
    if (self.currentPage >= self.dataArray.count*self.virtualCellCount-1) {
        self.currentPage = self.dataArray.count * self.virtualCellCount-1;
    }else if (self.currentPage <= 0) {
        self.currentPage = 0;
    }
    
    //4. 根据页数计算偏移量
    CGFloat offsetX;
    if (self.currentPage == 0) {
        offsetX = firstCellOffset;
    }else{
        offsetX = firstCellOffset + otherCellOffsetX * (self.currentPage-1);
    }
    
    //5. 设置scrollView滚动的最终停止位置
    *targetContentOffset = CGPointMake(offsetX, 0);
    
    [self updatePageControl];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
     [self addTimer];
}

#pragma mark - timer

- (void)addTimer {
    if (_timer) return;
    _timer = [NSTimer timerWithTimeInterval:kLZ_Bannerinterval target:self selector:@selector(scrollToThePage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
}

- (void)removeTimer {
    if (!_timer) return;
    [_timer invalidate];
    _timer = nil;
}

- (void)scrollToThePage{
    
    self.currentPage ++;
    
    [self.bannerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    if (self.currentPage == self.dataArray.count * self.virtualCellCount-1 || self.currentPage == 0) {
        self.currentPage = self.dataArray.count *self.virtualCellCount/2;
        [self.bannerCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
    
    [self updatePageControl];
}

#pragma mark - Private
-(void)updatePageControl{
    NSUInteger page = self.currentPage % self.dataArray.count;
    self.pageControl.currentPage = page;
}

#pragma mark - lazyLoad
-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

-(UICollectionView *)bannerCollectionView{
    if (!_bannerCollectionView) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        self.bannerCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        [self.bannerCollectionView setDelegate:self];
        [self.bannerCollectionView setDataSource:self];
        self.bannerCollectionView.backgroundColor = [UIColor whiteColor];
        [self.bannerCollectionView setDecelerationRate:0.3];
        [self addSubview:self.bannerCollectionView];
        self.bannerCollectionView.showsHorizontalScrollIndicator = NO;
        [self.bannerCollectionView registerClass:[LZBannerCell class] forCellWithReuseIdentifier:NSStringFromClass([LZBannerCell class])];
    }
    return _bannerCollectionView;
}

-(UIPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc]init];
        self.pageControl.currentPage = 0;
        _pageControl.hidesForSinglePage = NO;
        _pageControl.userInteractionEnabled = YES;
        
//        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
//        _pageControl.pageIndicatorTintColor = [UIColor greenColor];
        _pageControl.allowsContinuousInteraction = YES;
        
        [self addSubview:self.pageControl];
    }
    return _pageControl;
}

@end

