//
//  VOACategoriesViewController.m
//  VOA
//
//  Created by xuzepei on 6/16/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOACategoriesViewController.h"
#import "VOACategoriesTableViewCell.h"
#import "VOAFeaturedImporter.h"
#import "RCTool.h"
#import "Item.h"
#import "VOACategory.h"
#import "VOACategoriesDetailViewController.h"
#import "VOATextImporter.h"
#import "RCTool.h"
#import "Reachability.h"
#import "VOAFeaturedLoader.h"

@implementation VOACategoriesViewController
@synthesize _tableView;
@synthesize _itemArray;
@synthesize _operationQueue;
@synthesize fetchedResultsController;
@synthesize _textOperationQueue;
@synthesize _indicatorView;
@synthesize _requestArray;
@synthesize _cacheItemArray;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        
        UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"Topics" 
														   image:[UIImage imageNamed:@"categories.png"]
															 tag:TT_CATEGORIES];
		self.tabBarItem = item;
		[item release];
		
		self.navigationItem.title = @"VOA Special English";
		
		UIBarButtonItem* temp = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
																			  target:self
																			  action:@selector(clickRefreshButton:)];
		self.navigationItem.rightBarButtonItem = temp;
		[temp release];
        
        [[NSNotificationCenter defaultCenter] addObserver: self 
												 selector: @selector(reachabilityChanged:) 
													 name: kReachabilityChangedNotification 
												   object: nil];
        
        [self initCategories];
		
		_itemArray = [[NSMutableArray alloc] init];
		_operationQueue = [[NSOperationQueue alloc] init];
		[_operationQueue setMaxConcurrentOperationCount:1];
		
		_textOperationQueue = [[NSOperationQueue alloc] init];
		[_textOperationQueue setMaxConcurrentOperationCount:1];
		
		_requestArray = [[NSMutableArray alloc] init];
		_cacheItemArray = [[NSMutableArray alloc] init];
		
		
		//self.title = NSLocalizedString(@"Featured",@"");

		_indicatorView = [[UIActivityIndicatorView alloc] 
						  initWithActivityIndicatorStyle:
						  UIActivityIndicatorViewStyleGray];
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
    [super viewWillAppear: animated];
    
    if(_tableView)
        [_tableView reloadData];
    
    [self rearrange];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
    if(_indicatorView)
        [_indicatorView removeFromSuperview];
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
    
    if(_indicatorView)
    {
        _indicatorView.center = CGPointMake(self.view.bounds.size.width/2.0,self.view.bounds.size.height/2.0);
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
    
    self._tableView = nil;
}


