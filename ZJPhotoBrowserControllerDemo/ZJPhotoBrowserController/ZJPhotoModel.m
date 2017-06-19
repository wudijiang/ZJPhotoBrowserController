//
//  ZJPhotoModel.m
//  test--图片浏览器
//
//  Created by YZJ on 15/6/29.
//  Copyright (c) 2015年 YZJ. All rights reserved.
//

#import "ZJPhotoModel.h"

@implementation ZJPhotoModel

+ (instancetype)modelWithUrl:(NSString *)url hdUrl:(NSString *)hdUrl image:(UIImage *)image srcView:(UIView *)srcView;
{
    ZJPhotoModel *model = [ZJPhotoModel new];
    model.url = url;
    model.hdUrl = hdUrl;
    model.image = image;
    model.srcView = srcView;
    return model;
}

+ (instancetype)modelWithUrl:(NSString *)url image:(UIImage *)image srcView:(UIView *)srcView
{
    return [self modelWithUrl:url hdUrl:nil image:image srcView:srcView];
}

+ (instancetype)modelWithUrl:(NSString *)url image:(UIImage *)image
{
    return [self modelWithUrl:url image:image srcView:nil];
}
@end
