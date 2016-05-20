//
//  PhotoLibarayCollectionViewCell.m
//  PhotoLibraryDemo
//
//  Created by 张齐朴 on 16/5/19.
//  Copyright © 2016年 张齐朴. All rights reserved.
//

#import "PhotoLibarayCollectionViewCell.h"

@implementation PhotoLibarayCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (IBAction)selectButtonAction:(id)sender {
    [_selectButton setSelected:!_selectButton.isSelected];
    
    if (_selectItemBlock) {
        _selectItemBlock(_selectButton.isSelected, _indexPath);
    }
}

@end
