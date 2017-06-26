//
//  ViewController.m
//  ZJPhotoBrowserControllerDemo
//
//  Created by yzj on 2017/6/19.
//  Copyright © 2017年 yzj. All rights reserved.
//

#import "ViewController.h"
#import "ZJPhotoBrowserController.h"
#import "SDImageCache.h"


@interface ViewController ()
@property (nonatomic, strong) NSArray *imagesArray;
@end

@implementation ViewController

- (NSArray *)imagesArray
{
    if (!_imagesArray) {
        //        NSDictionary *dict1 = @{@"image": [UIImage imageNamed:@"1.jpg"], @"url":@"http://pic1.nipic.com/2008-09-19/200891903253318_2.jpg"};
        //        NSDictionary *dict2 = @{@"image": [UIImage imageNamed:@"2.jpg"], @"url":@"http://pic4.nipic.com/20091117/3376018_110331702620_2.jpg"};
        //        NSDictionary *dict3 = @{@"image": [UIImage imageNamed:@"3.jpg"], @"url":@"http://pic10.nipic.com/20101020/3650425_202918301404_2.jpg"};
        //        NSDictionary *dict4 = @{@"image": [UIImage imageNamed:@"4.jpg"], @"url":@"http://img1.xcarimg.com/news/945/995/m_e5ji7hx2rn2103.jpg"};
        //        NSDictionary *dict5 = @{@"image": [UIImage imageNamed:@"5.jpg"], @"url":@"http://img1.xcarimg.com/news/1656/1740/m_20100927095234521711.jpg"};
        NSDictionary *dict1 = @{@"image": [UIImage imageNamed:@"111"], @"url":@"http://piccdn.xingyun.cn/media/users/post/323/12/100201148299_3231261.jpg?imageMogr2/thumbnail/828.000000x", @"hdUrl":@"http://piccdn.xingyun.cn/media/users/post/323/12/100201148299_3231261.jpg"};
        NSDictionary *dict2 = @{@"image": [UIImage imageNamed:@"222"], @"url":@"http://piccdn.xingyun.cn/media/users/post/323/12/100201148299_3231262.jpg?imageMogr2/thumbnail/828.000000x", @"hdUrl":@"http://piccdn.xingyun.cn/media/users/post/323/12/100201148299_3231262.jpg"};
        NSDictionary *dict3 = @{@"image": [UIImage imageNamed:@"333"], @"url":@"http://piccdn.xingyun.cn/media/users/post/323/12/100201148299_3231263.jpg?imageMogr2/thumbnail/828.000000x", @"hdUrl":@"http://piccdn.xingyun.cn/media/users/post/323/12/100201148299_3231263.jpg"};
        NSDictionary *dict4 = @{@"image": [UIImage imageNamed:@"444"], @"url":@"http://piccdn.xingyun.cn/media/users/post/323/12/100201148299_3231264.jpg?imageMogr2/thumbnail/828.000000x", @"hdUrl":@"http://piccdn.xingyun.cn/media/users/post/323/12/100201148299_3231264.jpg"};
        NSDictionary *dict5 = @{@"image": [UIImage imageNamed:@"555"], @"url":@"http://piccdn.xingyun.cn/media/users/post/323/12/100201148299_3231265.jpg?imageMogr2/thumbnail/828.000000x", @"hdUrl":@"http://piccdn.xingyun.cn/media/users/post/323/12/100201148299_3231265.jpg"};
        
        NSMutableArray *mArray = [NSMutableArray arrayWithObjects:dict1, dict2, dict3,dict4, dict5, nil];
        
        _imagesArray = mArray;
    }
    return _imagesArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    for (int i = 1; i<=5; i++) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(browseImageView:)];
        UIImageView *imageView = [self.view viewWithTag:i];
        [imageView addGestureRecognizer:tap];
        
    }
    
}


- (void)browseImageView:(UITapGestureRecognizer *)gesture
{
    
    NSMutableArray *photos = [NSMutableArray array];
    for (int i = 1; i<=self.imagesArray.count; i++) {
        NSDictionary *dict = self.imagesArray[i-1];
        UIImageView *imageView = [self.view viewWithTag:i];
        
        ZJPhotoModel *model = [ZJPhotoModel modelWithUrl:dict[@"url"] image:dict[@"image"] srcView: imageView];
        model.hdUrl = dict[@"hdUrl"];
        [photos addObject:model];
    }
    
    ZJPhotoBrowserController *photoBrowser = [ZJPhotoBrowserController new];
    photoBrowser.photos = photos;
    photoBrowser.index = gesture.view.tag - 1;
    [photoBrowser show];
}

- (IBAction)clearCache {
    
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearMemory];
    
}

@end
