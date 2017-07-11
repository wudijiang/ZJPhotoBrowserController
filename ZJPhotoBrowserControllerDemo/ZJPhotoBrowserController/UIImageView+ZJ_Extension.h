//
//  UIImageView+ZJ_Extension.h
//  ZJPhotoBrowserControllerDemo
//
//  Created by yzj on 2017/7/10.
//  Copyright © 2017年 YZJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

@interface UIImageView (ZJ_Extension)

- (void)zj_setImageWithURL:(nullable NSURL *)url;


- (void)zj_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder;


- (void)zj_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options;


- (void)zj_setImageWithURL:(nullable NSURL *)url
                 completed:(nullable SDExternalCompletionBlock)completedBlock;


- (void)zj_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                 completed:(nullable SDExternalCompletionBlock)completedBlock;


- (void)zj_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                 completed:(nullable SDExternalCompletionBlock)completedBlock;


- (void)zj_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock;

@end
