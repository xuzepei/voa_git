//
//  VOATextViewController.h
//  VOA
//
//  Created by xuzepei on 6/17/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h> 
#import <MediaPlayer/MediaPlayer.h>

@class Item;
@class AudioStreamer;
@class AVAudioPlayer;
@class VOAImageDisplayView;
@interface VOATextViewController : UIViewController
<UIWebViewDelegate,UIActionSheetDelegate,AVAudioPlayerDelegate,UIGestureRecognizerDelegate>
{
	
	Item* _item;
	UIWebView* _webView;
	UIToolbar* _toolbar;
	AudioStreamer* _player;
	AVAudioPlayer* _localPlayer;

	NSOperationQueue* _textOperationQueue;
	UIActivityIndicatorView* _indicatorView;
	BOOL _isLocalPlay;
	
	UISlider* _slider;
	UILabel* _leftTimeLabel;
	UILabel* _rightTimeLabel;
	
	BOOL _type;
	
	UIScrollView* _scrollView;
	NSTimer* _scrollTimer;
	CGFloat _currentOffset;
	BOOL _isAutoScrolling;
	BOOL _isDisappear;
	BOOL _isLoaded;
	
	UILabel* _progressLabel;
	
	NSTimer* _progressTimer;
	
	VOAImageDisplayView* _imageDisplayView;
    
    BOOL _clickedPlayButton;
    BOOL _observerGesture;
}

@property(nonatomic, retain)Item* _item;
@property(nonatomic, retain)UIWebView* _webView;
@property(nonatomic, retain)UIToolbar* _toolbar;;
@property(nonatomic, retain)NSOperationQueue* _textOperationQueue;
@property(nonatomic, retain)UIActivityIndicatorView* _indicatorView;

@property(nonatomic, retain) UISlider* _slider;
@property(nonatomic, retain) UILabel* _leftTimeLabel;
@property(nonatomic, retain) UILabel* _rightTimeLabel;

@property(nonatomic, retain)NSTimer* _scrollTimer;

@property(nonatomic,retain)NSTimer* _progressTimer;

@property(nonatomic,retain)VOAImageDisplayView* _imageDisplayView;

@property(nonatomic,retain)UIScrollView* _scrollView;
@property(nonatomic,retain)UILabel* _progressLabel;

@property(nonatomic,retain)UITapGestureRecognizer* _tapGestureRecognizer;

- (void)initWebView;
- (void)updateContent:(Item*)item type:(NSUInteger)type;
- (void)initToolbar:(BOOL)isOnline;
- (void)initProgressInfo;
- (void)clickPlayButton:(id)sender;
- (void)clickPauseButton:(id)sender;

- (void)doubleClickWebView:(NSNotification*)notification;
- (void)startScrollWebPage;
- (void)stopScrollWebPage;

- (void)initRightBarButtonItem;

- (void)rearrange;

- (void)displayImage:(NSString*)urlString;

@end
