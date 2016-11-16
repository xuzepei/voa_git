//
//  RCHomeTableViewCellContentView.m
//  rsscoffee
//
//  Created by beer on 7/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RCHomeTableViewCellContentView.h"
#import "VOACategory.h"
#import "Item.h"

#define BUBBLE_MINWIDTH 21.0
#define BUBBLE_MINHEIGHT 22.0
#define NUMBER_FONTSIZE 14.0


@implementation RCHomeTableViewCellContentView
@synthesize _highlighted;
@synthesize _category;
@synthesize _number;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

		self.backgroundColor = [UIColor clearColor];
		_number = 0;
    }
    return self;
}

- (void)updateContent:(VOACategory*)category
{
	if(category)
	{
		self._category = category;
		[self setNeedsDisplay];
	}
}

- (void)drawRect:(CGRect)rect {
    [super drawRect: rect];
	
	
	//draw image
	if([_category.order length])
	{
		UIImage* image = [UIImage imageNamed:
						  [NSString stringWithFormat:@"%@.png",_category.order]];
		if(image)
			[image drawInRect:CGRectMake(0, 0, 60, 60)];
	}
	
	//draw title
	NSString* title = _category.title;	
	CGSize textSize = [title sizeWithFont:[UIFont boldSystemFontOfSize: 17]
					   constrainedToSize:CGSizeMake(rect.size.width/2.0 + 20.0, 25)
						   lineBreakMode:UILineBreakModeTailTruncation];
	
	if(_highlighted)
		[[UIColor whiteColor] set];
	else
		[[UIColor blackColor] set];

	[title drawInRect:CGRectMake(70 , 19, textSize.width, textSize.height) 
			withFont:[UIFont boldSystemFontOfSize: 17]
	   lineBreakMode:UILineBreakModeTailTruncation];
	
	int i = 0;
	NSSet* items = _category.items;
	if(items)
	{
		NSArray* itemArray = [items allObjects];
		i = [itemArray count];
		for(Item* item in itemArray)
		{
			NSNumber* isRead = item.isRead;
            NSNumber* isHidden = item.isHidden;
			if([isRead boolValue] || [isHidden boolValue])
				i--;
		}
	}
	
	_number = i;
    if(_number <= 0)
        return;
    
    NSString* numberString = @"";
    if(_number >= 1000)
        numberString = @"1000+";
    else 
        numberString = [NSString stringWithFormat:@"%d",_number];
    
    CGSize numberSize = [numberString sizeWithFont:[UIFont boldSystemFontOfSize: NUMBER_FONTSIZE]
								 constrainedToSize:CGSizeMake(100, 20) 
									 lineBreakMode:UILineBreakModeWordWrap];
    
    numberSize = CGSizeMake(MAX(numberSize.width,BUBBLE_MINWIDTH),
                            MAX(numberSize.height,BUBBLE_MINHEIGHT));
    
    [self drawNumberBubble:numberString rect:CGRectMake(rect.size.width - 31 - (numberSize.width + 10),
														20, numberSize.width + 13, 19.9)];
	
	

}

- (void)drawBubble: (CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 0.0);
	
	if(_highlighted)
		CGContextSetRGBFillColor(context, 1.0, 1.0, 1.0, 1.0);
	else
		CGContextSetRGBFillColor(context, 0.55, 0.61, 0.69, 1.0);
	
	CGRect rrect = rect;
	CGFloat radius = 10.0;
	
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathFillStroke);
	CGContextRestoreGState(context);
}

- (void)drawNumberBubble:(NSString*)numberString rect:(CGRect)rect 
{
	//draw bubble
	[self drawBubble: rect];
	
	//draw number
	if(_highlighted)
		[BLUE_TEXT_COLOR set];
	else
		[[UIColor whiteColor] set];
	
	[numberString drawInRect:CGRectMake(rect.origin.x + 5, 21, rect.size.width - 10, 18)
					withFont:[UIFont boldSystemFontOfSize: NUMBER_FONTSIZE]
			   lineBreakMode:UILineBreakModeTailTruncation
				   alignment:UITextAlignmentCenter];
}


- (void)dealloc {
	
	[_category release];
    [super dealloc];
}



@end
