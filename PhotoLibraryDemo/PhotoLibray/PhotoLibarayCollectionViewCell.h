//
//  PhotoLibarayCollectionViewCell.h
//  PhotoLibraryDemo
//
//  Created by 张齐朴 on 16/5/19.
//  Copyright © 2016年 张齐朴. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectItemBlock)(BOOL isSelected, NSIndexPath *indexPath);

@interface PhotoLibarayCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

@property (copy, nonatomic) SelectItemBlock selectItemBlock;
@property (assign, nonatomic) NSIndexPath *indexPath;

@end
