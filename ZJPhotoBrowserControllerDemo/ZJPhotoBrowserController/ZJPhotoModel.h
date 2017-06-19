//
//  QFQPhotoModel.h
//  test--图片浏览器
//
//  Created by YZJ on 15/6/29.
//  Copyright (c) 2015年 YZJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZJPhotoModel : NSObject
/**
 *  普通大图的url
 */
@property (nonatomic, copy) NSString *url;
/**
 *  高清大图的url
 */
@property (nonatomic, copy) NSString *hdUrl;
/**
 *  缩略图（图片浏览器的占位图）
 */
@property (nonatomic, strong) UIImage *image;
/**
 *  被点击的View，图片浏览器会从该view上动画展示（如果为nil，动画会从中间放大展示）
 */
@property (nonatomic, strong) UIView *srcView;


/**

 @param url   普通大图的url
 @param hdUrl 高清大图的url
 @param image 缩略图
 @param srcView 被点击的View，图片浏览器会从该view上动画展示（如果为nil，动画会从中间放大展示）

 */
+ (instancetype)modelWithUrl:(NSString *)url hdUrl:(NSString *)hdUrl image:(UIImage *)image srcView:(UIView *)srcView;

+ (instancetype)modelWithUrl:(NSString *)url image:(UIImage *)image srcView:(UIView *)srcView;

+ (instancetype)modelWithUrl:(NSString *)url image:(UIImage *)image;

@end
