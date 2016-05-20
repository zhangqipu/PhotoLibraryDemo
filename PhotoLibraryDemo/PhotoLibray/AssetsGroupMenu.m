//
//  AssetsGroupMenu.m
//  PhotoLibraryDemo
//
//  Created by 张齐朴 on 16/5/20.
//  Copyright © 2016年 张齐朴. All rights reserved.
//

#import "AssetsGroupMenu.h"

@implementation AssetsGroupMenu

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
}

#pragma mark - TableVeiewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _assetsGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AssetsGroupMenuCell"];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"AssetsGroupMenu" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.textLabel setTextColor:[UIColor whiteColor]];
    }
    
    ALAssetsGroup *group = _assetsGroups[indexPath.row];
    cell.textLabel.text = [group valueForProperty:ALAssetsGroupPropertyName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_assetsGroupItemSelectAction) {
        _assetsGroupItemSelectAction(_assetsGroups[indexPath.row]);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
