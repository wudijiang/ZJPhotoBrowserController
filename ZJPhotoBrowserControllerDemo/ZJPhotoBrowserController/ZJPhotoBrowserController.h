//
//  ZJPhotoBrowserController.h
//  test--图片浏览器
//
//  Created by YZJ on 15/6/29.
//  Copyright (c) 2015年 YZJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZJPhotoBrowserCell.h"
@interface ZJPhotoBrowserController : UIViewController
/** 所有的图片对象（里面存放ZJPhotoModel对象）*/
@property (nonatomic, strong) NSArray <ZJPhotoModel *> *photos;
/**
 *  图片浏览器弹出来后 定位到的第index张图片处
 */
@property (nonatomic, assign) NSInteger index;

- (instancetype)initWithPhotos:(NSArray *)photos index:(NSInteger)index;

- (void)show;

@end
