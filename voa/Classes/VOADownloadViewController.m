//
//  VOADownloadViewController.m
//  VOA
//
//  Created by xuzepei on 7/1/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOADownloadViewController.h"
#import "VOADownloadTableViewCell.h"
#import "RCTool.h"
#import "Item.h"
#import "VOADownloadLoader.h"
#import "VOATextViewController.h"
#import "VOATextImporter.h"

@interface VOADownloadViewController(Private)
- (void)updateBadgeValue;
- (void)cancelHttpRequestForCell:(VOADownloadTableViewCell*)cell;
- (NSUInteger)removeDownloadItem: (NSString*)urlString;
@end


@implementation VOADownloadViewController
@synthesize _itemArray;
@synthesize _textOperationQueue;
@synthesize fetchedResultsController;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
		UITabBarItem* item = [[UITabBarItem alloc] initWithTabBarSystemItem: UITabBarSystemItemDownloads
																		tag: TT_DOWNLOADS];
		self.tabBarItem = item;
		[item release];
		
		self.title = NSLocalizedString(@"Downloads", @"");
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		
		_itemArray = [[NSMutableArray alloc] init];
		_textOperationQueue = [[NSOperationQueue alloc] init];
		
		// create and configure the table view
		self.tableView.alwaysBounceVertical = YES;
		self.tableView.delegate = self;
		self.tableView.dataSource = self;
		self.tableView.scrollEnabled = YES;
		
		[self fetch];
		[self updateBadgeValue];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(addDownloadItem:)
													 name: @"addDownloadItem" 
												   object: nil];
		
		[[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(clickRightImageButton:)
													 name: @"clickRightImageButton" 
												   object: nil];
		
		_cellEditing = NO;
    }
    return self;
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear: animated];	
	[self updateBadgeValue];
    
    [self rearrange];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	[self rearrange];
}

- (void)rearrange
{
    if(self.tableView)
    {
        UIInterfaceOrientation statusBarOrientation =[UIApplication sharedApplication].statusBarOrientation;
        
        CGFloat height = 0.0;
        if(UIInterfaceOrientationLandscapeLeft ==statusBarOrientation || UIInterfaceOrientationLandscapeRight ==statusBarOrientation)
        {
            height = [RCTool getScreenSize].width - STATUS_BAR_HEIGHT - self.navigationController.navigationBar.frame.size.height - TAB_BAR_HEIGHT;
            if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
            {
                height = [RCTool getScreenSize].width;
            }
        }
        else
        {
            height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT;
            if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
            {
                height = [RCTool getScreenSize].height;
            }
        }
        
        CGRect rect = self.tableView.frame;
        rect.size.height = height;
        self.tableView.frame = rect;
        
        [self.tableView reloadData];
    }
    

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[_itemArray release];
	[_textOperationQueue release];
	[fetchedResultsController release];
    [super dealloc];
}

#pragma mark -
#pragma mark Fetched results controller

- (void)fetch 
{
    NSError *error = nil;
	[[self fetchedResultsController] performFetch:&error];
	if([fetchedResultsController.fetchedObjects count])
		[_itemArray addObjectsFromArray:fetchedResultsController.fetchedObjects];
	
    [self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController 
{
	if (fetchedResultsController == nil) {
		
		NSSortDescriptor *sortDescriptor = nil;
		NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isDownloaded == YES"];
		NSManagedObjectContext* context = [RCTool getManagedObjectContext];
		
		//set entity
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Item" 
												  inManagedObjectContext:context];
		[fetchRequest setEntity:entity];
		
		//set predicate
		[fetchRequest setPredicate: predicate];
		
		//set sortdescriptors
        NSArray *sortDescriptors = [[NSArray alloc] init];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
																									managedObjectContext:context 
																									  sectionNameKeyPath:nil
																											   cacheName:nil];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
        
        [aFetchedResultsController release];
        [fetchRequest release];
        [sortDescriptor release];
        [sortDescriptors release];
    }
	
	return fetchedResultsController;
}


