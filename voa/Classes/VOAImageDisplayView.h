//
//  VOAImageDisplayView.h
//  VOA
//
//  Created by xuzepei on 6/3/11.
//  Copyright 2011 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TapDetectingImageView.h"
#import "VOATextViewController.h"

@interface VOAImageDisplayView : UIView<UIScrollViewDelegate,TapDetectingImageViewDelegate> {
	
	UIScrollView* _scrollView;
	UIButton* _saveButton;
	UIButton* _closeButton;
	NSString* _imagePath;
    UIImageView* _imageView;
	
	VOATextViewController* _delegate;

}

@property(nonatomic,retain)UIScrollView* _scrollView;
@property(nonatomic,retain)UIButton* _saveButton;
@property(nonatomic,retain)UIButton* _closeButton;
@property(nonatomic,retain)NSString* _imagePath;
@property(nonatomic,retain)UIImageView* _imageView;
@property(nonatomic,assign)VOATextViewController* _delegate;

- (void)updateContent:(NSString*)path delegate:(id)delegate;
- (void)rearrange;

@end
