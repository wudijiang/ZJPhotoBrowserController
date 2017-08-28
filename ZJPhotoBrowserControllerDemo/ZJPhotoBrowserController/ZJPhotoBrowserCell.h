//
//  ZJPhotoBrowserCell.h
//  test--图片浏览器
//
//  Created by YZJ on 15/6/29.
//  Copyright (c) 2015年 YZJ. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ZJPhotoModel.h"

@class ZJPhotoBrowserCell;
@protocol ZJPhotoBrowserCellDelegate <NSObject>

@optional;

- (void)photoBrowserCellWillHide:(ZJPhotoBrowserCell *)cell;

@end
@interface ZJPhotoBrowserCell : UICollectionViewCell

@property (nonatomic, weak) UIViewController *controller;

@property (nonatomic, strong) ZJPhotoModel *model;

@property (nonatomic, weak) id <ZJPhotoBrowserCellDelegate> delegate;
/** 动画的展示出来 */
- (void)showImageAnimated;

@end
