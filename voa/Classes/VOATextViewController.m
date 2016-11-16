//
//  VOATextViewController.m
//  VOA
//
//  Created by xuzepei on 6/17/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOATextViewController.h"
#import "Item.h"
#import "RCTool.h"
#import "AudioStreamer.h"
#import "VOATextImporter.h"
#import "VOAAppDelegate.h"
#import "WRSysTabBarController.h"
#import "VOAImageDisplayView.h"
#import "RCHintView.h"
#import "RCImageDisplayViewController.h"
#import "VOAAppDelegate.h"

#define TOOLBAR_LANDSCAPE_HEIGHT 30.0f
#define TOOLBAR_HEIGHT 44.0f
#define NAVIGATION_BAR_LANDSCAPE_HEIGHT 32.0f


@implementation VOATextViewController
@synthesize _item;
@synthesize _webView;
@synthesize _toolbar;
@synthesize _textOperationQueue;
@synthesize _indicatorView;
@synthesize _slider;
@synthesize _leftTimeLabel;
@synthesize _rightTimeLabel;
@synthesize _scrollTimer;
@synthesize _progressTimer;
@synthesize _imageDisplayView;
@synthesize _scrollView;
@synthesize _progressLabel;
@synthesize _tapGestureRecognizer;


// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		
		_isLocalPlay = NO;
        _observerGesture = YES;
		
        [self initWebView];
		
		//进度转圈指示
		_indicatorView = [[UIActivityIndicatorView alloc]
						  initWithActivityIndicatorStyle:
						  UIActivityIndicatorViewStyleGray];
		
		//下载器
		_textOperationQueue = [[NSOperationQueue alloc] init];
		
		
		//双击webview通知
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(doubleClickWebView:)
													 name:@"doubleClickWebView"
												   object:nil];
		
		//定时更新播放进度
		self._progressTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                                               target: self
                                                             selector: @selector(updateProgressInfo:)
                                                             userInfo: nil
                                                              repeats: YES];
		[_progressTimer fire];
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBannerAD:) name:SHOW_ADBANNER_NOTIFICATION object:nil];
    
    [self initWebView];
    
    [self rearrange];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL hideHintView = [[userDefaults objectForKey:@"hideHintView"] boolValue];
    
    if(NO == hideHintView)
    {
        RCHintView* hintView = [[[RCHintView alloc] initWithFrame:CGRectMake(0,0,200,80)] autorelease];
        hintView.center = CGPointMake([RCTool getScreenSize].width/2.0, [RCTool getScreenSize].height/2.0);
        [hintView updateContent:@"Hint" text:@"Double tap to stop scrolling"];
        [[RCTool frontWindow] addSubview: hintView];
        
        [UIView animateWithDuration:6.0 animations:^{
            
            hintView.alpha = 0.0;
        } completion:^(BOOL finished) {
            [hintView removeFromSuperview];
        }];
        
        [userDefaults setBool:YES forKey:@"hideHintView"];
        [userDefaults synchronize];
    }

    
    //Once the view has loaded then we can register to begin recieving controls and we can become the first responder
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
	
	if(_player)
		[_player start];
	else if(_localPlayer)
	{
		[self clickPlayButton:nil];
	}
	
	VOAAppDelegate* appDelegate = (VOAAppDelegate*)[UIApplication sharedApplication].delegate;
	WRSysTabBarController* temp = appDelegate._tabBarController;
	temp._shouldAutorotateToInterfaceOrientation = YES;
	
    //	UIMenuItem *customMenuItem1 = [[[UIMenuItem alloc] initWithTitle:@"Dictionary" action:@selector(clickMenuItem1:)] autorelease];
    //    UIMenuItem *customMenuItem2 = [[[UIMenuItem alloc] initWithTitle:@"Translate" action:@selector(clickMenuItem2:)] autorelease];
    //    [[UIMenuController sharedMenuController] setMenuItems:[NSArray arrayWithObjects:customMenuItem1, customMenuItem2, nil]];
    
    [self rearrange];
    
    [self showBannerAD:nil];
	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    //End recieving events
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self resignFirstResponder];
    
	VOAAppDelegate* appDelegate = (VOAAppDelegate*)[UIApplication sharedApplication].delegate;
	WRSysTabBarController* temp = appDelegate._tabBarController;
	temp._shouldAutorotateToInterfaceOrientation = NO;
	
    if(_indicatorView)
        [_indicatorView removeFromSuperview];
	
	_isDisappear = YES;
	if(_player)
	{
		[_player removeObserver:self forKeyPath:@"state"];
		[_player stop];
		[_player release];
		_player = nil;
	}
	
	if(_localPlayer)
	{
		[_localPlayer stop];
		[_localPlayer release];
		_localPlayer = nil;
	}
	
	[self stopScrollWebPage];
}


//for iOS6
- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
	
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	[self rearrange];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    _webView.delegate = nil;
    self._webView = nil;
    self._scrollView = nil;
    
    self._toolbar = nil;
    self._slider = nil;
    self._leftTimeLabel = nil;
    self._rightTimeLabel = nil;
}


