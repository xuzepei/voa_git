//
//  VOASettingViewController.m
//  VOA
//
//  Created by xuzepei on 5/31/11.
//  Copyright 2011 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOASettingViewController.h"
#import "VOABigFontCell.h"
#import "VOAAutoScrollCell.h"
#import "RCTool.h"
#import "Item.h"
#import "VOARefreshCell.h"
#import "VOAWifiOnlyCell.h"
#import "RCImageLoader.h"

#define SEGMENT_REFRESH 0
#define SEGMENT_TEXT 1
#define SEGMENT_CLEANUP 2
#define SEGMENT_RECOMMENDED 3

#define CLEANUP_TAG 111

@implementation VOASettingViewController
@synthesize _tableView;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
		UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"Settings" 
														   image:[UIImage imageNamed:@"settings.png"]
															 tag:TT_SETTINGS];
		self.tabBarItem = item;
		[item release];
		
		self.navigationItem.title = @"Settings";
		
		UIBarButtonItem* leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Recommend" 
																			  style:UIBarButtonItemStylePlain 
																			 target:self 
																			 action:@selector(clickLeftBarButtonItem:)];
		
        //		UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
        //																			   style:UIBarButtonItemStyleDone 
        //																			  target:self 
        //																			  action:@selector(clickRightBarButtonItem:)];
        
		self.navigationItem.rightBarButtonItem = leftBarButtonItem;
		[leftBarButtonItem release];
        
        
        _itemArray = [[NSMutableArray alloc] init];
		
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
	
	if(_tableView)
		[_tableView reloadData];
    
    [self rearrange];
    
    [self requestContent];
}

- (void)requestContent
{
    [self.itemArray removeAllObjects];
    
    NSArray* otherApps = [RCTool getOtherApps];
    if([otherApps count])
        [self.itemArray addObjectsFromArray:otherApps];
    
    [_tableView reloadData];
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
    
//    if(_indicatorView)
//    {
//        _indicatorView.center = CGPointMake(self.view.bounds.size.width/2.0,self.view.bounds.size.height/2.0);
//    }
    
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
	
	[_tableView release];
	_tableView = nil;
    
    self.itemArray = nil;
    
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
                                                  style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|
        UIViewAutoresizingFlexibleBottomMargin|
        UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
	
	[self.view addSubview:_tableView];
}

#pragma mark -
#pragma mark UITableView delegate methods

