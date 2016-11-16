//
//  VOACategoriesDetailTableViewCell.h
//  VOA
//
//  Created by xuzepei on 6/17/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VOACategoriesDetailTableViewCellContentView;
@interface VOACategoriesDetailTableViewCell : UITableViewCell {
	
	VOACategoriesDetailTableViewCellContentView* _myContentView;
	
}

@property(nonatomic,retain)VOACategoriesDetailTableViewCellContentView* _myContentView;

- (void)updateContent:(id)item;
- (void)rearrange: (BOOL)editing;


@end