- (void)dealloc
{
	self._item = nil;
    
    _webView.delegate = nil;
	[_webView release];
    _webView = nil;
    
	self._toolbar = nil;
    
    self._textOperationQueue = nil;
    
	self._indicatorView = nil;
    
    self._slider = nil;
    self._leftTimeLabel = nil;
    self._rightTimeLabel = nil;
    self._progressLabel = nil;
    
    self._imageDisplayView = nil;
	
	if(_player)
		[_player removeObserver:self forKeyPath:@"state"];
	
	[_player release];
	[_localPlayer release];
	
	self._scrollView = nil;
	
	if(_scrollTimer)
	{
		[_scrollTimer invalidate];
		[_scrollTimer release];
        _scrollTimer = nil;
	}
	
    if(_progressTimer)
    {
        [_progressTimer invalidate];
        [_progressTimer release];
        _progressTimer = nil;
    }
    
    self._tapGestureRecognizer = nil;
    
    [super dealloc];
}

- (void)initWebView
{
    CGRect rect = self.view.bounds;
    
    //NSLog(@"rect:%@",NSStringFromCGRect(rect));
    
    //设置可以自动滚动的WebView
    if(nil == _scrollView)
    {
        CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
        if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
        {
            height = [RCTool getScreenSize].height;
        }
        
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0,0,rect.size.width,height)];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|
            UIViewAutoresizingFlexibleBottomMargin|
            UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    }
    
    [self.view addSubview: _scrollView];
    
    if(nil == _webView)
    {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,rect.size.width,[RCTool getScreenSize].height - STATUS_BAR_HEIGHT - AD_HEIGHT)];
        _webView.userInteractionEnabled = YES;
        _webView.delegate = self;
        _webView.opaque = NO;
        _webView.backgroundColor = [UIColor clearColor];
        //        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        //隐藏UIWebView shadow
        [RCTool hidenWebViewShadow:_webView];
        
        
        if(nil == _tapGestureRecognizer)
        {
            _tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handleTaps:)];
            _tapGestureRecognizer.delegate = self;
        }
        
        _tapGestureRecognizer.numberOfTapsRequired = 2;
        [_webView addGestureRecognizer:_tapGestureRecognizer];
    }
    
    [_scrollView addSubview: _webView];
    
    _scrollView.contentSize = CGSizeMake(rect.size.width, [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - AD_HEIGHT + 100);
}

