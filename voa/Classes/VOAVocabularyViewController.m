//
//  VOAVocabularyViewController.m
//  VOA
//
//  Created by xuzepei on 7/14/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOAVocabularyViewController.h"
#import "RCDictionaryViewController.h"
#import "RCTool.h"

@implementation VOAVocabularyViewController
@synthesize _itemArray;
@synthesize _filterItemArray;
@synthesize _tableView;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
	{
		UITabBarItem* item = [[UITabBarItem alloc] initWithTitle:@"Vocabulary" 
														   image:[UIImage imageNamed:@"vocabulary.png"]
															 tag:TT_VOCABULARY];
		self.tabBarItem = item;
		[item release];
		
		self.navigationItem.title = @"VOA English Word Book";
		
		_itemArray = [[NSMutableArray alloc] init];
		_filterItemArray = [[NSMutableArray alloc] init];
		
		
		NSString* path = [[NSBundle mainBundle] pathForResource:@"bin" ofType:@"db"];
		NSArray* array = [[NSArray alloc] initWithContentsOfFile:path];
		[_itemArray addObjectsFromArray: array];
		[array release];
		[_tableView reloadData];
		
    }
    return self;
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
	
	[_itemArray release];
	[_filterItemArray release];
	[_tableView release];
    
    self.searchBar = nil;
	
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear: animated];
    
    [self rearrange];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	[self rearrange];
}

- (void)rearrange
{
}

#pragma mark -
#pragma mark UITableView data source and delegate methods

- (id)getCellDataAtIndexPath: (NSIndexPath*)indexPath
{
	if(indexPath.row >= [_itemArray count])
		return nil;
	
	return [_itemArray objectAtIndex: indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 40.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	/*
	 If the requesting table view is the search display controller's table view, return the count of
     the filtered list, otherwise return the count of the main list.
	 */
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
        return [_filterItemArray count];
    }
	else
	{
        return [_itemArray count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *kCellID = @"cellID";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellID];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellID] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	/*
	 If the requesting table view is the search display controller's table view, configure the cell using the filtered content, otherwise use the main list.
	 */
	NSDictionary *word = nil;
	if (tableView == self.searchDisplayController.searchResultsTableView)
	{
		if(indexPath.row < [_filterItemArray count])
			word = [_filterItemArray objectAtIndex:indexPath.row];
    }
	else
	{
		if(indexPath.row < [_itemArray count])
			word = [_itemArray objectAtIndex:indexPath.row];
    }
	
	if(word)
		cell.textLabel.text = [word objectForKey:@"word"];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath: indexPath animated: YES];
	
	NSDictionary* word = (NSDictionary*)[self getCellDataAtIndexPath: indexPath];
	if(word)
	{
		RCDictionaryViewController* temp = [[[RCDictionaryViewController alloc] 
											initWithNibName:nil 
													 bundle:nil] autorelease];
		[temp updateContent: word]; 
		[self.navigationController pushViewController:temp animated:YES];
	}
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	[_filterItemArray removeAllObjects]; // First clear the filtered array.
	
	for (NSDictionary *word in _itemArray)
	{
		NSString* wordString = [word objectForKey:@"word"];
		if ([wordString length])
		{
			NSRange range = [wordString rangeOfString:searchText
											  options:NSCaseInsensitiveSearch];

			if(range.location != NSNotFound)
			{
				[_filterItemArray addObject: word];
            }
		}
	}
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString scope:nil];
	 
	 [[self.searchDisplayController.searchBar scopeButtonTitles] 
	  objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]];
    
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[self.searchDisplayController.searchBar text] scope:
	 [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


@end
