//
//  PhotoLookViewController.m
//  PhotoLibraryDemo
//
//  Created by 张齐朴 on 16/5/19.
//  Copyright © 2016年 张齐朴. All rights reserved.
//

/*
 assets 包含camera
 方式一 进入前移除 退出后添加
 
 方式二 不移除 计算好index
    a) 进入移动到指定图片
    b) 滚动时候
    b) 选中当前
 */

#import "PhotoLookViewController.h"
#import "SelectedCollectionViewCell.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoLookViewController ()
<UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

@end

@implementation PhotoLookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setUpRightNav];
    [self setUpCollectionView];
    [self setUpScrollView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self layoutScrollView];
}

- (void)setUpCollectionView
{
    NSBundle *bundle = [NSBundle mainBundle];
    UINib *nib = [UINib nibWithNibName:@"SelectedCollectionViewCell" bundle:bundle];
    
    [_collectionView registerNib:nib forCellWithReuseIdentifier:@"SelectedCollectionViewCell"];
}

- (void)setUpScrollView {
    
    _scrollView.pagingEnabled = YES;
    _scrollView.backgroundColor = [UIColor blackColor];
    
    for (int i = 0; i < _assets.count; i++) {
        UIImageView *imgV = [UIImageView new];
        ALAsset *asset = _assets[i];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        imgV.image = [UIImage imageWithCGImage:representation.fullScreenImage];
        
        [_scrollView addSubview:imgV];
    }
    
    // 设置第一张图片右上角选中状态
    ALAsset *asset = _assets[_currentIndex];
    BOOL isSelected = [_selectedAssets containsObject:asset];
    [self changeRightNavItem:isSelected];
    
    [_finishButton setTitle:[NSString stringWithFormat:@"完成(%lu)", (unsigned long)_selectedAssets.count] forState:UIControlStateNormal];
}

- (void)layoutScrollView
{
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * _assets.count, CGRectGetHeight(_scrollView.frame));

    for (int i = 0 ; i < _scrollView.subviews.count; i++) {
        UIView *sv = _scrollView.subviews[i];
        
        if ([sv isKindOfClass:[UIImageView class]]) {
            sv.frame = CGRectMake(i * CGRectGetWidth(self.view.frame),
                                  0, CGRectGetWidth(self.view.frame), CGRectGetHeight(_scrollView.frame));
        }
    }
    
    CGFloat offsetX = CGRectGetWidth(self.view.frame) * _currentIndex;
    [_scrollView setContentOffset:CGPointMake(offsetX, 0) animated:NO];
}

- (void)setUpRightNav
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 40);
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, -5)];
    [btn setImage:[UIImage imageNamed:@"navUnSelected"] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:@"navSelected"] forState:UIControlStateSelected];
    [btn addTarget:self action:@selector(rightNavItemAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)changeRightNavItem:(BOOL)isSelected
{
    UIButton *btn = self.navigationItem.rightBarButtonItem.customView;
    
    [btn setSelected:isSelected];
}

- (void)rightNavItemAction:(UIButton *)sender
{
    [sender setSelected:!sender.isSelected];
    
    // 如果变为选中则添加,如果变为未选中则移除
    if (sender.isSelected) {
        [_selectedAssets addObject:_assets[_currentIndex]];
        if (_selectedAssets.count > 0)
        [_collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:_selectedAssets.count - 1 inSection:0]]];
    } else {
        NSUInteger i = [_selectedAssets indexOfObject:_assets[_currentIndex]];
        [_selectedAssets removeObject:_assets[_currentIndex]];
        [_collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]]];
    }
    
    if (_selectedAssets.count > 0)
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedAssets.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    
    [_finishButton setTitle:[NSString stringWithFormat:@"完成(%lu)", (unsigned long)_selectedAssets.count] forState:UIControlStateNormal];
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (_collectionView == scrollView) return ;
    
    _currentIndex = (int)(scrollView.contentOffset.x / CGRectGetWidth(self.view.frame));
    
    ALAsset *asset = _assets[_currentIndex];
    BOOL isSelected = [_selectedAssets containsObject:asset];
    
    [self changeRightNavItem:isSelected];
}

#pragma mark - CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _selectedAssets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SelectedCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectedCollectionViewCell" forIndexPath:indexPath];
    
    // 取缩略图
    ALAsset *asset = _selectedAssets[indexPath.row];
    cell.imgV.image = [UIImage imageWithCGImage:asset.thumbnail];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(40, 40);  
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)finishButtonAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
