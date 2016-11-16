//
//  VOAFavoritesViewController.h
//  VOA
//
//  Created by xuzepei on 6/16/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VOAFavoritesViewController : UIViewController 
<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>
{
	
	UITableView* _tableView;
	NSMutableArray* _itemArray;
	
	BOOL _cellEditing;
	
@private
	NSFetchedResultsController *fetchedResultsController;

}

@property(nonatomic,retain)UITableView* _tableView;
@property(nonatomic,retain)NSMutableArray* _itemArray;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)initTableView;
- (void)updateContent;
- (void)fetch;

@end
