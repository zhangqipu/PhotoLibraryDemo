//
//  PhotoLookViewController.m
//  PhotoLibraryDemo
//
//  Created by 张齐朴 on 16/5/19.
//  Copyright © 2016年 张齐朴. All rights reserved.
//

#import "PhotoLookViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

@interface PhotoLookViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation PhotoLookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)setUpScrollView {
    
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * _assets.count, CGRectGetHeight(_scrollView.frame));
    
    for (int i = 0; i < _assets.count; i++) {
        UIImageView *imgV = [[UIImageView alloc]
                             initWithFrame:CGRectMake(i * CGRectGetWidth(self.view.frame),
                                                      0, CGRectGetWidth(self.view.frame), CGRectGetHeight(_scrollView.frame))];
        ALAsset *asset = _assets[i];
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        
        imgV.image = [UIImage imageWithCGImage:representation.fullScreenImage];
        
        [_scrollView addSubview:imgV];
    }
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self setUpScrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
