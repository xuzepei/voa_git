//
//  VOACategoriesDetailViewController.m
//  VOA
//
//  Created by xuzepei on 6/17/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOACategoriesDetailViewController.h"
#import "VOACategory.h"
#import "Item.h"
#import "VOACategoriesDetailTableViewCell.h"
#import "RCTool.h"
#import "VOATextViewController.h"
#import "VOAAppDelegate.h"


@implementation VOACategoriesDetailViewController
@synthesize _tableView;
@synthesize _itemArray;
@synthesize _category;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        [[NSNotificationCenter defaultCenter] addObserver: self
												 selector: @selector(reloadItem:)
													 name: RELOAD_ITEM_NOTIFICATION 
												   object: nil];
		
		_itemArray = [[NSMutableArray alloc] init];
		self.navigationItem.rightBarButtonItem = self.editButtonItem;
		
		[self initTableView];
		
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTableView];
    
    [self rearrange];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    [self showScreenAd];
	
    if(_tableView)
        [_tableView reloadData];
    
    [self rearrange];
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self._tableView = nil;
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self._itemArray = nil;
	self._tableView = nil;
	self._category = nil;
	
    [super dealloc];
}

- (void)rearrange
{
    if(_tableView)
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
        
        CGRect rect = _tableView.frame;
        rect.size.height = height;
        _tableView.frame = rect;
        
        [_tableView reloadData];
    }
    
}

- (void)initTableView
{
    if(nil == _tableView)
    {
        CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT;
        if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
        {
            height = [RCTool getScreenSize].height;
        }
        
        //init table view
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,[RCTool getScreenSize].width,height)
                                                  style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|
        UIViewAutoresizingFlexibleBottomMargin|
        UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
	
	[self.view addSubview:_tableView];
}

NSComparisonResult dateSort(Item *s1, Item *s2, void *context) 
{
    NSDate *d1 = [RCTool getDateByString:s1.pubDate];
    NSDate *d2 = [RCTool getDateByString:s2.pubDate];
    return [d2 compare:d1];
}

- (NSArray*)getItems:(NSSet*)items
{
	if(nil == items)
		return nil;
	
	NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
	for(Item* item in [items allObjects])
	{
		if(NO == [item.isHidden boolValue])
		{
			[array addObject:item];
		}
	}
	
	return array;
}

- (void)updateContent: (VOACategory*)category
{
	if(nil == category)
		return;
	
	self._category = category;
	self.navigationItem.title = _category.title;
	
	[self reloadData];
}

- (void)reloadData
{
    if(nil == _category)
        return;

    NSSet* items = _category.items;
	if(items)
	{
		NSArray* itemsArray = [self getItems:items];
		if([itemsArray count])
		{
            [_itemArray removeAllObjects];
			itemsArray = [itemsArray sortedArrayUsingFunction:dateSort context:nil];
			[_itemArray addObjectsFromArray:itemsArray];
		}
	}
    
    if(_tableView)
        [_tableView reloadData];
}

- (void)reloadItem:(NSNotification*)notification
{
    [self reloadData];
}


#pragma mark -
#pragma mark UITableView delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (id)getCellDataAtIndexPath: (NSIndexPath*)indexPath
{
	if(indexPath.row >= [_itemArray count])
		return nil;
	
	return [_itemArray objectAtIndex: indexPath.row];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return [_itemArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 70.0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) 
	{
		cell = [[[VOACategoriesDetailTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault 
												  reuseIdentifier: cellId] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	VOACategoriesDetailTableViewCell* temp = (VOACategoriesDetailTableViewCell*)cell;
	if(temp)
	{
		Item* item = (Item*)[self getCellDataAtIndexPath:indexPath];
		if(item)
		{
			VOACategoriesDetailTableViewCell* temp = (VOACategoriesDetailTableViewCell*)cell;
			[temp updateContent: item];
			if([RCTool isExistingFile:[RCTool getFilePathByUrl:item.address]])
            {
				temp.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                UIImageView* imageButton = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35,35)] autorelease];
                imageButton.image = [UIImage imageNamed:@"play_button2"];
                temp.accessoryView = imageButton;
            }
            else
            {
                temp.accessoryView = nil;
                temp.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
		}
	}
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
	Item* item = (Item*)[self getCellDataAtIndexPath: indexPath];
	if(item)
	{
        //[RCTool showInterstitialAd];
        
		VOATextViewController* temp = [[[VOATextViewController alloc] 
													initWithNibName:@"VOATextViewController" 
													bundle:nil] autorelease];

		temp.hidesBottomBarWhenPushed = YES;
		[temp updateContent:item type:0];
		[self.navigationController pushViewController:temp animated:YES];
	}
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath;
{
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
	Item* item = (Item*)[self getCellDataAtIndexPath: indexPath];
	if(item)
	{
		VOATextViewController* temp = [[[VOATextViewController alloc] 
										initWithNibName:@"VOATextViewController" 
										bundle:nil] autorelease];
		temp.hidesBottomBarWhenPushed = YES;
		[temp updateContent: item type:0];
		[self.navigationController pushViewController:temp animated:YES];
	}
}

#pragma mark -
#pragma mark edit cell

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
    [_tableView setEditing:editing animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	VOACategoriesDetailTableViewCell* cell = (VOACategoriesDetailTableViewCell*)[tableView cellForRowAtIndexPath: indexPath];
	if(cell)
	{
		Item* item = (Item*)[self getCellDataAtIndexPath:indexPath];
		if(item)
		{
			item.isHidden = [NSNumber numberWithBool:YES];
			[RCTool saveCoreData];
		}
		
		[self removeItemByIndexPath:indexPath];
		[_tableView reloadData];
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (self.editing == NO) 
		return UITableViewCellEditingStyleNone;
	
	return UITableViewCellEditingStyleDelete;
}

- (void)showScreenAd
{
    VOAAppDelegate* appDelegate = (VOAAppDelegate*)[UIApplication sharedApplication].delegate;
    [appDelegate getAdInterstitial];
}

@end
