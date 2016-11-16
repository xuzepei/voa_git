//
//  RCHomeTableViewCellContentView.h
//  rsscoffee
//
//  Created by beer on 7/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VOACategory;
@interface RCHomeTableViewCellContentView : UIView {

	BOOL _highlighted;
	VOACategory* _category;
	NSInteger _number;
}

@property (assign) BOOL _highlighted;
@property (nonatomic, retain) VOACategory* _category;
@property (assign) NSInteger _number;

- (void)updateContent:(VOACategory*)category;
- (void)drawNumberBubble:(NSString*)numberString 
					rect:(CGRect)rect;
@end
