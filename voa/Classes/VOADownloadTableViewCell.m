//
//  VOADownloadTableViewCell.m
//  VOA
//
//  Created by xuzepei on 7/1/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOADownloadTableViewCell.h"
#import "VOADownloadImageView.h"
#import "Item.h"
#import "RCTool.h"
#import "RCImageLoader.h"


@implementation VOADownloadTableViewCell
@synthesize _myImageView;
@synthesize _item;
@synthesize _imageUrl;
@synthesize _rightImageButton;
@synthesize _rightImageType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
       
		_myImageView = [[VOADownloadImageView alloc] initWithFrame: CGRectMake(8,5,50,50)
																		 image: [UIImage imageNamed:@"item.png"]
																		 round: 0.0
																  needDrawLine: YES];
		[self.contentView addSubview: _myImageView];
		
		_rightImageType = IT_DOWNLOAD;
		self._rightImageButton = [UIButton buttonWithType: UIButtonTypeCustom];
		_rightImageButton.frame = CGRectMake(0, 0, 40, 40);
        _rightImageButton.backgroundColor = [UIColor clearColor];
		[_rightImageButton setImage: [self getImageByType: _rightImageType] 
						   forState: UIControlStateNormal];
		[_rightImageButton addTarget: self 
							  action:@selector(clickRightImageButton:) 
					forControlEvents:UIControlEventTouchUpInside];
		self.accessoryView = _rightImageButton;
		
		
		_titleLabel = [[UILabel alloc] initWithFrame: CGRectMake(66, 2, 190, 20)];
		_titleLabel.font = [UIFont systemFontOfSize: 12];
		_titleLabel.text = @"";
        _titleLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview: _titleLabel];
		
		_progressView = [[UIProgressView alloc] initWithProgressViewStyle: 
						 UIProgressViewStyleDefault];
		CGRect rect  = _progressView.frame;
		rect.origin.x = 66;
		rect.origin.y = 25;
		rect.size.width = 185;
		_progressView.frame = rect;
         _progressView.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview: _progressView];
		
		_infoLabel = [[UILabel alloc] initWithFrame: CGRectMake(66, 35, 200, 20)];
		_infoLabel.textColor = [UIColor grayColor];
		_infoLabel.font = [UIFont systemFontOfSize: 12];
		_infoLabel.text = @"";
        _infoLabel.backgroundColor = [UIColor clearColor];
		[self.contentView addSubview: _infoLabel];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc 
{
	[_myImageView release];
	[_item release];
	[_imageUrl release];
	[_rightImageButton release];
	
	[_titleLabel release];
	[_infoLabel release];
	[_progressView release];
	
    [super dealloc];
}

- (IBAction)clickRightImageButton:(id)sender
{
	NSLog(@"clickRightImageButton");
	
	[[NSNotificationCenter defaultCenter] postNotificationName: @"clickRightImageButton" 
														object: self
													  userInfo: nil];
}

- (void)updateRightButtonImage:(NSUInteger)type
{
	_rightImageType = type;
	[_rightImageButton setImage: [self getImageByType: _rightImageType] 
					   forState: UIControlStateNormal];
}

- (void)updateContent:(Item*)item 
			indexPath:(NSIndexPath *)indexPath 
				count:(NSUInteger)count
{
	self._item = item;
	_titleLabel.text = _item.title;
    
    UIInterfaceOrientation statusBarOrientation =[UIApplication sharedApplication].statusBarOrientation;
    
    if(UIInterfaceOrientationLandscapeLeft ==statusBarOrientation || UIInterfaceOrientationLandscapeRight ==statusBarOrientation)
    {
        _titleLabel.frame = CGRectMake(66, 2, [RCTool getScreenSize].height - 130, 20);
        _progressView.frame = CGRectMake(66,25,[RCTool getScreenSize].height - 130,20);
        _infoLabel.frame = CGRectMake(66, 35, [RCTool getScreenSize].height - 130, 20);
    }
    else
    {
        _titleLabel.frame = CGRectMake(66, 2, 190, 20);
        _progressView.frame = CGRectMake(66,25,185,20);
        _infoLabel.frame = CGRectMake(66, 35, 200, 20);
    }
	
	if((0 == indexPath.row) && (1 == count))
		self._myImageView._type = ARCTYPE_LEFTTOP | ARCTYPE_LEFTBOTTOM;
	else if(0 == indexPath.row)
		self._myImageView._type = ARCTYPE_LEFTTOP;
	else if(count - 1 == indexPath.row)
		self._myImageView._type = ARCTYPE_LEFTBOTTOM;
	else
		self._myImageView._type = ARCTYPE_NORMAL;
	
	NSString* imageUrl = _item.imageUrl;
	if([imageUrl length])
	{
		if([self._imageUrl isEqualToString:imageUrl])
			return;
		
		self._imageUrl = imageUrl;
		UIImage* image = [RCTool getSmallImage:imageUrl];
		if(image)
			[_myImageView setImage:image];
		else
		{
			[_myImageView setImage:[UIImage imageNamed:@"item.png"]];
			[[RCImageLoader sharedInstance] saveImage:imageUrl 
											 delegate:self 
												token:nil];
		}
	}
	else
		[_myImageView setImage: [UIImage imageNamed:@"item.png"]];
	
	
//	NSRange range = [_item.address rangeOfString:@"http"];
//	if(range.location != NSNotFound)
//		_item.address = [_item.address substringFromIndex:range.location];
//	

	if([RCTool isExistingFile:[RCTool getFilePathByUrl:_item.address]])
	{
		[self updatePercentage:1.0];
	}
	
}

