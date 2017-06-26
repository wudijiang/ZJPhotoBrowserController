//
//  ViewController.m
//  test--图片浏览器
//
//  Created by YZJ on 15/6/29.
//  Copyright (c) 2015年 YZJ. All rights reserved.
//

#import "ZJPhotoBrowserController.h"
#import "SDWebImagePrefetcher.h"


#define collectionID @"photoCell"
@interface ZJPhotoBrowserController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ZJPhotoBrowserCellDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
/**
 *  标题
 */
@property (nonatomic, weak) UILabel *titleLable;

@property (nonatomic, assign) BOOL statusBarState;

@end

@implementation ZJPhotoBrowserController

#pragma mark - lifeCycle

- (instancetype)initWithPhotos:(NSArray *)photos index:(NSInteger)index
{
    if (self = [super init]) {
        self.photos = photos;
        self.index = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self collectionView];
    
    if (self.photos.count <= 1) {
        self.titleLable.hidden = YES;
    } else {
        self.titleLable.hidden = NO;
        self.titleLable.text = [NSString stringWithFormat:@"1/%lu", (unsigned long)self.photos.count];
    }
    
    self.statusBarState = [UIApplication sharedApplication].statusBarHidden;
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showPhotos];
}


#pragma mark - Event
- (void)show
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    //目的是消除动画问题
    //    self.view.alpha = 0;
    self.view.backgroundColor = [UIColor clearColor];
    
    
}

- (void)showPhotos
{
    //    //先滚动到指定的位置
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.002 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.collectionView.hidden = NO;
        ZJPhotoBrowserCell *cell = (ZJPhotoBrowserCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.index inSection:0]];
        [cell showImageAnimated];
        
        // 预下载图片
        [self prefetchDownloadImage];
    });
    
    
    
}
// 预下载图片
- (void)prefetchDownloadImage
{
    // 预下载下一张
    if (self.index + 1 < self.photos.count) {
        ZJPhotoModel *model = self.photos[self.index + 1];
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:model.url] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
        }];
    }
    
    // 预下载上一张
    if (self.index - 1 >= 0) {
        ZJPhotoModel *model = self.photos[self.index - 1];
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:model.url] options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
        }];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ZJPhotoBrowserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionID forIndexPath:indexPath];
    cell.model = self.photos[indexPath.row];
    cell.controller = self;
    cell.delegate = self;
    return cell;
}

#pragma mark - scrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int currentPage = scrollView.contentOffset.x/scrollView.frame.size.width + 1.5;
    self.titleLable.text = [NSString stringWithFormat:@"%d/%lu", currentPage, (unsigned long)self.photos.count];
    
}

#pragma mark - ZJPhotoBrowserCellDelegate
- (void)photoBrowserCellWillHide:(ZJPhotoBrowserCell *)cell
{
    [UIApplication sharedApplication].statusBarHidden = self.statusBarState;
    
//    return;
    // 考虑可能会有nav及tab的情况
    UIView *srcView = cell.model.srcView;
    CGRect srcToWindowFrame = [srcView convertRect:srcView.bounds toView:nil];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    UIViewController *rootVC = keyWindow.rootViewController;
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navVC = (UINavigationController *)rootVC;
        UINavigationBar *navBar = navVC.navigationBar;
        CGRect navBarToWindowFrame = [navBar convertRect:navBar.bounds toView:nil];
        if (!CGRectIntersectsRect(srcToWindowFrame, navBarToWindowFrame)) {
            return;
        }
        
        [navVC.view insertSubview:self.view belowSubview:navBar];
    } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController *)rootVC;
        UINavigationController *navVC = tabVC.viewControllers[0];
        
        UITabBar *tabBar = tabVC.tabBar;
        UINavigationBar *navBar = navVC.navigationBar;
        CGRect navBarToWindowFrame = [navBar convertRect:navBar.bounds toView:nil];
        CGRect tabBarToWindowFrame = [tabBar convertRect:tabBar.bounds toView:nil];
        if (!CGRectIntersectsRect(srcToWindowFrame, navBarToWindowFrame) && !CGRectIntersectsRect(srcToWindowFrame, tabBarToWindowFrame)) {
            return;
        }
        if (navVC) {
            
            [navVC.view insertSubview:self.view belowSubview:navVC.navigationBar];
        } else {
            [tabVC.view insertSubview:self.view belowSubview:tabVC.tabBar];
        }
    }
}

#pragma mark - getter

- (UILabel *)titleLable
{
    if (!_titleLable) {
        UILabel *titleLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
        titleLable.tag = 200;
        titleLable.textColor = [UIColor whiteColor];
        titleLable.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        titleLable.textAlignment = NSTextAlignmentCenter;
        titleLable.center = CGPointMake(self.view.center.x, 40);
        
        titleLable.layer.cornerRadius = 10;
        titleLable.layer.masksToBounds = YES;
        [self.view addSubview:titleLable];
        _titleLable = titleLable;
    }
    return _titleLable;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        CGFloat width = self.view.frame.size.width + 20;
        CGFloat height = self.view.frame.size.height;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(width, height);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, width, height) collectionViewLayout:layout];
        collectionView.hidden = YES;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.pagingEnabled = YES;
        collectionView.delegate = self;
        collectionView.dataSource = self;
        [collectionView registerClass:[ZJPhotoBrowserCell class] forCellWithReuseIdentifier:collectionID];
        self.collectionView = collectionView;
        [self.view addSubview:collectionView];
    }
    return _collectionView;
}

@end
