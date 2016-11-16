//
//  VOAImageDisplayView.m
//  VOA
//
//  Created by xuzepei on 6/3/11.
//  Copyright 2011 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOAImageDisplayView.h"
#import "RCTool.h"
#import "VOAAppDelegate.h"
#import "WRSysTabBarController.h"

#define ZOOM_VIEW_TAG 100
#define ZOOM_STEP 1.0

#define THUMB_HEIGHT 150
#define THUMB_V_PADDING 10
#define THUMB_H_PADDING 10
#define CREDIT_LABEL_HEIGHT 20

#define AUTOSCROLL_THRESHOLD 30

#define OFFSET_HEIGHT 100.0

@interface VOAImageDisplayView(Private)

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;

@end

@implementation VOAImageDisplayView
@synthesize _scrollView;
@synthesize _saveButton;
@synthesize _closeButton;
@synthesize _imagePath;
@synthesize _delegate;
@synthesize _imageView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		
		self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }
    return self;
}


- (CGSize)getDisplayImageSize:(CGSize)imageSize
{
	CGFloat width = 0;
	CGFloat height = 0;
	
    if(imageSize.width <= imageSize.height)//竖直的
    {
        if(imageSize.height >= self.bounds.size.height - OFFSET_HEIGHT)
        {
            height = self.bounds.size.height - OFFSET_HEIGHT;
            width = (imageSize.width * height)/imageSize.height;
        }
        else
        {
            
            height = imageSize.height;
            width = imageSize.width;
        }
        
        while (width > [RCTool getScreenSize].width - 20.0)
        {
            width -= 1.0;
            height = (imageSize.height * width) / imageSize.width;
        }
        
    }
    else//横着的
    {
        if(imageSize.width >= [RCTool getScreenSize].width - 20.0)
        {
            width = [RCTool getScreenSize].width - 20.0;
            height = (imageSize.height * [RCTool getScreenSize].width - 20.0) / imageSize.width;
        }
        else
        {
            height = imageSize.height;
            width = imageSize.width;
        }
        
        
        while(height > self.bounds.size.height - OFFSET_HEIGHT)
        {
            height -= 1.0;
            width = (imageSize.width * height) / imageSize.height;
        }
        
    }
	
	return CGSizeMake(width, height);
}

 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
     
     UIImage *image = [RCTool getImage:_imagePath];
     if(image)
     {
         CGSize size = [self getDisplayImageSize:image.size];
         [image drawInRect:CGRectMake((self.bounds.size.width - size.width)/2.0, (self.bounds.size.height - size.height)/2.0, size.width, size.height)];
     }
         
 }


- (void)dealloc {
	
	[_scrollView release];
	[_imagePath release];
	[_saveButton release];
    self._imageView = nil;
    
    self._delegate = nil;
	
    [super dealloc];
}



- (void)updateContent:(NSString*)path delegate:(id)delegate
{
	self._delegate = delegate;
	self._imagePath = path;
		
    UIImage *image = [RCTool getImage:path];
	if(nil == image)
	{
        if(_delegate && [_delegate respondsToSelector:@selector(closeImage)])
        {
            [_delegate closeImage];
        }
        
        return;
	}

    if(nil == _saveButton)
    {
        self._saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        [_saveButton addTarget:self
                        action:@selector(clickSaveButton:)
              forControlEvents:UIControlEventTouchUpInside];
        [_saveButton setImage:[UIImage imageNamed:@"download.png"]
                     forState:UIControlStateNormal];
        [self addSubview: _saveButton];
    }
    
    _saveButton.frame = CGRectMake(self.bounds.size.width - 60, self.bounds.size.height - 60, 40, 40);
	
    if(nil == _closeButton)
    {
        self._closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"x.png"]
                      forState:UIControlStateNormal];
        [_closeButton addTarget:self
                         action:@selector(clickCloseButton:)
               forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview: _closeButton];
    }
    
    _closeButton.frame = CGRectMake(self.bounds.size.width - 50.0, 10, 40, 40);
    
}

- (void) image: (UIImage *) image
didFinishSavingWithError: (NSError *) error
   contextInfo: (void *) contextInfo
{
	if(0 == [error code])
	{
        [RCTool showAlert:NSLocalizedString(@"Hint",@"") message:NSLocalizedString(@"Succeed in saving this image to Photos Library.", @"")];
	}
}

- (void)clickSaveButton:(id)sender
{
	if([_imagePath length])
	{
		UIImage *image = [RCTool getImage:_imagePath];
		if(nil == image)
			return;
		
		_saveButton.enabled = NO;
		
		UIImageWriteToSavedPhotosAlbum(image,
									   self,
									   @selector(image:didFinishSavingWithError:contextInfo:),
									   nil);
	}
}

- (void)clickCloseButton:(id)sender
{
	if(_delegate && [_delegate respondsToSelector:@selector(closeImage)])
	{
		[_delegate closeImage];
	}
}

- (void)rearrange
{
    if(_saveButton)
    {
        _saveButton.frame = CGRectMake(self.bounds.size.width - 60, self.bounds.size.height - 60, 40, 40);
    }
    
    if(_closeButton)
    {
        _closeButton.frame = CGRectMake(self.bounds.size.width - 50.0, 10, 40, 40);
    }
    
    [self setNeedsDisplay];
}


@end
