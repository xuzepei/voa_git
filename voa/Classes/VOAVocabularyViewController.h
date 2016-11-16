//
//  VOAVocabularyViewController.h
//  VOA
//
//  Created by xuzepei on 7/14/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VOAVocabularyViewController : UIViewController
<UITableViewDelegate,UITableViewDataSource,
UISearchDisplayDelegate, UISearchBarDelegate> 
{
	NSMutableArray* _itemArray;
	NSMutableArray* _filterItemArray;
	IBOutlet UITableView* _tableView;
}

@property(nonatomic,retain)NSMutableArray* _itemArray;
@property(nonatomic,retain)NSMutableArray* _filterItemArray;
@property(nonatomic,retain)IBOutlet UITableView* _tableView;
@property(nonatomic,retain)IBOutlet UISearchBar* searchBar;

@end
