//
//  VOACategoriesViewController.h
//  VOA
//
//  Created by xuzepei on 6/16/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VOACategoriesViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate>
{
	
	UITableView* _tableView;
	NSMutableArray* _itemArray;
	NSOperationQueue* _operationQueue;
	NSOperationQueue* _textOperationQueue;
	UIActivityIndicatorView* _indicatorView;
	NSMutableArray* _requestArray;
	NSMutableArray* _cacheItemArray;
	
	int _sum;
	BOOL _isRefreshing;
	
@private
	NSFetchedResultsController *fetchedResultsController;
}

@property(nonatomic,retain)UITableView* _tableView;
@property(nonatomic,retain)NSMutableArray* _itemArray;
@property(nonatomic,retain)NSOperationQueue* _operationQueue;
@property(nonatomic,retain)NSOperationQueue* _textOperationQueue;
@property(nonatomic,retain)UIActivityIndicatorView* _indicatorView;
@property(nonatomic,retain)NSMutableArray* _requestArray;
@property(nonatomic,retain)NSMutableArray* _cacheItemArray;
@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)initTableView;
- (void)updateContent;
- (void)fetch;
- (void)checkInternetConnection;
- (void)initCategories;

@end
