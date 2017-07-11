//
//  UIImageView+ZJ_Extension.m
//  ZJPhotoBrowserControllerDemo
//
//  Created by yzj on 2017/7/10.
//  Copyright © 2017年 YZJ. All rights reserved.
//

#import "UIImageView+ZJ_Extension.h"
#import "UIView+WebCache.h"
#import "NSData+ImageContentType.h"
#import <ImageIO/ImageIO.h>

@implementation UIImage (ZJ_Gif)

+ (UIImage *)zj_animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    }
    else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            if (!image) {
                continue;
            }
            
            duration += [self zj_frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (float)zj_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

@end

@implementation UIImageView (ZJ_Extension)

- (void)zj_setImageWithURL:(nullable NSURL *)url {
    [self zj_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)zj_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder {
    [self zj_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)zj_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options {
    [self zj_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)zj_setImageWithURL:(nullable NSURL *)url completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self zj_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)zj_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self zj_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)zj_setImageWithURL:(nullable NSURL *)url placeholderImage:(nullable UIImage *)placeholder options:(SDWebImageOptions)options completed:(nullable SDExternalCompletionBlock)completedBlock {
    [self zj_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)zj_setImageWithURL:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                   options:(SDWebImageOptions)options
                  progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
                 completed:(nullable SDExternalCompletionBlock)completedBlock {
    
    __weak typeof(self)weakSelf = self;
    [self sd_internalSetImageWithURL:url placeholderImage:placeholder options:options operationKey:nil setImageBlock:^(UIImage * _Nullable image, NSData * _Nullable imageData) {
        
        SDImageFormat imageFormat = [NSData sd_imageFormatForImageData:imageData];
        if (imageFormat == SDImageFormatGIF) {
            weakSelf.image = [UIImage zj_animatedGIFWithData:imageData];
        } else {
            weakSelf.image = image;
        }
        
    } progress:progressBlock completed:completedBlock];
}


@end