- (void)rearrange
{
    UIInterfaceOrientation statusBarOrientation =[UIApplication sharedApplication].statusBarOrientation;
	
	if(UIInterfaceOrientationLandscapeLeft ==statusBarOrientation || UIInterfaceOrientationLandscapeRight ==statusBarOrientation)
	{

        CGFloat height = [RCTool getScreenSize].width - STATUS_BAR_HEIGHT - self.navigationController.navigationBar.frame.size.height;
        if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
        {
            height = [RCTool getScreenSize].width;
        }
        
        if(_scrollView)
        {
            _scrollView.frame = CGRectMake(0,0,[RCTool getScreenSize].height,height);
        }
        
        if(_webView)
        {
            _webView.frame = CGRectMake(0,0,[RCTool getScreenSize].height,height);
            
            NSString* scrollHeight = [_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
            if([scrollHeight length])
            {
                double height = [scrollHeight doubleValue];
                if(height > 0)
                {
                    _webView.frame = CGRectMake(0,0,[RCTool getScreenSize].height,height - 1200);
                    _scrollView.contentSize = CGSizeMake([RCTool getScreenSize].height,height - 1200);
                }
            }
        }
        
        if(_toolbar)
        {
            _toolbar.frame = CGRectMake(0,height - TOOLBAR_LANDSCAPE_HEIGHT,[RCTool getScreenSize].height,TOOLBAR_LANDSCAPE_HEIGHT);
        }
        
        if(_progressLabel)
            _progressLabel.frame = CGRectMake(10,(_toolbar.frame.size.height - 20)/2.0,100,20);
        
        
        if(_rightTimeLabel)
        {
            _rightTimeLabel.frame = CGRectMake(344, (_toolbar.frame.size.height - 20)/2.0, 40, 20);
        }
        
        if(_leftTimeLabel)
        {
            _leftTimeLabel.frame = CGRectMake(0, (_toolbar.frame.size.height - 20)/2.0, 40, 20);
        }
        
        if(_slider)
        {
            _slider.frame = CGRectMake(40,(_toolbar.frame.size.height - 40)/2.0,300,40);
        }
        
        
        if(_imageDisplayView)
        {
            _imageDisplayView.frame = CGRectMake(0,0,[RCTool getScreenSize].height,[RCTool getScreenSize].width - STATUS_BAR_HEIGHT - self.navigationController.navigationBar.frame.size.height);
            [_imageDisplayView rearrange];
        }
	}
	else
	{
        CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
        if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
        {
            height = [RCTool getScreenSize].height;
        }
        

        if(_scrollView)
        {
            _scrollView.frame = CGRectMake(0,0,[RCTool getScreenSize].width,height);
        }
        
        if(_webView)
        {
            _webView.frame = CGRectMake(0,0,[RCTool getScreenSize].width,height);
            
            NSString* scrollHeight = [_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
            if([scrollHeight length])
            {
                double height = [scrollHeight doubleValue];
                if(height > 0)
                {
                    _webView.frame = CGRectMake(0,0,[RCTool getScreenSize].width,height);
                    _scrollView.contentSize = CGSizeMake([RCTool getScreenSize].width,height + 100);
                }
            }
        }
        
        if(_toolbar)
        {
            _toolbar.frame = CGRectMake(0,height - TOOLBAR_HEIGHT,[RCTool getScreenSize].width,TOOLBAR_HEIGHT);
        }
		
        if(_progressLabel)
            _progressLabel.frame = CGRectMake(10,(_toolbar.frame.size.height - 20)/2.0,100,20);
        
        if(_rightTimeLabel)
        {
            _rightTimeLabel.frame = CGRectMake(220, (_toolbar.frame.size.height - 20)/2.0, 40, 20);
        }
        
        if(_leftTimeLabel)
        {
            _leftTimeLabel.frame = CGRectMake(0, (_toolbar.frame.size.height - 20)/2.0, 40, 20);
        }
        
        if(_slider)
        {
            _slider.frame = CGRectMake(40,(_toolbar.frame.size.height - 40)/2.0,180,40);
        }
        
        if(_imageDisplayView)
        {
            _imageDisplayView.frame = CGRectMake(0,0,[RCTool getScreenSize].width,[RCTool getScreenSize].height - STATUS_BAR_HEIGHT - self.navigationController.navigationBar.frame.size.height);
            [_imageDisplayView rearrange];
        }
        
	}
	
    if(_indicatorView)
    {
        _indicatorView.center = CGPointMake(self.view.bounds.size.width/2.0,self.view.bounds.size.height/2.0);
    }
	
	_indicatorView.hidden = NO;
	_scrollView.hidden = NO;
    
    
}

- (void)initToolbar:(BOOL)isOnline
{
	_clickedPlayButton = YES;
    
    CGRect rect = self.view.bounds;
    
    CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT;
    if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
    {
        height = [RCTool getScreenSize].height;
    }
    
    if(nil == _toolbar)
    {
        _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,height - TOOLBAR_HEIGHT,rect.size.width,NAVIGATION_BAR_HEIGHT)];
        _toolbar.barStyle = UIBarStyleBlackTranslucent;
        _toolbar.barTintColor = [UIColor blackColor];
    }
    
    [self rearrange];
    
	if(isOnline)
	{
		UIBarButtonItem* buttonItem0 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
		buttonItem0.width = 10;
        
        UIBarButtonItem* buttonItem1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                        target:nil action:nil];
		//buttonItem1.width = 10;
		
		UIBarButtonItem* buttonItem2 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:
                                        UIBarButtonSystemItemPause
                                        target:self action:@selector(clickPauseOnlineButton:)];
        buttonItem2.tintColor = [UIColor whiteColor];
		
		UIBarButtonItem* buttonItem3 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                        target:nil action:nil];
		
		UIBarButtonItem* buttonItem4 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:
                                        UIBarButtonSystemItemAction
                                        target:self action:@selector(clickActionButtonItem:)];
        buttonItem4.tintColor = [UIColor whiteColor];
        
        UIBarButtonItem* buttonItem5 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
		buttonItem0.width = 10;
		
		
		[_toolbar setItems:[NSArray arrayWithObjects:buttonItem0,buttonItem1,
							buttonItem2,buttonItem3,buttonItem4,buttonItem5,nil] animated:YES];
		[buttonItem0 release];
		[buttonItem1 release];
		[buttonItem2 release];
		[buttonItem3 release];
        [buttonItem4 release];
        [buttonItem5 release];
        
		[self.view addSubview:_toolbar];
		
        if(nil == _progressLabel)
        {
            _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,(_toolbar.frame.size.height - 20)/2.0,100,20)];
        }
		_progressLabel.backgroundColor = [UIColor clearColor];
		_progressLabel.font = [UIFont boldSystemFontOfSize:14];
		_progressLabel.textColor = [UIColor whiteColor];
		[_toolbar addSubview: _progressLabel];
	}
	else
	{
		UIBarButtonItem* buttonItem0 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                        target:nil action:nil];
		//buttonItem0.width = 270;
		
		UIBarButtonItem* buttonItem1 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:
                                        UIBarButtonSystemItemPause
                                        target:self action:@selector(clickPauseButton:)];
        buttonItem1.tintColor = [UIColor whiteColor];
        
        UIBarButtonItem* buttonItem2 = [[UIBarButtonItem alloc]
                                        initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                        target:nil action:nil];
		buttonItem2.width = 10;
		
		[_toolbar setItems:[NSArray arrayWithObjects:buttonItem0,buttonItem1,buttonItem2,nil] animated:YES];
		[buttonItem0 release];
		[buttonItem1 release];
        [buttonItem2 release];
		[self.view addSubview:_toolbar];
		
        if(nil == _slider)
        {
            _slider = [[UISlider alloc] initWithFrame:CGRectMake(40,(_toolbar.frame.size.height - 40)/2.0,180,40)];
            [_slider setThumbImage:[UIImage imageNamed:@"handle"] forState:UIControlStateNormal];
        }
		[_toolbar addSubview: _slider];
		
        if(nil == _leftTimeLabel)
        {
            _leftTimeLabel = [[UILabel alloc] initWithFrame:
                              CGRectMake(0, (_toolbar.frame.size.height - 20)/2.0, 40, 20)];
        }
		_leftTimeLabel.backgroundColor = [UIColor clearColor];
		_leftTimeLabel.textColor = [UIColor whiteColor];
		_leftTimeLabel.font = [UIFont boldSystemFontOfSize:14];
		_leftTimeLabel.textAlignment = NSTextAlignmentCenter;
		_leftTimeLabel.text = @"0:00";
		[_toolbar addSubview: _leftTimeLabel];
		
        if(nil == _rightTimeLabel)
        {
            _rightTimeLabel = [[UILabel alloc] initWithFrame:
                               CGRectMake(220, (_toolbar.frame.size.height - 20)/2.0, 40, 20)];
        }
		_rightTimeLabel.backgroundColor = [UIColor clearColor];
		_rightTimeLabel.textColor = [UIColor whiteColor];
		_rightTimeLabel.font = [UIFont boldSystemFontOfSize:14];
		_rightTimeLabel.textAlignment = NSTextAlignmentCenter;
		_rightTimeLabel.text = @"0:00";
		[_toolbar addSubview: _rightTimeLabel];
		
		[_slider addTarget:self
					action:@selector(progressDidChange:)
		  forControlEvents:UIControlEventValueChanged];
		
		[self initProgressInfo];
	}
    
    [self rearrange];
}

