//
//  RCHomeCellBackgroundView.m
//  rsscoffee
//
//  Created by xuzepei on 12/1/09.
//  Copyright 2009 Rumtel Co.,Ltd. All rights reserved.
//

#import "RCHomeCellBackgroundView.h"


@implementation RCHomeCellBackgroundView
@synthesize _image;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self._image = [UIImage imageNamed:@"itembk.png"];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    
	[_image drawInRect: rect];
}


- (void)dealloc {
	
	[_image release];
    [super dealloc];
}


@end
