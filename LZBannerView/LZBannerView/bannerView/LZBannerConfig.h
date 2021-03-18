//
//  LZBannerConfig.h
//  LZBannerView
//
//  Created by Vic on 2021/3/18.
//  Copyright © 2021 liuzhixiong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LZBannerConfig : NSObject

@property (nonatomic, assign) NSTimeInterval interval;


/*
 bannerImgWidth:(CGFloat)width bannerImgHeight:(CGFloat)height leftRightSpace:(CGFloat)space itemSpace:(CGFloat)itemSpace{
     if (self = [super initWithFrame:frame]) {

 */

@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;
@property (nonatomic, assign) CGFloat itemInsetSpacing;
@property (nonatomic, assign) CGFloat itemInterSpacing;




@end

NS_ASSUME_NONNULL_END