- (id)getCellDataAtIndexPath: (NSIndexPath*)indexPath
{
    if(SEGMENT_RECOMMENDED == indexPath.section)
    {
        if(indexPath.row >= [self.itemArray count])
            return nil;
        
        return [self.itemArray objectAtIndex: indexPath.row];
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
	return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(SEGMENT_REFRESH == section)
	{
		return @"Refresh";
	}
	else if(SEGMENT_TEXT == section)
	{
		return @"Text";
	}
	else if(SEGMENT_CLEANUP == section)
	{
		return @"Clean up";
	}
    else if(SEGMENT_RECOMMENDED == section && [self.itemArray count])
        return @"Recommended Apps";
    
	return @"";
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	if(SEGMENT_REFRESH == section)
		return 1;
	else if(SEGMENT_TEXT == section)
		return 2;
	else if(SEGMENT_CLEANUP == section)
		return 1;
    else if(SEGMENT_RECOMMENDED == section)
        return [self.itemArray count];
	
	return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(SEGMENT_RECOMMENDED == indexPath.section)
        return 60.0;
    
	return 44.0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	//static NSString *cellId = @"cellId";
    static NSString *cellId1 = @"cellId1";
	//static NSString *cellId2 = @"cellId2";
	static NSString *cellId3 = @"cellId3";
	static NSString *cellId4 = @"cellId4";
	static NSString *cellId5 = @"cellId5";
	static NSString *cellId6 = @"cellId6";
	
	UITableViewCell *cell = nil;
	if(SEGMENT_REFRESH == indexPath.section)
	{
		if(0 == indexPath.row)
		{
			cell = [tableView dequeueReusableCellWithIdentifier:cellId1];
			if (cell == nil) 
			{
				cell = [[[VOARefreshCell alloc] initWithStyle: UITableViewCellStyleDefault 
                                              reuseIdentifier: cellId1] autorelease];
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = @"Manual Refresh Only";
			}
			
			VOARefreshCell* temp = (VOARefreshCell*)cell;
			[temp updateContent];
		}
		
	}
	else if(SEGMENT_TEXT ==  indexPath.section)
	{
        if(0 == indexPath.row)
		{
			cell = [tableView dequeueReusableCellWithIdentifier:cellId3];
			if (cell == nil) 
			{
				cell = [[[VOABigFontCell alloc] initWithStyle: UITableViewCellStyleDefault 
                                              reuseIdentifier: cellId3] autorelease];
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = @"Big Font";
			}
			
			VOABigFontCell* temp = (VOABigFontCell*)cell;
			[temp updateContent];
		}
		else if(1 == indexPath.row)
		{
			cell = [tableView dequeueReusableCellWithIdentifier:cellId4];
			if (cell == nil) 
			{
				cell = [[[VOAAutoScrollCell alloc] initWithStyle: UITableViewCellStyleDefault 
                                                 reuseIdentifier: cellId4] autorelease];
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				cell.textLabel.text = @"Auto Scroll";
			}
			
			VOAAutoScrollCell* temp = (VOAAutoScrollCell*)cell;
			[temp updateContent];
		}
	}
	else if(SEGMENT_CLEANUP == indexPath.section)
	{
        cell = [tableView dequeueReusableCellWithIdentifier:cellId5];
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault 
                                           reuseIdentifier: cellId5] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            cell.textLabel.text = NSLocalizedString(@"Delete old data 3 weeks before",@"");
        }
	}
    else if(SEGMENT_RECOMMENDED == indexPath.section)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:cellId6];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault
                                           reuseIdentifier: cellId6] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
        NSDictionary* item = (NSDictionary*)[self getCellDataAtIndexPath:indexPath];
        if(item)
        {
            cell.textLabel.text = [item objectForKey:@"name"];
            
            NSString* imageUrl = [item objectForKey:@"img_url"];
            if([imageUrl length])
            {
                UIImage* image = [RCTool getImage:imageUrl];
                if(image)
                {
                    image = [RCTool imageWithImage:image scaledToSize:CGSizeMake(40.0, 40.0)];
                    cell.imageView.image = image;
                }
                else
                {
                    [[RCImageLoader sharedInstance] saveImage:imageUrl
                                                     delegate:self
                                                        token:nil];
                }
            }
        }
    }
    
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
    if(SEGMENT_CLEANUP == indexPath.section)
    {
        UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                  delegate:self
                                                         cancelButtonTitle:NSLocalizedString(@"Cancel",@"")
                                                    destructiveButtonTitle:NSLocalizedString(@"Delete",@"")
                                                         otherButtonTitles:nil];
        actionSheet.tag = CLEANUP_TAG;
        [actionSheet showFromTabBar:self.tabBarController.tabBar];
        [actionSheet release];
    }
    else if(SEGMENT_RECOMMENDED == indexPath.section)
    {
        NSDictionary* item = (NSDictionary*)[self getCellDataAtIndexPath:indexPath];
        if(item)
        {
            NSString* urlString = [item objectForKey:@"url"];
            if([urlString length])
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
    }
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(CLEANUP_TAG == actionSheet.tag)
    {
        if(0 == buttonIndex)
        {
            NSLog(@"Delete");
            [RCTool deleteOldData];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_ITEM_NOTIFICATION object:nil];
        }
    }
	
}

#pragma mark -
#pragma mark Action Event

- (void)clickLeftBarButtonItem:(id)sender
{
	NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
	[temp setObject:[NSNumber numberWithBool:NO] 
			 forKey: @"manualRefresh"];
	[temp setObject:[NSNumber numberWithBool:NO]
			 forKey: @"wifiOnly"];
	[temp setObject:[NSNumber numberWithBool:NO] 
			 forKey: @"bigFont"];
	[temp setObject:[NSNumber numberWithBool:YES] 
			 forKey: @"autoScroll"];
	[temp synchronize];
	
	[_tableView reloadData];
    
}

- (void)clickRightBarButtonItem:(id)sender
{
	//[self dismissModalViewControllerAnimated:YES];
}

- (void)succeedLoad:(id)result token:(id)token
{
    [_tableView reloadData];
}


@end
