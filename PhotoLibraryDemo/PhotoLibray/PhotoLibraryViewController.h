//
//  PhotoLibraryViewController.h
//  PhotoLibraryDemo
//
//  Created by 张齐朴 on 16/5/19.
//  Copyright © 2016年 张齐朴. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^OnFinishPhotoesPickUpBlock)(NSArray *photoAssets); // 每个元素类型 ALAsset

@interface PhotoLibraryViewController : UIViewController

@property (copy, nonatomic) OnFinishPhotoesPickUpBlock onFinishPhotoesPickUpBlock;

@end
