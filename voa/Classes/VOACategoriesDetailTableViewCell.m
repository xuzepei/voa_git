//
//  VOACategoriesDetailTableViewCell.m
//  VOA
//
//  Created by xuzepei on 6/17/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOACategoriesDetailTableViewCell.h"
#import "RCHomeCellBackgroundView.h"
#import "VOACategoriesDetailTableViewCellContentView.h"
#import "RCTool.h"


@implementation VOACategoriesDetailTableViewCell
@synthesize _myContentView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        
//		//设置cell的背景图片
//		RCHomeCellBackgroundView* temp = [[[RCHomeCellBackgroundView alloc] 
//										   initWithFrame:self.frame] autorelease];
//		self.backgroundView = temp;
		
		
		_myContentView = [[VOACategoriesDetailTableViewCellContentView alloc] 
						  initWithFrame:CGRectZero];
		
		[self.contentView addSubview: _myContentView];
		
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	[super setHighlighted: highlighted animated: animated];
	
	if(_myContentView._highlighted != highlighted)
	{
		_myContentView._highlighted = highlighted;
		[_myContentView setNeedsDisplay];
	}
	
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
	
	if(_myContentView._highlighted != selected)
	{
		_myContentView._highlighted = selected;
		[_myContentView setNeedsDisplay];
	}
}


- (void)dealloc {
	
	[_myContentView release];	
    [super dealloc];
}

- (void)updateContent:(id)item
{
	if(nil == item)
		return;
    
	if(nil == item)
		return;
    
    UIInterfaceOrientation statusBarOrientation =[UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationLandscapeLeft ==statusBarOrientation || UIInterfaceOrientationLandscapeRight ==statusBarOrientation)
    {
        _myContentView.frame = CGRectMake(0,0,[RCTool getScreenSize].height,70);
    }
    else
    {
        _myContentView.frame = CGRectMake(0,0,[RCTool getScreenSize].width,70);
    }
	
	[_myContentView updateContent: item];
}

- (void)rearrange: (BOOL)editing
{

}


@end