- (void)rearrange: (BOOL)editing
{
    
    UIInterfaceOrientation statusBarOrientation =[UIApplication sharedApplication].statusBarOrientation;
    
    CGFloat offset_width = 0.0;
    if(YES == editing)
    {
        [UIView beginAnimations:@"rearrange" context:UIGraphicsGetCurrentContext()];
        [UIView setAnimationDuration: 0.3];
        
        offset_width = 60.0;
    }
    
    if(UIInterfaceOrientationLandscapeLeft ==statusBarOrientation || UIInterfaceOrientationLandscapeRight ==statusBarOrientation)
    {
        _titleLabel.frame = CGRectMake(66, 4, [RCTool getScreenSize].height - 136, 20);
        _progressView.frame = CGRectMake(66,27,[RCTool getScreenSize].height - 136,20);
        _infoLabel.frame = CGRectMake(66, 35, [RCTool getScreenSize].height - 136, 20);
    }
    else
    {
        CGFloat x = 192.0f;
        if([RCTool systemVersion] < 7.0)
            x = 185.0f;
        
        _titleLabel.frame = CGRectMake(66, 4, x -offset_width, 20);
        _progressView.frame = CGRectMake(66,27,x -offset_width,20);
        _infoLabel.frame = CGRectMake(66, 35, 200 - offset_width, 20);
    }
	
    if(editing)
        [UIView commitAnimations];
}

- (UIImage*)getImageByType: (NSUInteger)type
{
    NSString* pauseImageName = @"pause_rightbutton";
    if([RCTool systemVersion] < 7.0)
        pauseImageName = @"pause_rightbutton_6.png";
    
    NSString* download_rightbutton = @"download_rightbutton";
    if([RCTool systemVersion] < 7.0)
        download_rightbutton = @"download_rightbutton_6.png";
    
    NSString* disclosure_rightbutton = @"disclosure_rightbutton";
    if([RCTool systemVersion] < 7.0)
        disclosure_rightbutton = @"disclosure_rightbutton_6.png";
    
    
	UIImage* image = nil;
	switch (type) 
	{
		case IT_PAUSE:
			image = [UIImage imageNamed: pauseImageName];
			break;
		case IT_DOWNLOAD:
			image = [UIImage imageNamed: download_rightbutton];
			break;
		case IT_DISCLOSURE:
			image = [UIImage imageNamed: disclosure_rightbutton];
			break;
		default:
			break;
	}
	
	return image;
}

- (void)updatePercentage: (float)percentage
{
	_progressView.progress = percentage;
	
	if(percentage != 1.0)
	{
		_infoLabel.text = [NSString stringWithFormat:@"%@  %5.1f%%",
						   NSLocalizedString(@"downloading...", @""),
						   percentage*100];
		[self updateRightButtonImage: IT_PAUSE];
	}
	else if(percentage == 1.0)
	{
		_infoLabel.text = NSLocalizedString(@"finished",@"");
		[self updateRightButtonImage: IT_DISCLOSURE];
	}
}

- (void)updateStatusForFailed
{
	[self updateRightButtonImage: IT_DOWNLOAD];
	_infoLabel.text = NSLocalizedString(@"failed", @"");
}

- (void)updateStatusForCancel
{
	[self updateRightButtonImage: IT_DOWNLOAD];
	_infoLabel.text = NSLocalizedString(@"canceled", @"");
}


@end