- (void)clickPlayButton:(id)sender
{
    _clickedPlayButton = YES;
    
    UIBarButtonItem* buttonItem0 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                    target:nil action:nil];
	
	UIBarButtonItem* pauseButtonItem = [[UIBarButtonItem alloc]
										initWithBarButtonSystemItem:
										UIBarButtonSystemItemPause
										target:self action:@selector(clickPauseButton:)];
    pauseButtonItem.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem* buttonItem2 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                    target:nil action:nil];
    buttonItem2.width = 10;
	
	[_toolbar setItems:[NSArray arrayWithObjects:buttonItem0,pauseButtonItem,buttonItem2,nil] animated:YES];
	[buttonItem0 release];
	[pauseButtonItem release];
    [buttonItem2 release];
	
	if(_localPlayer)
	{
		if(_slider.value >= _localPlayer.duration)
			_localPlayer.currentTime = 0;
		
		[_localPlayer play];
	}
    
}

- (void)clickPauseButton:(id)sender
{
    _clickedPlayButton = NO;
    
    UIBarButtonItem* buttonItem0 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                    target:nil action:nil];
	
	UIBarButtonItem* playButtonItem = [[UIBarButtonItem alloc]
									   initWithBarButtonSystemItem:
									   UIBarButtonSystemItemPlay
									   target:self action:@selector(clickPlayButton:)];
    playButtonItem.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem* buttonItem2 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                    target:nil action:nil];
    buttonItem2.width = 10;
	
	[_toolbar setItems:[NSArray arrayWithObjects:buttonItem0,playButtonItem,buttonItem2,nil] animated:YES];
	[buttonItem0 release];
	[playButtonItem release];
    [buttonItem2 release];
	
	if(_localPlayer)
	{
		[_localPlayer pause];
	}
	
	[self stopScrollWebPage];
}

- (IBAction)clickPlayOnlineButton:(id)sender
{
    _clickedPlayButton = YES;
    
    UIBarButtonItem* buttonItem0 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                    target:nil action:nil];
    buttonItem0.width = 10;
    
    UIBarButtonItem* buttonItem1 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                    target:nil action:nil];
    
    UIBarButtonItem* buttonItem2 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:
                                    UIBarButtonSystemItemPause
                                    target:self action:@selector(clickPauseOnlineButton:)];
    buttonItem2.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem* buttonItem3 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                    target:nil action:nil];
    
    UIBarButtonItem* buttonItem4 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:
                                    UIBarButtonSystemItemAction
                                    target:self action:@selector(clickActionButtonItem:)];
    buttonItem4.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem* buttonItem5 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                    target:nil action:nil];
    buttonItem0.width = 10;
    
    
    [_toolbar setItems:[NSArray arrayWithObjects:buttonItem0,buttonItem1,
                        buttonItem2,buttonItem3,buttonItem4,buttonItem5,nil] animated:YES];
    [buttonItem0 release];
    [buttonItem1 release];
    [buttonItem2 release];
    [buttonItem3 release];
    [buttonItem4 release];
    [buttonItem5 release];
    
    [self.view addSubview:_toolbar];
	
	if(_player)
	{
		[_player start];
	}
	
}

