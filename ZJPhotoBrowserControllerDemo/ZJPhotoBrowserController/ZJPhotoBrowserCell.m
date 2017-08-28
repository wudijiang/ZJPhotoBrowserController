//
//  ZJPhotoBrowserCell.m
//  test--图片浏览器
//
//  Created by YZJ on 15/6/29.
//  Copyright (c) 2015年 YZJ. All rights reserved.
//

#import "ZJPhotoBrowserCell.h"
#import "UIImageView+WebCache.h"
#import "UIView+WebCache.h"
#import "ZJProgressView.h"
#import "UIImageView+ZJ_Extension.h"
#import <AssetsLibrary/AssetsLibrary.h>
#define maxZoomScale 4.0
#define kAnimatedDuration 0.3

@interface ZJPhotoBrowserCell () <UIScrollViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) ZJProgressView *progressView;
@property (nonatomic, strong) UIButton *lookupBigImageButton;
@property (nonatomic, weak) UIScrollView *observerScrollView;
@end

@implementation ZJPhotoBrowserCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        [self.contentView addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
        [self.contentView addSubview:self.progressView];
        [self.contentView addSubview:self.lookupBigImageButton];
        
        
    }
    return self;
}

- (void)setModel:(ZJPhotoModel *)model
{
    _model = model;
    self.imageView.image = model.image;
    // 首先判断是否有高清图
    NSString *hdUrlKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:model.hdUrl]];
    if (model.hdUrl.length && [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:hdUrlKey]) {
        self.progressView.hidden = YES;
        self.lookupBigImageButton.hidden = YES;
        [self.imageView zj_setImageWithURL:[NSURL URLWithString:model.hdUrl] placeholderImage:model.image];
    } else if (model.url.length) {
        
        // 如果hdUrl为空或者 url与高清大图url相同，则隐藏该按钮
        self.lookupBigImageButton.hidden = !model.hdUrl.length || [model.hdUrl isEqualToString:model.url];
        
        // 这个判断的作用是 ：防止第一次弹出浏览器时加载环会闪现
        NSString *urlKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:model.url]];
        if (![[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:urlKey]) {
            self.progressView.hidden = NO;
            self.progressView.progress = 0;
        } else {
            self.progressView.hidden = YES;
        }
        
        [self.imageView zj_setImageWithURL:[NSURL URLWithString:model.url] placeholderImage:model.image options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (receivedSize >= 0 && expectedSize > 0) {
                    CGFloat progress = (CGFloat)receivedSize/expectedSize;
                    self.progressView.progress = progress;
                    NSLog(@"%f", progress);
                }
            });
        } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            self.progressView.hidden = YES;
            self.scrollView.zoomScale = 1.0;
            [self setImageViewFrameByImageSize];
        }];
        
    } else {
        self.lookupBigImageButton.hidden = YES;
    }
    self.scrollView.zoomScale = 1.0;
    [self setImageViewFrameByImageSize];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    
    CGFloat centerX = scrollView.center.x , centerY = scrollView.center.y;
    
    centerX = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : centerX;
    
    centerY = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : centerY;
    
    self.imageView.center = CGPointMake(centerX, centerY);
    
}

#pragma mark - publick
- (void)showImageAnimated
{
    ZJPhotoModel *model = self.model;
    // 点击的View
    UIView *srcView = model.srcView;
    if (srcView) {
        CGRect srcFrame = [srcView convertRect:srcView.bounds toView:self];
        self.imageView.frame = srcFrame;
        self.imageView.contentMode = srcView.contentMode;
    } else {
        self.imageView.bounds = CGRectMake(0, 0, 50, 50);
        CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
        CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
        self.imageView.center = CGPointMake(screenW*0.5, screenH*0.5);
    }
    
    [UIView animateWithDuration:kAnimatedDuration animations:^{
        self.controller.view.backgroundColor = [UIColor blackColor];
        [self setImageViewFrameByImageSize];
    }];
}


