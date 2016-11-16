//
//  VOADownloadTableViewCell.h
//  VOA
//
//  Created by xuzepei on 7/1/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VOADownloadImageView;
@class Item;
@interface VOADownloadTableViewCell : UITableViewCell {
	
	VOADownloadImageView* _myImageView;
	Item* _item;
	NSString* _imageUrl;
	
	UILabel* _titleLabel;
	UILabel* _infoLabel;
	UIProgressView* _progressView;
	UIButton* _rightImageButton;
	NSUInteger _rightImageType;
}

@property (nonatomic, retain) VOADownloadImageView* _myImageView;
@property (nonatomic, retain) Item* _item;
@property (nonatomic, retain) NSString* _imageUrl;
@property (nonatomic, retain) UIButton* _rightImageButton;
@property (assign)NSUInteger _rightImageType;

- (void)updateContent:(Item*)item 
			indexPath:(NSIndexPath *)indexPath 
				count:(NSUInteger)count;

- (void)rearrange: (BOOL)editing;
- (UIImage*)getImageByType: (NSUInteger)type;
- (void)updatePercentage: (float)percentage;
- (void)updateStatusForFailed;
- (void)updateStatusForCancel;


@end