#pragma mark -
#pragma mark UITableView delegate methods

- (id)getCellDataAtIndexPath: (NSIndexPath*)indexPath
{
	if(1 == indexPath.section)
	{
		if(indexPath.row >= [_itemArray count])
			return nil;
		
		return [_itemArray objectAtIndex: indexPath.row];
	}
	
	return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(0 == section)
		return [_itemArray count];
	
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(0 == indexPath.section)
		return 60.0;
	
	return 30;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *downloadCellID = @"downloadcell";
	//static NSString *clearCellID = @"clearcell";
	
	UITableViewCell *cell = nil;
	
	if(0 == indexPath.section)
	{
		cell = [tableView dequeueReusableCellWithIdentifier: downloadCellID];
		
		if(nil == cell)
		{
			cell = [[[VOADownloadTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault 
												   reuseIdentifier: downloadCellID] autorelease];
			
			cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		
		VOADownloadTableViewCell* temp = (VOADownloadTableViewCell*)cell;
		Item* item = [self getItemByIndexPath: indexPath];
		if(item)
		{
			[temp updateContent: item
					  indexPath: indexPath 
						  count: [_itemArray count]];
			
			[temp rearrange: _cellEditing];
		}
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath: indexPath animated: NO];
	
	
	if(0 == indexPath.section)
	{
		VOADownloadTableViewCell* cell = (VOADownloadTableViewCell*)[self.tableView 
																	 cellForRowAtIndexPath:indexPath];
		if(cell)
		{
			if(IT_DISCLOSURE == cell._rightImageType)
			{
				[self clickPlayButton: cell];
			}
		}
	}
}

#pragma mark -
#pragma mark edit cell

- (Item*)getItemByIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.row >= [_itemArray count])
		return nil;
	
	return [_itemArray objectAtIndex:indexPath.row];
}