#pragma mark - gesture
- (void)tapClick
{
    [self removeAllObserver];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowserCellWillHide:)]) {
        [self.delegate photoBrowserCellWillHide:self];
    }
    
    self.imageView.contentMode = self.model.srcView.contentMode;
    self.imageView.clipsToBounds = YES;
    
    UIView *titleLabel = [self.controller.view viewWithTag:200];
    titleLabel.hidden = YES;
    self.progressView.hidden = YES;
    self.lookupBigImageButton.hidden = YES;
    UIView *srcView = self.model.srcView;
    CGRect srcFrame = [srcView convertRect:srcView.bounds toView:self.scrollView];
    if (!srcView) {
        [UIView animateWithDuration:kAnimatedDuration animations:^{
            self.superview.alpha = 0.0;
            self.controller.view.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            [self.controller.view removeFromSuperview];
            [self.controller removeFromParentViewController];
        }];
    } else {
        [UIView animateWithDuration:kAnimatedDuration animations:^{
            self.imageView.frame = srcFrame;
            self.controller.view.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            [self.controller.view removeFromSuperview];
            [self.controller removeFromParentViewController];
        }];
    }
    
}

- (void)doubleClick:(UIGestureRecognizer *)gesture
{
    if (self.scrollView.zoomScale == maxZoomScale) {
        [self.scrollView setZoomScale:1 animated:YES];
    } else {
        CGPoint touchPoint = [gesture locationInView:self.imageView];
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
        [self.scrollView setZoomScale:maxZoomScale animated:YES];
    }
    
}

- (void)longPress:(UILongPressGestureRecognizer *)press
{
    if (press.state == UIGestureRecognizerStateBegan) {
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"保存图片", nil];
        [sheet showInView:self];
    }
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            if (self.imageView.image.images) {
                [self saveGifToAlbumWithUrl:self.model.hdUrl];
               
            } else {
                UIImageWriteToSavedPhotosAlbum(self.imageView.image, nil, nil,nil);
            }
        });
    }
}

#pragma mark - private
/** 保存gif图 */
- (void)saveGifToAlbumWithUrl:(NSString *)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    [[SDWebImageManager sharedManager] cachedImageExistsForURL:url completion:^(BOOL isInCache) {
        
        if (isInCache) {
            NSString *cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:url];
            if (cacheImageKey.length) {
                NSString *cacheImagePath = [[SDWebImageManager sharedManager].imageCache defaultCachePathForKey:cacheImageKey];
                if (cacheImagePath.length) {
                    NSData *gifData = [NSData dataWithContentsOfFile:cacheImagePath];
                    // 保存到本地相册
                    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                    [library writeImageDataToSavedPhotosAlbum:gifData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                        
                    }] ;
                }
            }
        } else {
            if ([urlString isEqualToString:self.model.url]) return ;
            
            [self saveGifToAlbumWithUrl:self.model.url];
        }
        
    }];
    
}

- (void)setImageViewFrameByImageSize
{
    if (!self.imageView.image) return;
    //标准
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat imageOW = self.imageView.image.size.width;
    CGFloat imageOH = self.imageView.image.size.height;
    //比例
    CGFloat rate = imageOW / screenW;
    //图片显示区域的宽高
    CGFloat imageRW = screenW;
    CGFloat imageRH = imageOH / rate;
    
    self.imageView.frame = CGRectMake(0, 0, imageRW, imageRH);
    if (imageRH < screenH) {
        self.imageView.center = CGPointMake(screenW*0.5, screenH*0.5);
    }
    
    self.scrollView.contentSize = CGSizeMake(imageRW, imageRH);
}


- (void)lookupBigImageButtonClick:(UIButton *)button
{
    button.hidden = YES;
    
    ZJPhotoModel *model = self.model;
    
    if (model.hdUrl.length == 0) return;
    self.progressView.hidden = NO;
    self.progressView.progress = 0;
    [self.imageView zj_setImageWithURL:[NSURL URLWithString:model.hdUrl] placeholderImage:self.imageView.image options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (receivedSize >= 0 && expectedSize > 0) {
                CGFloat progress = (CGFloat)receivedSize/expectedSize;
                self.progressView.progress = progress;
                NSLog(@"下载进度  %f", progress);
            }
        });
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (error) {
            self.lookupBigImageButton.hidden = NO;
        }
        self.progressView.hidden = YES;
        self.scrollView.zoomScale = 1.0;
        [self setImageViewFrameByImageSize];
        
    }];
}

