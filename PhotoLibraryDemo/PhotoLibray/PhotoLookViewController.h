//
//  PhotoLookViewController.h
//  PhotoLibraryDemo
//
//  Created by 张齐朴 on 16/5/19.
//  Copyright © 2016年 张齐朴. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoLookViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
// 某个一个相册中的所有图片
@property (nonatomic, strong) NSArray *assets;
// 某相册中被选中的图片
@property (nonatomic, strong) NSMutableArray *selectedAssets;
@property (assign, nonatomic) NSUInteger currentIndex;

@end
