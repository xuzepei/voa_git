//
//  VOADownloadImageView.h
//  VOA
//
//  Created by xuzepei on 7/2/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VOADownloadImageView : UIView {
	
	CGImageRef _imageRef;
	CGFloat _radius;
	int _type;
	BOOL _needDrawLine;
}

@property(assign) int _type;
@property(assign) BOOL _needDrawLine;

- (id)initWithFrame:(CGRect)frame image:(UIImage*)image 
			  round:(CGFloat)round needDrawLine:(BOOL)needDrawLine;
- (void)setImage:(UIImage*)image;

@end
