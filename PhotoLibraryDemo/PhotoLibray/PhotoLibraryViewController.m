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
#import "AssetsGroupMenu.h"

#define kItemSize ((CGRectGetWidth(self.view.frame) - 4 * 5) / 3)
#define kMenuHeight (CGRectGetHeight(self.view.frame) - 64 - 56)

@interface PhotoLibraryViewController ()
<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *upperCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *downCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (strong, nonatomic) UIButton *titleViewButton;

@property (strong, nonatomic) AssetsGroupMenu *assetsGroupMenu;

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
    [self setUpTitleView];
    [self setUpAssetsGroupMenu];
    [self setUpAssetLibrary];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [_upperCollectionView reloadData];
    [_downCollectionView reloadData];
    [_finishButton setTitle:[NSString stringWithFormat:@"完成(%lu)", (unsigned long)_selectedAssets.count] forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _assetsGroupMenu.frame = CGRectMake(0, -kMenuHeight, CGRectGetWidth(self.view.frame), kMenuHeight);
}

- (void)setUpTitleView
{
    _titleViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _titleViewButton.frame = CGRectMake(0, 0, 180, 40);
    [_titleViewButton setTitle:@"选择相册" forState:UIControlStateNormal];
    [_titleViewButton setImage:[UIImage imageNamed:@"downArrow"] forState:UIControlStateNormal];
    [_titleViewButton setImageEdgeInsets:UIEdgeInsetsMake(0, 160, 0, 0)];
    [_titleViewButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [_titleViewButton addTarget:self action:@selector(assetsGroupSelectAction) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.titleView = _titleViewButton;
}

- (void)assetsGroupSelectAction
{
    if (CGRectGetMinY(_assetsGroupMenu.frame) != 64) {
        [UIView animateWithDuration:0.6 animations:^{
            _assetsGroupMenu.frame = CGRectMake(0, 64, CGRectGetWidth(_assetsGroupMenu.frame), CGRectGetHeight(_assetsGroupMenu.frame));
        }];
    } else {
        [UIView animateWithDuration:0.6 animations:^{
            _assetsGroupMenu.frame = CGRectMake(0, -CGRectGetHeight(_assetsGroupMenu.frame), CGRectGetWidth(_assetsGroupMenu.frame), CGRectGetHeight(_assetsGroupMenu.frame));
        }];
    }
}

- (void)setUpAssetsGroupMenu
{
    _assetsGroupMenu = [[[NSBundle mainBundle] loadNibNamed:@"AssetsGroupMenu" owner:self options:nil] firstObject];
    _assetsGroupMenu.frame = CGRectZero;
    _assetsGroupMenu.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.view addSubview:_assetsGroupMenu];
    
    __weak id weakSelf = self;
    AssetsGroupMenu *weakMenu = _assetsGroupMenu;
    _assetsGroupMenu.assetsGroupItemSelectAction = ^(ALAssetsGroup *group) {
        [weakSelf configDataSource:group];
        [UIView animateWithDuration:0.3 animations:^{
            weakMenu.frame = CGRectMake(0, -CGRectGetHeight(weakMenu.frame), CGRectGetWidth(weakMenu.frame), CGRectGetHeight(weakMenu.frame));
        }];

    };
    
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
            [self configAssetsGroupDataSource];
        } else {
            [_assetsGroups addObject:group];
            
            if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"Camera Roll"]) {
                [self configDataSource:group];
            }
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

/**
 *  切换相册
 */

- (void)configDataSource:(ALAssetsGroup *)assetsGroup {
    
    if (_assetsGroups.count > 0 == NO) return ;
    
    // 遍历相册中所有照片
    ALAssetsGroup *group = assetsGroup ? assetsGroup : _assetsGroups[0];
    
    NSString *groupName = [group valueForProperty:ALAssetsGroupPropertyName];
    [_titleViewButton setTitle:groupName forState:UIControlStateNormal];
    
    [_assets removeAllObjects];
    [_selectedAssets removeAllObjects];
    [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result == nil) {
            *stop = YES;
            [_upperCollectionView reloadData];
            [_downCollectionView reloadData];
            [_finishButton setTitle:[NSString stringWithFormat:@"完成(%lu)", (unsigned long)_selectedAssets.count] forState:UIControlStateNormal];

        } else {
            [_assets addObject:result];
        }
    }];
    
}

- (void)configAssetsGroupDataSource {
    _assetsGroupMenu.assetsGroups = _assetsGroups;
    [_assetsGroupMenu.tableView reloadData];
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
        
        cell.indexPath = indexPath;
        
        // 取缩略图
        ALAsset *asset = _assets[indexPath.row];
        cell.imgV.image = [UIImage imageWithCGImage:asset.thumbnail];
        
        [cell.selectButton setSelected:[_selectedAssets containsObject:_assets[indexPath.row]]];
        
        cell.selectItemBlock = ^(BOOL isSelected, NSIndexPath *indP) {
            if (isSelected) {
                [_selectedAssets addObject:_assets[indP.row]];
                if (_selectedAssets.count > 0)
                [_downCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedAssets.count - 1 inSection:0]]];
            } else {
                NSUInteger i = [_selectedAssets indexOfObject:asset];
                [_selectedAssets removeObject:asset];
                [_downCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
            }
            
            if (_selectedAssets.count > 0)
            [_downCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedAssets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            
            [_finishButton setTitle:[NSString stringWithFormat:@"完成(%lu)", (unsigned long)_selectedAssets.count] forState:UIControlStateNormal];
        };
        
        return cell;
    } else {
        SelectedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectedCollectionViewCell" forIndexPath:indexPath];
        
        // 取缩略图
        ALAsset *asset = _selectedAssets[indexPath.row];
        cell.imgV.image = [UIImage imageWithCGImage:asset.thumbnail];
        
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoLookViewController *vc = [[PhotoLookViewController alloc] init];
    vc.assets = _assets;
    vc.selectedAssets = _selectedAssets;
    vc.currentIndex = indexPath.row;
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == _upperCollectionView) {
        return CGSizeMake(kItemSize, kItemSize);
    } else {
        return CGSizeMake(40, 40);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

/**
 *  完成按钮事件
 *
 *  @param sender
 */
- (IBAction)finishButtonAction:(id)sender {
    if (_onFinishPhotoesPickUpBlock) {
        _onFinishPhotoesPickUpBlock(_selectedAssets);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