- (IBAction)clickPauseOnlineButton:(id)sender
{
    _clickedPlayButton = NO;
    
    
    UIBarButtonItem* buttonItem0 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                    target:nil action:nil];
    buttonItem0.width = 10;
    
    UIBarButtonItem* buttonItem1 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                    target:nil action:nil];
    //buttonItem1.width = 10;
    
    UIBarButtonItem* buttonItem2 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:
                                    UIBarButtonSystemItemPlay
                                    target:self action:@selector(clickPlayOnlineButton:)];
    buttonItem2.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem* buttonItem3 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                    target:nil action:nil];
    
    UIBarButtonItem* buttonItem4 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:
                                    UIBarButtonSystemItemAction
                                    target:self action:@selector(clickActionButtonItem:)];
    buttonItem4.tintColor = [UIColor whiteColor];
    
    UIBarButtonItem* buttonItem5 = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                    target:nil action:nil];
    buttonItem0.width = 10;
    
    
    [_toolbar setItems:[NSArray arrayWithObjects:buttonItem0,buttonItem1,
                        buttonItem2,buttonItem3,buttonItem4,buttonItem5,nil] animated:YES];
    [buttonItem0 release];
    [buttonItem1 release];
    [buttonItem2 release];
    [buttonItem3 release];
    [buttonItem4 release];
    [buttonItem5 release];
    
    [self.view addSubview:_toolbar];
 	
	if(_player)
	{
		[_player pause];
	}
	
	[self stopScrollWebPage];
}

- (IBAction)progressDidChange:(UISlider*)sender
{
	if(_localPlayer)
	{
		_localPlayer.currentTime = sender.value;
		_leftTimeLabel.text = [NSString stringWithFormat:@"%d:%02d",
                               (int)_localPlayer.currentTime / 60,
                               (int)_localPlayer.currentTime % 60, nil];
		
	}
}

- (void)initProgressInfo
{
	_slider.minimumValue = 0.0;
	if(_localPlayer)
	{
		NSTimeInterval duration = _localPlayer.duration;
		_rightTimeLabel.text = [NSString stringWithFormat:@"%d:%02d",
								(int)duration / 60,
								(int)duration % 60, nil];
		_slider.maximumValue = duration;
	}
}

- (void)updateProgressInfo:(NSTimer*)timer
{
	if(_localPlayer.playing)
	{
		_slider.value = _localPlayer.currentTime;
		_leftTimeLabel.text = [NSString stringWithFormat:@"%d:%02d",
							   (int)_localPlayer.currentTime / 60,
							   (int)_localPlayer.currentTime % 60, nil];
	}
}

- (void)updateContent:(Item*)item type:(NSUInteger)type
{
	if(nil == item)
		return;
	
	if(_isDisappear)
		return;
	
	self._item = item;
	_item.isRead = [NSNumber numberWithBool:YES];
	self.title = _item.title;
	
	NSLog(@"link:%@",_item.link);
	
	_type = type;
    
	NSString *path = [[NSBundle mainBundle] resourcePath];
	path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	
	if(0 == [_item.text length] && 0 == [_item.address length])
	{
		VOATextImporter* textImporter = [[[VOATextImporter alloc] init] autorelease];
		textImporter._delegate = self;
		textImporter._requestUrl = item.link;
		textImporter._objectID = [_item objectID];
		[_textOperationQueue addOperation: textImporter];
		return;
	}
	
	//if([_item.text length])
	{
		//NSLog(@"_item.text:%@",_item.text);
        
        NSRange range = [_item.text rangeOfString:@"不提供文本"];
        if(range.location != NSNotFound)
        {
            _item.text = @"This news has no text.";
            _isAutoScrolling = YES;
        }
        
        
		NSString* text = @"";
		NSString* topImagePath = [RCTool getImageLocalPath:_item.imageUrl];
		
		NSString* cssName = @"voa.css";
		if([RCTool isBigFont])
			cssName = @"voa2.css";
        
		if([RCTool isExistingFile:topImagePath])
		{
			text = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"%@\"/><script type=\"text/javascript\" charset=\"utf-8\" src=\"voa.js\"></script></head><body><div class=\"titleDiv\"><font>%@</font></div><div class=\"dashedLine\"></div><br><a href=\"%@\"><img class=\"topImage\" src=\"%@\"/></a>%@<br><br></body></html>",
					cssName,_item.title,_item.imageUrl,topImagePath,_item.text];
		}
		else
		{
			text = [NSString stringWithFormat:@"<html><head><link rel=\"stylesheet\" type=\"text/css\" href=\"%@\"/><script type=\"text/javascript\" charset=\"utf-8\" src=\"voa.js\"></script></head><body><div class=\"titleDiv\"><font>%@</font></div><div class=\"dashedLine\"></div>%@<br><br></body></html>",
                    cssName,_item.title,_item.text];
		}
		
		text = [RCTool getColorText:text];
		[_webView loadHTMLString:text baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",path]]];
	}
	
	
	if([_item.address length])
	{
		NSLog(@"_item.address:%@",_item.address);
        
		if([RCTool isExistingFile:[RCTool getFilePathByUrl:_item.address]])
		{
			_isLocalPlay = YES;
			_localPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[RCTool getFilePathByUrl:_item.address]]
																  error:nil];
			_localPlayer.delegate = self;
			_localPlayer.volume = 1.0;
			[_localPlayer prepareToPlay];
			[_localPlayer play];
			
			[self initToolbar: NO];
			
			[self initRightBarButtonItem];
			
		}
		else
		{
			[self initToolbar: YES];
			
			if([RCTool isReachableViaInternet])
			{
				NSString* urlString = _item.address;
				_player = [[AudioStreamer alloc] initWithURL:[NSURL URLWithString:urlString]];
				[_player start];
				_progressLabel.text = NSLocalizedString(@"buffering...",@"");
				
				[_player addObserver:self forKeyPath:@"state"
							 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
							 context:nil];
				
				NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval: 0.5
																  target: self
																selector: @selector(handleProgressTimer:)
																userInfo: nil
																 repeats: YES];
				[timer fire];
			}
			else
			{
                [RCTool showAlert:NSLocalizedString(@"Hint",@"") message:NSLocalizedString(@"Internet Connection Required.", @"")];
				return;
			}
		}
	}
    
    
    MPMediaItemArtwork* artWork = nil;
    
    NSString* topImagePath = [RCTool getImageLocalPath:_item.imageUrl];
    if([RCTool isExistingFile:topImagePath])
    {
        artWork = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithContentsOfFile:topImagePath]];
    }
    
    NSMutableDictionary* mediaInfo = [[NSMutableDictionary alloc] init];
    [mediaInfo setObject:self.title forKey:MPMediaItemPropertyTitle];
    if(artWork)
    {
        [mediaInfo setObject:artWork forKey:MPMediaItemPropertyArtwork];
        [artWork release];
    }
    
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaInfo];
    [mediaInfo release];
    
}

