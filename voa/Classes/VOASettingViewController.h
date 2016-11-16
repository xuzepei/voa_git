//
//  VOASettingViewController.h
//  VOA
//
//  Created by xuzepei on 5/31/11.
//  Copyright 2011 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VOASettingViewController : UIViewController 
<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>
{
	UITableView* _tableView;
}

@property(nonatomic,retain)UITableView* _tableView;
@property(nonatomic,retain)NSMutableArray* itemArray;

- (void)initTableView;

@end
