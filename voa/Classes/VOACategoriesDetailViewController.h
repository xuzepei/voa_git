//
//  VOACategoriesDetailViewController.h
//  VOA
//
//  Created by xuzepei on 6/17/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VOACategory;
@interface VOACategoriesDetailViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>
{
	UITableView* _tableView;
	NSMutableArray* _itemArray;
	VOACategory* _category;

}

@property(nonatomic,retain)UITableView* _tableView;
@property(nonatomic,retain)NSMutableArray* _itemArray;
@property(nonatomic,retain)VOACategory* _category;

- (void)initTableView;
- (void)updateContent: (VOACategory*)category;
- (void)reloadData;

@end
