//
//  VOACategoriesDetailTableViewCellContentView.h
//  VOA
//
//  Created by xuzepei on 6/17/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;
@interface VOACategoriesDetailTableViewCellContentView : UIView {
	
	BOOL _highlighted;
	Item* _item;
	UIImage* _image;
	NSString* _imageUrl;

}

@property (assign) BOOL _highlighted;
@property (nonatomic, retain) Item* _item;
@property (nonatomic,retain)UIImage* _image;
@property (nonatomic,retain)NSString* _imageUrl;

- (void)updateContent:(id)item;

@end
