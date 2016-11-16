//
//  VOACategoriesTableViewCell.h
//  VOA
//
//  Created by xuzepei on 6/16/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RCHomeTableViewCellContentView;

@interface VOACategoriesTableViewCell : UITableViewCell {
	
	RCHomeTableViewCellContentView* _myContentView;

}

@property(nonatomic,retain)RCHomeTableViewCellContentView* _myContentView;

- (void)updateContent:(id)item;


@end