#warning kvo监听逻辑后期需要重新调整一下
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    ZJPhotoModel *model = self.model;
    // 只有该按钮存在时才需要处理
    if (model.hdUrl && ![model.hdUrl isEqualToString:model.url])
    {
        NSString *hdUrlKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:model.hdUrl]];
        if (![[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:hdUrlKey]) {
            
            UIScrollView *scrollView = self.observerScrollView;
            
            int a =  scrollView.contentOffset.x;
            int b = scrollView.frame.size.width;
            
            BOOL  isStop = !(a % b);
            
            [UIView animateWithDuration:0.2 animations:^{
                self.lookupBigImageButton.alpha = isStop;
            } completion:^(BOOL finished) {
                self.lookupBigImageButton.hidden = !isStop;
            }];
        }
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 如果不是UIScrollView，不做任何事情
    if (newSuperview && ![newSuperview isKindOfClass:[UIScrollView class]]) return;
    self.observerScrollView = (UIScrollView *)newSuperview;
    [newSuperview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeAllObserver
{
    // 移除监听者
    id info = self.observerScrollView.observationInfo;
    NSArray *array = [info valueForKey:@"_observances"];
    for (id objc in array) {
        id observer = [objc valueForKeyPath:@"_observer"];
        [self.observerScrollView removeObserver:observer forKeyPath:@"contentOffset"];
    }
}

#pragma mark - getter
- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        scrollView.delegate = self;
        //        scrollView.minimumZoomScale = 0.5;
        scrollView.maximumZoomScale = maxZoomScale;
        self.scrollView = scrollView;
        
        //手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [self.scrollView addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
        doubleTap.numberOfTapsRequired = 2;
        [self.scrollView addGestureRecognizer:doubleTap];
        
        [tap requireGestureRecognizerToFail:doubleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        [self.scrollView addGestureRecognizer:longPress];
    }
    return _scrollView;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        self.imageView = imageView;
        self.imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (ZJProgressView *)progressView
{
    if (!_progressView) {
        ZJProgressView *progressView = [[ZJProgressView alloc] initWithFrame:self.scrollView.bounds];
        progressView.hidden = YES;
        self.progressView = progressView;
        
    }
    return _progressView;
}

- (UIButton *)lookupBigImageButton
{
    if (!_lookupBigImageButton) {
        CGFloat bigImageButtonWidth = 105;
        CGFloat bigImageButtonHeight = 30;
        CGFloat bigImageButtonX = (self.scrollView.frame.size.width - bigImageButtonWidth) * 0.5;
        CGFloat bigImageButtonY = self.scrollView.frame.size.height - bigImageButtonHeight - 54;
        UIButton *lookupBigImageButton = [[UIButton alloc] initWithFrame:CGRectMake(bigImageButtonX, bigImageButtonY, bigImageButtonWidth, bigImageButtonHeight)];
        lookupBigImageButton.layer.cornerRadius = 5;
        lookupBigImageButton.layer.masksToBounds = YES;
        lookupBigImageButton.hidden = YES;
        lookupBigImageButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [lookupBigImageButton setTitle:@"查看高清大图" forState:UIControlStateNormal];
        [lookupBigImageButton addTarget:self action:@selector(lookupBigImageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        self.lookupBigImageButton = lookupBigImageButton;
        
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = lookupBigImageButton.bounds;
        [lookupBigImageButton.layer insertSublayer:gradientLayer atIndex:0];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0 green:178/255.0 blue:1.0 alpha:1.0].CGColor,
                                 (__bridge id)[UIColor colorWithRed:52/255.0 green:86/255.0 blue:1.0 alpha:1.0].CGColor];
        
    }
    return _lookupBigImageButton;
}
@end