- (void)clickActionButtonItem:(id)sender
{
	NSLog(@"clickActionButtonItem");
	
	NSString* thirdItem;
	if(_isAutoScrolling)
	{
		thirdItem = NSLocalizedString(@"Stop scrolling",@"");
	}
	else
	{
		thirdItem = NSLocalizedString(@"Auto scrolling",@"");
	}
	
	UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil
															 delegate: self
													cancelButtonTitle: NSLocalizedString(@"Cancel",@"")
											   destructiveButtonTitle:nil
												    otherButtonTitles:
								  NSLocalizedString(@"Add to Favorites",@""),
								  NSLocalizedString(@"Download",@""),
								  thirdItem,nil];
	actionSheet.tag = 0;
	[actionSheet showFromToolbar:_toolbar];
    [actionSheet release];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	
	if(0 == actionSheet.tag)
	{
		if(0 == buttonIndex)
		{
			NSLog(@"Add to Favorites");
			
			if(NO == [_item.isFavorited boolValue])
            {
				_item.isFavorited = [NSNumber numberWithBool:YES];
                [RCTool saveCoreData];
            }
		}
		else if(1 == buttonIndex)
		{
			NSLog(@"Download");
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"addDownloadItem"
																object:nil
															  userInfo:[NSDictionary dictionaryWithObject:_item
																								   forKey:@"item"]];
		}
		else if(2 == buttonIndex)
		{
			if(_isAutoScrolling)
				[self stopScrollWebPage];
			else
				[self startScrollWebPage];
		}
	}
}


- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (_webView.superview != nil) {
        if (action == @selector(clickMenuItem1:) ||
			action == @selector(clickMenuItem2:))
		{
            return YES;
        }
    }
	
    return [super canPerformAction:action withSender:sender];
}

- (void)displayImage:(NSString*)urlString
{
    RCImageDisplayViewController* temp = [[RCImageDisplayViewController alloc] initWithNibName:nil bundle:nil];
    [temp updateContent:urlString];
    [self presentViewController:temp animated:YES completion:nil];

//    _observerGesture = NO;
    
//    if(_imageDisplayView.superview)
//        return;
//    
//    self._imageDisplayView = [[[VOAImageDisplayView alloc] initWithFrame:CGRectZero] autorelease];
//    
//    UIInterfaceOrientation statusBarOrientation =[UIApplication sharedApplication].statusBarOrientation;
//    
//    if(UIInterfaceOrientationLandscapeLeft ==statusBarOrientation || UIInterfaceOrientationLandscapeRight ==statusBarOrientation)
//    {
//        _imageDisplayView.frame = CGRectMake(0,0,[RCTool getScreenSize].height,[RCTool getScreenSize].width - STATUS_BAR_HEIGHT - self.navigationController.navigationBar.frame.size.height);
//    }
//    else
//    {
//        _imageDisplayView.frame = CGRectMake(0,0,[RCTool getScreenSize].width,[RCTool getScreenSize].height - STATUS_BAR_HEIGHT - self.navigationController.navigationBar.frame.size.height);
//    }
//    
//    
//    [_imageDisplayView updateContent: urlString delegate: self];
//    
////    UIApplication *app = [UIApplication sharedApplication];
////    [app setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
//    
////    UIWindow *frontWindow = [[app windows] lastObject];
//    [self.view addSubview: _imageDisplayView];
    
}

