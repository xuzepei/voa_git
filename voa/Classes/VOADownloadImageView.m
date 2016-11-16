//
//  VOADownloadImageView.m
//  VOA
//
//  Created by xuzepei on 7/2/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOADownloadImageView.h"


@implementation VOADownloadImageView
@synthesize _type;
@synthesize _needDrawLine;

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image 
			  round:(CGFloat)round needDrawLine:(BOOL)needDrawLine
{
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		[self setImage:image];
		_radius = round;
		_type = 0;
		_needDrawLine = needDrawLine;
	}
	return self;
}

- (void)dealloc 
{
	CGImageRelease(_imageRef);
	[super dealloc];
}


- (void)drawRect:(CGRect)rect 
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, rect.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
	
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, (_type & 8) ? _radius : 0);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, (_type & 4) ? _radius : 0);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, (_type & 2) ? _radius : 0);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, (_type & 1) ? _radius : 0);
	CGContextClosePath(context);
	CGContextClip (context);
	
	// draw image with rounded-rect clip
	CGContextDrawImage (context, rect, _imageRef);
	
	//draw line 
	if(_needDrawLine)
	{
		CGContextSetRGBStrokeColor(context, 0.66, 0.67, 0.68, 1.0);
		CGContextSetLineWidth(context, 1.0);
		CGContextMoveToPoint(context, maxx, 0);
		CGContextAddLineToPoint(context, maxx, maxy);
		CGContextStrokePath(context);
	}
	
}

- (void)setImage:(UIImage*)image {
	if (_imageRef) {
		CGImageRelease(_imageRef);
	}
	_imageRef = CGImageRetain([image CGImage]);
	[self setNeedsDisplay];
}

@end
