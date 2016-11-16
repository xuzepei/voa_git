//
//  VOACategoriesTableViewCell.m
//  VOA
//
//  Created by xuzepei on 6/16/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOACategoriesTableViewCell.h"
#import "RCHomeCellBackgroundView.h"
#import "RCHomeTableViewCellContentView.h"
#import "VOACategory.h"
#import "RCTool.h"


@implementation VOACategoriesTableViewCell
@synthesize _myContentView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
//		//设置cell的背景图片
//		RCHomeCellBackgroundView* temp = [[[RCHomeCellBackgroundView alloc] 
//										   initWithFrame:self.frame] autorelease];
//		self.backgroundView = temp;

		_myContentView = [[RCHomeTableViewCellContentView alloc] 
							initWithFrame:CGRectZero];
		
		[self.contentView addSubview: _myContentView];

    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted: highlighted animated: animated];
	_myContentView._highlighted = highlighted;
	[_myContentView setNeedsDisplay];
	
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	_myContentView._highlighted = selected;
	[_myContentView setNeedsDisplay];
}


- (void)dealloc {
	
	[_myContentView release];	
    [super dealloc];
}

- (void)updateContent:(id)item
{
	if(nil == item)
		return;
    
    UIInterfaceOrientation statusBarOrientation =[UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationLandscapeLeft ==statusBarOrientation || UIInterfaceOrientationLandscapeRight ==statusBarOrientation)
    {
        _myContentView.frame = CGRectMake(0,0,[RCTool getScreenSize].height,60);
    }
    else
    {
        _myContentView.frame = CGRectMake(0,0,[RCTool getScreenSize].width,60);
    }

    //NSLog(@"cell:%@",NSStringFromCGRect(self.frame));
	
	[_myContentView updateContent: item];
}



@end
