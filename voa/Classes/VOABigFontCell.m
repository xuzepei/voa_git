//
//  VOABigFontCell.m
//  VOA
//
//  Created by xuzepei on 6/1/11.
//  Copyright 2011 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOABigFontCell.h"
#import "RCTool.h"

@implementation VOABigFontCell
@synthesize _switch;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		
		_switch = [[UISwitch alloc] initWithFrame:CGRectMake(206,10,80,40)];
		[_switch addTarget:self 
					action:@selector(switchValueDidChange:) 
		  forControlEvents:UIControlEventValueChanged];
		
        self.accessoryView = _switch;
		
		
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	
    [super setSelected:selected animated:animated];
	
    // Configure the view for the selected state
}


- (void)dealloc {
	
	[_switch release];
    [super dealloc];
}

- (void)switchValueDidChange:(id)sender
{
	NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
	[temp setObject:[NSNumber numberWithBool:_switch.on] 
			 forKey: @"bigFont"];
	[temp synchronize];
}

- (void)updateContent
{
	NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
	NSNumber* b = [temp objectForKey:@"bigFont"];
	
	if(nil == b)
		_switch.on = NO;
	else
		_switch.on = [b boolValue];
}


@end
