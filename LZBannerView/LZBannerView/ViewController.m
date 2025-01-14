//
//  ViewController.m
//  LZBanner
//
//  Created by liuzhixiong on 2018/8/31.
//  Copyright © 2018年 liuzhixiong. All rights reserved.
//

#import "ViewController.h"
#import "LZBannerView.h"
#import "LZBannerModel.h"

@interface ViewController ()

@property (nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self setupBannerData];
    [self setupOneBannerView];
//    [self setupTwoBannerView];
}

#pragma mark - setupBanner
-(void)setupOneBannerView{
    
    LZBannerConfig *config = [LZBannerConfig new];
    config.imageWidth = 343;
    config.imageHeight = 200;
    config.itemInsetSpacing = 20;
    config.itemInterSpacing = 10;
    LZBannerView *oneBannerView = [[LZBannerView alloc] initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds) - 100, 193) config:config];
    [oneBannerView setupBannerData:self.dataArray];
    [self.view addSubview:oneBannerView];
}

-(void)setupTwoBannerView{

    LZBannerView * twoBannerView = [[LZBannerView alloc]initWithFrame:CGRectMake(0,250, CGRectGetWidth(self.view.bounds), 200) bannerImgWidth:343 bannerImgHeight:193 leftRightSpace:0 itemSpace:50];
    [twoBannerView setupBannerData:self.dataArray];
    [self.view addSubview:twoBannerView];
}


#pragma mark - GetData
-(void)setupBannerData{
    NSArray *titlesArray = @[@"bannerOne",@"bannerTwo",@"bannerThree",@"bannerFour"];
    self.dataArray = [NSMutableArray array];
    [titlesArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        LZBannerModel *bannerModel = [[LZBannerModel alloc]init];
        bannerModel.title = [NSString stringWithFormat:@"title:%zd",idx];
        bannerModel.filePath = [[NSBundle mainBundle]pathForResource:titlesArray[idx] ofType:@"jpg"];
        [self.dataArray addObject:bannerModel];
    }];
}

@end