- (void)closeImage
{
    _observerGesture = YES;
    
//	UIApplication *app = [UIApplication sharedApplication];
//	[app setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	
	if(_imageDisplayView)
		[_imageDisplayView removeFromSuperview];
}

#pragma mark -
#pragma mark action event

- (void)clickMenuItem1:(id)sender
{
	NSLog(@"clickDictionaryMenuItem");
}

- (void)clickMenuItem2:(id)sender
{
	NSLog(@"clickTranslateMenuItem");
}


#pragma mark -
#pragma mark http request

- (void)importerDidSave:(NSNotification *)notification
{
	//如果是当前线程的managedObjectContext,则不用merge
	if ([notification object] == [RCTool getManagedObjectContext])
		return;
	
	if ([NSThread isMainThread])
	{
		NSManagedObjectContext* context = [RCTool getManagedObjectContext];
        [context mergeChangesFromContextDidSaveNotification: notification];
		
	}
    else
	{
		//转到主线程执行，直到完成
        [self performSelectorOnMainThread:@selector(importerDidSave:)
							   withObject:notification
							waitUntilDone:YES];
    }
}

#pragma mark -
#pragma mark key value observer

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object change:(NSDictionary *)change
					   context:(void *)context
{
	if([keyPath isEqualToString:@"state"])
	{
		NSLog(@"state:%d", [[object valueForKey:keyPath] intValue]);
		
		int state = [[object valueForKey:keyPath] intValue];
		if(state == AS_PLAYING ||state == AS_BUFFERING)
		{
			[self initProgressInfo];
			
			_progressLabel.text = NSLocalizedString(@"buffering...",@"");
		}
		else
		{
			if(state == AS_STOPPED)
			{
				NSLog(@"play is stopped");
				_progressLabel.text = @"";
			}
		}
		
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}


- (void)textImporterDidStart:(id)token
{
    //	UIApplication *app = [UIApplication sharedApplication];
    //	UIWindow *frontWindow = [[app windows] lastObject];
	CGRect rect = self.view.frame;
	_indicatorView.center = CGPointMake(rect.size.width/2.0,rect.size.height/2.0);
	[self.view addSubview: _indicatorView];
	
	[_indicatorView startAnimating];
}

- (void)textImporterDidFinish:(id)token
{
	[_indicatorView stopAnimating];
	[_indicatorView removeFromSuperview];
	
	if([_item.address length])
	{
		[self updateContent:_item type:_type];
	}
}


#pragma mark -
#pragma mark UIWebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
	if(UIWebViewNavigationTypeLinkClicked == navigationType)
	{
		NSString* urlString = [[request URL] absoluteString];
		if([RCTool isImageUrl: urlString])
		{
			[self displayImage: urlString];
		}
        
		return NO;
	}
	
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //	UIApplication *app = [UIApplication sharedApplication];
    //	UIWindow *frontWindow = [[app windows] lastObject];
	_indicatorView.center = CGPointMake(160,160);
	[self.view addSubview: _indicatorView];
	
	[_indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
	[_indicatorView stopAnimating];
	[_indicatorView removeFromSuperview];
	
	CGRect rect = self.view.frame;
	
	NSString* scrollHeight = [_webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
	if([scrollHeight length])
	{
		double height = [scrollHeight doubleValue];
		if(height > 0)
		{
			_webView.frame = CGRectMake(0,0,rect.size.width,height);
			_scrollView.contentSize = CGSizeMake(rect.size.width,height + 100);
			
			if([RCTool isAutoScroll])
            {
				[self doubleClickWebView:nil];
            }
		}
	}
	
    //	if(NO == _forbidRotating)
    //	{
    //
    //	}
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
					   successfully:(BOOL)flag
{
	[self clickPauseButton:nil];
}

#pragma mark -
#pragma mark progress update timer

- (void)handleProgressTimer: (NSTimer*)timer
{
	if(nil == _player)
		return;
	
	//NSLog(@"%lf",_player.progress);
	
	if([_player isPlaying])
	{
		_progressLabel.text = [NSString stringWithFormat:@"%02d:%02d",
							   (int)_player.progress / 60,
							   (int)_player.progress % 60, nil];
	}
    //	else
    //	{
    //		_progressLabel.text = @"";
    //	}
}

#pragma mark -
#pragma mark scroll web page

- (void)doubleClickWebView:(NSNotification*)notification
{
	NSLog(@"doubleClickWebView");
	
	if(_isAutoScrolling)
		[self stopScrollWebPage];
	else
		[self startScrollWebPage];
}

- (void)autoScroll:(NSTimer*)timer
{
	CGPoint point = _scrollView.contentOffset;
	_currentOffset = point.y;
	
	//NSLog(@"%f,%f",_scrollView.contentSize.height, _scrollView.contentOffset.y);
	if(_scrollView.contentSize.height - 450 > _scrollView.contentOffset.y)
		_scrollView.contentOffset = CGPointMake(point.x, _currentOffset + 0.7);
	else
	{
		[self stopScrollWebPage];
	}
}

- (void)startScrollWebPage
{
	if(_scrollView.contentSize.height - 450 <= _scrollView.contentOffset.y)
		return;
	
	self._scrollTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
                                                         target: self
                                                       selector: @selector(autoScroll:)
                                                       userInfo: nil
                                                        repeats: YES];
	[_scrollTimer fire];
	_isAutoScrolling = YES;
}

- (void)stopScrollWebPage
{
	if(_scrollTimer)
	{
		[_scrollTimer invalidate];
		[_scrollTimer release];
        _scrollTimer = nil;
	}
    
    _isAutoScrolling = NO;
}


#pragma mark -
#pragma mark right bar button item

- (void)initRightBarButtonItem
{
	if([_item.isFavorited boolValue])
	{
		UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithImage:[UIImage imageNamed:@"favorited.png"]
											   style:UIBarButtonItemStylePlain
											   target:self
											   action:@selector(clickRightBarButtonItem:)];
		self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        rightBarButtonItem.tintColor = [UIColor yellowColor];
		[rightBarButtonItem release];
	}
	else
	{
		UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc]
											   initWithImage:[UIImage imageNamed:@"favorite.png"]
											   style:UIBarButtonItemStylePlain
											   target:self
											   action:@selector(clickRightBarButtonItem:)];
		self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        rightBarButtonItem.tintColor = [UIColor grayColor];
		[rightBarButtonItem release];
	}
    
}

