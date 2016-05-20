//
//  AssetsGroupMenu.h
//  PhotoLibraryDemo
//
//  Created by 张齐朴 on 16/5/20.
//  Copyright © 2016年 张齐朴. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void(^AssetsGroupItemSelectAction)(ALAssetsGroup *group);

@interface AssetsGroupMenu : UIView <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *assetsGroups;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (copy, nonatomic) AssetsGroupItemSelectAction assetsGroupItemSelectAction;

@end