- (void)removeItemByIndexPath:(NSIndexPath*)indexPath
{
	if(indexPath.row >= [_itemArray count])
		return;
	
	return [_itemArray removeObjectAtIndex:indexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
	
	for(int i = 0 ; i < [_itemArray count]; i++)
	{
		VOADownloadTableViewCell* cell = (VOADownloadTableViewCell*)[self.tableView cellForRowAtIndexPath: 
																   [NSIndexPath indexPathForRow:i inSection:0]];
		[cell rearrange: editing];
	}
	
	_cellEditing = editing;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	VOADownloadTableViewCell* cell = (VOADownloadTableViewCell*)[tableView cellForRowAtIndexPath: indexPath];
	if(cell)
	{
		[self clickCancelButton: cell];
		Item* item = [self getItemByIndexPath:indexPath];
		if(item)
		{
			item.isDownloaded = [NSNumber numberWithBool:NO];
			[RCTool saveCoreData];
		}
		
		[self removeItemByIndexPath:indexPath];
		[self.tableView reloadData];
		[self updateBadgeValue];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (self.editing == NO) 
		return UITableViewCellEditingStyleNone;
	
	return UITableViewCellEditingStyleDelete;
}

#pragma mark -
#pragma mark - self-define operation function

- (VOADownloadTableViewCell*)getCellByUrl:(NSString*)urlString
{
	VOADownloadTableViewCell* cell = nil;
	NSInteger index = -1;
	NSUInteger i = 0;
	for(Item* item in _itemArray)
	{
		NSString* temp = item.address;
		if([temp isEqualToString: urlString])
		{
			index = i;
			break;
		}
		
		i++;
	}
	
	cell = (VOADownloadTableViewCell*)[self.tableView cellForRowAtIndexPath: [NSIndexPath indexPathForRow:index inSection:0]];
	return cell;
}


- (void)updateBadgeValue
{
	NSUInteger i = 0;
	for(Item* item in _itemArray)
	{
		if([item.address length])
		{
			if(NO == [RCTool isExistingFile:
					  [RCTool getFilePathByUrl:item.address]])
			{
				i++;
			}
		}
	}
	
	if(i)
		self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d",i];
	else
		self.tabBarItem.badgeValue = nil;
}

//cancel downloading
- (void)clickCancelButton:(VOADownloadTableViewCell*)cell
{
	VOADownloadLoader* temp = [VOADownloadLoader sharedInstance];
	[temp cancelHttpRequest: cell._item.address];
	[cell updateStatusForCancel];
}

//redownload
- (void)clickReDownloadButton:(VOADownloadTableViewCell*)cell
{
	NSLog(@"clickReDownloadButton");
	
	[cell updatePercentage:0];	
	VOADownloadLoader* temp = [VOADownloadLoader sharedInstance];
	NSString* urlString = cell._item.address;
	[temp startHttpRequest:urlString delegate:self token:nil];
	
	[self updateBadgeValue];
	[self.tableView reloadData];
}

//play
- (void)clickPlayButton:(VOADownloadTableViewCell*)cell
{
	NSLog(@"clickPlayButton");
	
	VOATextViewController* temp = [[[VOATextViewController alloc] 
									initWithNibName:@"VOATextViewController" 
									bundle:nil] autorelease];
	temp.hidesBottomBarWhenPushed = YES;
	[temp updateContent: cell._item type:1];
	[self.navigationController pushViewController:temp animated:YES];

}

#pragma mark -
#pragma mark Notification

- (BOOL)isInItemArray:(Item*)item
{
	if(nil == item)
		return NO;
	
	for(Item* temp in _itemArray)
	{
		if([temp.id isEqualToString:item.id])
			return YES;
	}
	
	return NO;
}

- (void)addDownloadItem: (NSNotification*)notification
{
	NSDictionary* dict = [notification userInfo];
	Item* item = [dict objectForKey: @"item"];
	if(0 == [item.address length] || [item.isDownloaded boolValue])
		return;

	item.isDownloaded = [NSNumber numberWithBool:YES];
	[RCTool saveCoreData];
	
	VOADownloadLoader* temp = [VOADownloadLoader sharedInstance];
	[temp download:item.address delegate:self token: nil];
	
	if(NO == [self isInItemArray:item])
		[_itemArray addObject: item];
	
	[self updateBadgeValue];
	[self.tableView reloadData];
	
}

- (void)clickRightImageButton: (NSNotification*)notification
{
	VOADownloadTableViewCell* cell = [notification object];
	
	switch (cell._rightImageType) 
	{
		case IT_PAUSE:
		{
			[self clickCancelButton: cell];
			break;
		}
		case IT_DOWNLOAD:
		{
			[self clickReDownloadButton: cell];
			break;
		}
		case IT_DISCLOSURE:
		{
			[self clickPlayButton: cell];
			break;
		}
		default:
			break;
	}
}

#pragma mark -
#pragma mark VOADownloadLoaderDelegate methods

- (void) didFinishDownload:(id)result token: (id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSString* url = [dict valueForKey: @"url"];
	
	VOADownloadTableViewCell* cell = [self getCellByUrl: url];
	if(cell)
	{
		[cell updatePercentage: 1.0];
	}

	[self updateBadgeValue];
}

- (void)didFailDownload: (id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSString* url = [dict valueForKey: @"url"];
	
	VOADownloadTableViewCell* cell = [self getCellByUrl: url];
	if(cell)
	{
		[cell updateStatusForFailed];
	}
	
	[RCTool deleteFileByUrl: url];
	[self updateBadgeValue];
}

- (void)updatePercentage: (float)percentage token: (id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSString* url = [dict valueForKey: @"url"];
	VOADownloadTableViewCell* cell = [self getCellByUrl: url];
	if(cell)
	{
		[cell updatePercentage: percentage];
	}
}





@end
