//
//  VOACategoriesDetailTableViewCellContentView.m
//  VOA
//
//  Created by xuzepei on 6/17/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOACategoriesDetailTableViewCellContentView.h"
#import "Item.h"
#import "RCTool.h"
#import "RCImageLoader.h"

@implementation VOACategoriesDetailTableViewCellContentView
@synthesize _highlighted;
@synthesize _item;
@synthesize _image;
@synthesize _imageUrl;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
		
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)updateContent:(id)item
{
	if(item)
	{
		self._item = (Item*)item;
        self._image = nil;
		
		NSString* imageUrl = _item.imageUrl;
		if([imageUrl length])
		{
            self._image = [UIImage imageNamed:@"default_logo"];
			self._imageUrl = imageUrl;
			UIImage* image = [RCTool getSmallImage:imageUrl];
			if(image)
				self._image = image;
			else
			{
				//self._image = nil;
				[[RCImageLoader sharedInstance] saveImage:imageUrl 
												 delegate:self 
													token:nil];
			}
		}
		
		[self setNeedsDisplay];
	}
}

- (void)drawRect:(CGRect)rect {
    [super drawRect: rect];
	
    CGFloat offset_x = 0.0;
	BOOL hasImage = NO;
	if(_image)
	{
		hasImage = YES;
		CGRect imageRect;
		imageRect.size.width = 80;
		imageRect.size.height = 60;
		imageRect.origin.x = 6;
		imageRect.origin.y = 6;
		
		[_image drawInRect: imageRect];
		
        offset_x = 90;
		if(NO == [_item.isRead boolValue])
		{
			UIImage* unreadImage = [UIImage imageNamed:@"unread"];
			[unreadImage drawInRect:CGRectMake(offset_x, 55, 8, 8)];
		}
	}
	else
	{
        offset_x = 8;
		if(NO == [_item.isRead boolValue])
		{
			UIImage* unreadImage = [UIImage imageNamed:@"unread"];
			[unreadImage drawInRect:CGRectMake(offset_x, 55, 8, 8)];
		}
	}
	
	if([_item.isFavorited boolValue])
	{
		UIImage* image = [UIImage imageNamed:@"favorited2"];
		[image drawInRect:CGRectMake(offset_x, 55, 8,8)];
	}
	
	//draw title
	NSString* title = _item.title;
	
	CGFloat height = 2.0;
    CGFloat offset_y = 8.0;
	CGFloat max_with = self.bounds.size.width - 40.0;
	
	if(hasImage)
	{
        offset_y = 6.0;
		max_with = self.bounds.size.width - (offset_x + 10);
	}
	
	if([title length])
	{
		if(_highlighted)
			[[UIColor whiteColor] set];
		else
			[[UIColor blackColor] set];
		
		CGSize textSize = [title sizeWithFont:[UIFont boldSystemFontOfSize: 16]
							constrainedToSize:CGSizeMake(max_with, 40)
								lineBreakMode:NSLineBreakByTruncatingTail];
		
		[title drawInRect:CGRectMake(offset_x , offset_y, textSize.width, 40)
				 withFont:[UIFont boldSystemFontOfSize: 16]
			lineBreakMode:NSLineBreakByTruncatingTail
         alignment:NSTextAlignmentLeft];
		
		height = 2 + textSize.height;
	}
	
//	NSString* description = _item.itsdescription;
//	if([description length])
//	{
//		
//		if(_highlighted)
//			[[UIColor whiteColor] set];
//		else
//			[[UIColor colorWithRed:0.51 green:0.51 blue:0.51 alpha:1.00] set];
//		
//		CGSize textSize = [description sizeWithFont:[UIFont boldSystemFontOfSize: 13]
//						   constrainedToSize:CGSizeMake(max_with, 16) 
//							   lineBreakMode:UILineBreakModeTailTruncation];
//		
//		[description drawInRect:CGRectMake(offset_x, height,
//										   textSize.width, textSize.height) 
//				 withFont:[UIFont systemFontOfSize: 13]
//			lineBreakMode:UILineBreakModeTailTruncation];
//	}
	
	NSString* dateString = _item.pubDate;
	
	//日期
	NSDate* date = nil;
	if([dateString length])
		date = [RCTool getDateByString:dateString];

	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.dateStyle = NSDateFormatterShortStyle;
	dateFormatter.dateFormat = @"dd MMM YYYY";
	dateString = [dateFormatter stringFromDate:date];
	[dateFormatter release];
	
	if([dateString length])
	{
		if(_highlighted)
			[[UIColor whiteColor] set];
		else
			[[UIColor grayColor] set];
		
		CGSize textSize = [dateString sizeWithFont:[UIFont systemFontOfSize: 12]];
		[dateString drawInRect:CGRectMake(self.bounds.size.width - 16 - textSize.width,52,textSize.width,12)
				withFont:[UIFont systemFontOfSize: 12]
		   lineBreakMode:UILineBreakModeTailTruncation
			   alignment:UITextAlignmentLeft];
	}	
}


- (void)dealloc {
	
	[_item release];
	[_image release];
	[_imageUrl release];
	
    [super dealloc];
}

- (void)succeedLoad:(id)result token:(id)token
{
	NSDictionary* dict = (NSDictionary*)result;
	NSString* urlString = [dict valueForKey: @"url"];
	if([urlString isEqualToString: _imageUrl])
	{
		self._image = [RCTool getSmallImage:_imageUrl];
		[self setNeedsDisplay];
	}
}



@end
