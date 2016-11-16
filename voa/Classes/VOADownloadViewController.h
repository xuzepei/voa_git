//
//  VOADownloadViewController.h
//  VOA
//
//  Created by xuzepei on 7/1/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;
@class VOADownloadTableViewCell;
@interface VOADownloadViewController : UITableViewController 
<UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate>
{
	NSMutableArray* _itemArray;
	BOOL _cellEditing;
	NSOperationQueue* _textOperationQueue;
	
@private
	NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, retain) NSMutableArray* _itemArray;
@property (nonatomic, retain) NSOperationQueue* _textOperationQueue;

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;

- (void)fetch;
- (Item*)getItemByIndexPath:(NSIndexPath*)indexPath;
- (void)clickPlayButton:(VOADownloadTableViewCell*)cell;
- (void)clickCancelButton:(VOADownloadTableViewCell*)cell;

@end