- (void)dealloc {
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[_itemArray release];
	[_tableView release];
	[_operationQueue release];
	[_textOperationQueue release];
	[_indicatorView release];
	[fetchedResultsController release];
	[_requestArray release];
	[_cacheItemArray release];
	
    [super dealloc];
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

- (void)clickRefreshButton:(id)sender
{
	if(NO == [RCTool isReachableViaInternet])
	{
        [RCTool showAlert:NSLocalizedString(@"Hint",@"") message:NSLocalizedString(@"Internet Connection Required.", @"")];

		return;
	}
	
	[self updateContent];
}

- (void)updateContent
{
	//[self checkInternetConnection];
	
	if(NO == [RCTool isReachableViaInternet])
		return;
	
	if(_isRefreshing)
		return;
	
	_isRefreshing = YES;
    
   NSArray* indexArray = [[NSArray alloc] initWithObjects:@"a",@"b", @"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",nil];
    
    NSMutableArray* urlArray = [[NSMutableArray alloc] init];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/today/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/news/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/stories/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/mosaic/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/people/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/nation/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/exploration/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/health/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/science/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/economic/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/agriculture/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/develop/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/education/"];
    [urlArray addObject:@"http://www.voa365.com/specialVOA/word/"];
    
    int i = 0;
    for(NSString* urlString in urlArray)
    {
        VOAFeaturedImporter* importer = [[[VOAFeaturedImporter alloc] init] autorelease];
        importer._delegate = self;
        importer._requestUrl = urlString;
        importer._order = [indexArray objectAtIndex:i];
        [_operationQueue addOperation: importer];
        
        i++;
    }
    
    [indexArray release];
    [urlArray release];

}


- (void)initCategories
{
  NSArray* indexArray = [[NSArray alloc] initWithObjects:@"a",@"b", @"c",@"d",@"e",@"f",@"g",@"h",@"i",@"j",@"k",@"l",@"m",@"n",@"o",nil];
    
   NSArray* titleArray = [[NSArray alloc] initWithObjects:@"Last News",@"This is America", @"In the News",@"American Stories",@"American Mosaic",@"People in America",@"Making of a Nation",@"Explorations",@"Health Report",@"Science in the News",@"Economics Report",@"Agriculture Report",@"Technology Report",@"Education Report",@"Words and Their Stories",nil];
    
    for(int i = 0; i < 15; i++)
    {
        NSPredicate* predicate = nil;
        NSManagedObjectID* objectID = nil;
        VOACategory* category = nil;

        NSString* index = [indexArray objectAtIndex:i];
        predicate = [NSPredicate predicateWithFormat:@"id == %@",index];
        objectID = [RCTool getExistingEntityObjectIDForName: @"VOACategory"
                                                  predicate: predicate
                                            sortDescriptors: nil
                                                    context: [RCTool getManagedObjectContext]];
        category = nil;
        if(nil == objectID)
        {
            category = [RCTool insertEntityObjectForName:@"VOACategory"
                                    managedObjectContext:[RCTool getManagedObjectContext]];
            
            category.id = index;
            category.order = index;
            category.title = [titleArray objectAtIndex:i];
            
        }
    }

    [indexArray release];
    [titleArray release];
    
    [RCTool saveCoreData];
    
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
	return 60.0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) 
	{
		cell = [[[VOACategoriesTableViewCell alloc] initWithStyle: UITableViewCellStyleDefault 
											  reuseIdentifier: cellId] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
	
	VOACategoriesTableViewCell* temp = (VOACategoriesTableViewCell*)cell;
	if(temp)
	{
		VOACategory* category = [self getCellDataAtIndexPath:indexPath];
		if(category)
		{
			VOACategoriesTableViewCell* temp = (VOACategoriesTableViewCell*)cell;
			[temp updateContent: category];
			
		}
	}
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
	VOACategory* category = (VOACategory*)[self getCellDataAtIndexPath: indexPath];
	if(category)
	{
		VOACategoriesDetailViewController* temp = [[[VOACategoriesDetailViewController alloc] 
										  initWithNibName:@"VOACategoriesDetailViewController" 
										  bundle:nil] autorelease];
		[temp updateContent: category]; 
		[self.navigationController pushViewController:temp animated:YES];
	}
}

#pragma mark -
#pragma mark Fetched results controller

- (void)fetch 
{
    [_itemArray removeAllObjects];
    
    NSError *error = nil;
	[[self fetchedResultsController] performFetch:&error];
	if([fetchedResultsController.fetchedObjects count])
		[_itemArray addObjectsFromArray:fetchedResultsController.fetchedObjects];
	
    if(_tableView)
        [_tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController 
{
	
	if (fetchedResultsController == nil) {
		
		NSSortDescriptor *sortDescriptor = nil;
		NSPredicate* predicate = nil;
		NSManagedObjectContext* context = [RCTool getManagedObjectContext];
		
		sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" 
													 ascending:YES
													  selector:@selector(caseInsensitiveCompare:)];
        
		//set entity
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"VOACategory"
												  inManagedObjectContext:context];
		[fetchRequest setEntity:entity];
		
		//set predicate
		[fetchRequest setPredicate: predicate];
		
        
		//set sortdescriptors
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
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
#pragma mark http request

- (void)importerDidSave:(NSNotification *)notification
{
	//如果是当前线程的managedObjectContext,则不用merge
	if ([notification object] == [RCTool getManagedObjectContext]) 
		return;
	
	if ([NSThread isMainThread]) 
	{
		NSManagedObjectContext* context = [RCTool getManagedObjectContext];
        [context mergeChangesFromContextDidSaveNotification: notification];
		
	}
    else 
	{
		//转到主线程执行，直到完成
        [self performSelectorOnMainThread:@selector(importerDidSave:) 
							   withObject:notification 
							waitUntilDone:YES];
    }
}


- (void)featuredImporterDidStart:(id)token
{
	//_indicatorView.center = CGPointMake(160,160);
	[self.view addSubview: _indicatorView];
	
	[_indicatorView startAnimating];
}

- (void)featuredImporterDidFinish:(id)token
{
	_isRefreshing = NO;
	
	[self fetch];

	[_indicatorView stopAnimating];
	[_indicatorView removeFromSuperview];
}

- (void)featuredImporterDidFail:(id)token
{

}

- (void)willStartHttpRequest:(id)token
{
	
}

- (void)didFinishHttpRequest:(id)result token:(id)token
{
}

- (void)didFailHttpRequest:(id)token
{

}

- (void)textImporterDidFinish:(id)token
{
	VOATextImporter* importer = (VOATextImporter*)token;

	for(Item* temp in _cacheItemArray)
	{
		if([temp.link isEqualToString:importer._requestUrl])
		{
			[_cacheItemArray removeObject:temp];
			break;
		}
	}
}

#pragma mark -
#pragma mark Reachability Notification

- (void)checkInternetConnection
{
	NSLog(@"checkInternetConnection");
	
	Reachability* internetReach = [[Reachability reachabilityWithHostName:@"www.apple.com"] retain];
	[internetReach startNotifier];
    [internetReach release];
}

- (void)reachabilityChanged:(NSNotification*)notification
{
	Reachability* internetReach = [notification object];
	NSParameterAssert([internetReach isKindOfClass: [Reachability class]]);
	
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            [RCTool setReachabilityType: NotReachable];
			break;
        }
        case ReachableViaWWAN:
        {
            [RCTool setReachabilityType: ReachableViaWWAN];
			break;
        }
        case ReachableViaWiFi:
        {
			[RCTool setReachabilityType: ReachableViaWiFi];
			break;
		}
		default:
		{
			[RCTool setReachabilityType: NotReachable];
			break;
		}
	}
	
	if(NotReachable == [RCTool getReachabilityType])
	{
		[_operationQueue cancelAllOperations];
		[_textOperationQueue cancelAllOperations];
		
		[_indicatorView stopAnimating];
		[_indicatorView removeFromSuperview];
		
		_sum = 0;
		_isRefreshing = 0;
	}
	else
	{
		
	}
}


@end