- (void)clickRightBarButtonItem:(id)sender
{
	_item.isFavorited = [_item.isFavorited boolValue]?[NSNumber numberWithBool:NO]:[NSNumber numberWithBool:YES];
	[self initRightBarButtonItem];
	[RCTool saveCoreData];
}

#pragma mark - Remote Control Events
//Make sure we can recieve remote control events
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    //if it is a remote control event handle it correctly
    if (event.type == UIEventTypeRemoteControl) {
        if (event.subtype == UIEventSubtypeRemoteControlPlay) {
            
                        if(_isLocalPlay)
                            [self clickPlayButton:nil];
                        else
                            [self clickPlayOnlineButton:nil];
            
        } else if (event.subtype == UIEventSubtypeRemoteControlPause) {
            
                        if(_isLocalPlay)
                            [self clickPauseButton:nil];
                        else
                            [self clickPauseOnlineButton:nil];
            
        } else if (event.subtype == UIEventSubtypeRemoteControlTogglePlayPause) {
            
            if(_isLocalPlay)
            {
                if(_localPlayer)
                {
                    if(_clickedPlayButton)
                        [self clickPauseButton:nil];
                    else
                        [self clickPlayButton:nil];
                }
            }
            else
            {
                if(_player)
                {
                    if(_clickedPlayButton)
                        [self clickPauseOnlineButton:nil];
                    else
                        [self clickPlayOnlineButton:nil];
                }
            }
            
        }
    }
}

#pragma mark Handle Gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return _observerGesture;
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//    return YES;
//}

- (void)handleTaps:(UITapGestureRecognizer*)paramSender
{
//    CGPoint touchPoint =
//    [paramSender locationOfTouch:0
//                          inView:paramSender.view];
    
    NSLog(@"handleTaps:%d",paramSender.numberOfTapsRequired);
    
    [self doubleClickWebView:nil];
}

- (void)showBannerAD:(NSNotification*)noti
{
    UIView* adView = [RCTool getAdView];
    if(adView)
    {
        CGRect rect =  adView.frame;
        rect.origin.y = self.view.frame.size.height - 44 - rect.size.height;
        adView.frame = rect;
        [self.view addSubview:adView];
        //[self.view addSubview:adView];
    }
}

//- (BOOL)canBecomeFirstResponder {
//    return YES;
//}
//
//- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
//    //if it is a remote control event handle it correctly
//    if (event.type == UIEventTypeRemoteControl)
//    {
//        if (event.subtype == UIEventSubtypeRemoteControlPlay)
//        {
//            [self clickedPlayButton:nil];
//        }
//        else if (event.subtype == UIEventSubtypeRemoteControlPause)
//        {
//            [self clickedPlayButton:nil];
//        }
//        else if (event.subtype == UIEventSubtypeRemoteControlNextTrack)
//        {
//            NSLog(@"Play next item");
//        }
//        else if (event.subtype == UIEventSubtypeRemoteControlPreviousTrack)
//        {
//            NSLog(@"Play previous item");
//        }
//
//        
//    }
//}

@end
