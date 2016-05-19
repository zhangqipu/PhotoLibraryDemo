//
//  PhotoLibraryViewController.m
//  PhotoLibraryDemo
//
//  Created by 张齐朴 on 16/5/19.
//  Copyright © 2016年 张齐朴. All rights reserved.
//

#import "PhotoLibraryViewController.h"
#import "PhotoLibarayCollectionViewCell.h"
#import "SelectedCollectionViewCell.h"

#import "PhotoLookViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoLibraryViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *upperCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *downCollectionView;

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSMutableArray *assetsGroups;
@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) NSMutableArray *selectedAssets;

@end

@implementation PhotoLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setUpCollectionView];
    [self setUpAssetLibrary];
}

- (void)setUpCollectionView {
    
    NSBundle *bundle = [NSBundle mainBundle];
    UINib *nib = [UINib nibWithNibName:@"PhotoLibarayCollectionViewCell" bundle:bundle];
    
    [_upperCollectionView registerNib:nib forCellWithReuseIdentifier:@"PhotoLibarayCollectionViewCell"];
    [_upperCollectionView setAllowsMultipleSelection:YES];
    
    nib = [UINib nibWithNibName:@"SelectedCollectionViewCell" bundle:bundle];
    [_downCollectionView registerNib:nib forCellWithReuseIdentifier:@"SelectedCollectionViewCell"];

    _assetsGroups = [NSMutableArray array];
    _assets = [NSMutableArray array];
    _selectedAssets = [NSMutableArray array];
}

- (void)setUpAssetLibrary {
    _assetsLibrary = [[ALAssetsLibrary alloc] init];
    
    // 遍历所有相册
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group == nil) {
            *stop = YES;
            [self configDataSource];
        } else {
            [_assetsGroups addObject:group];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

/**
 *  选择相册事件
 */
- (void)selectAssetGroupAction:(id)sender {
    [self configDataSource];
}

/**
 *  获取相册所有图片设置数据源
 */

- (void)configDataSource {
    
    if (_assetsGroups.count > 0 == NO) return ;
    
    // 遍历相册中所有照片
    ALAssetsGroup *group = _assetsGroups[0];
    
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result == nil) {
            *stop = YES;
            [_upperCollectionView reloadData];
        } else {
            [_assets addObject:result];
        }
    }];
    
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == _upperCollectionView) {
        return _assets.count;
    } else {
        return _selectedAssets.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == _upperCollectionView) {
    
        PhotoLibarayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoLibarayCollectionViewCell" forIndexPath:indexPath];
        
        // 取缩略图
        ALAsset *asset = _assets[indexPath.row];
        cell.imgV.image = [UIImage imageWithCGImage:asset.thumbnail];
        
        cell.selectItemBlock = ^(BOOL isSelected) {
            if (isSelected) {
                [_selectedAssets addObject:asset];
                [_downCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedAssets.count - 1 inSection:0]]];
            } else {
                NSUInteger i = [_selectedAssets indexOfObject:asset];
                [_selectedAssets removeObject:asset];
                [_downCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
            }
            
            if (_selectedAssets.count > 0)
            [_downCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedAssets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        };
        
        return cell;
    } else {
        SelectedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectedCollectionViewCell" forIndexPath:indexPath];
        
        // 取缩略图
        ALAsset *asset = _assets[indexPath.row];
        cell.imgV.image = [UIImage imageWithCGImage:asset.thumbnail];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoLookViewController *vc = [[PhotoLookViewController alloc] init];
    vc.assets = _assets;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _upperCollectionView) {
        return CGSizeMake(110, 110);
    } else {
        return CGSizeMake(40, 40);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(15, 15, 15, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
