//
//  RCDictionaryViewController.m
//  SAT
//
//  Created by xu zepei on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RCDictionaryViewController.h"
#import "RCDictionaryHttpRequest.h"
#import "RCVoiceHttpRequest.h"
#import "RCTool.h"


#define BK_COLOR [UIColor colorWithRed:251/255.0 green:245/255.0 blue:149/255.0 alpha:1.00]

@interface RCDictionaryViewController ()

@end

@implementation RCDictionaryViewController
@synthesize _word;
@synthesize _webView;
@synthesize _player;
@synthesize _indicatorView;
@synthesize _noResultsLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.view.backgroundColor = BK_COLOR;
        
        UIBarButtonItem* rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                            target:self
                                                                                            action:@selector(clickRightBarButtonItem:)];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
        [rightBarButtonItem release];
        
        [self initWebView];
        
        [self initIndicatorView];
        
        [self initNoResultsLabel];
        
    }
    return self;
}

- (void)dealloc
{
    self._word = nil;
    
    if(_webView)
        _webView.delegate = nil;
    self._webView = nil;
    
    self._player = nil;
    
    self._indicatorView = nil;
    
    self._noResultsLabel = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self initWebView];
    
    [self initIndicatorView];
    
    [self initNoResultsLabel];
    
    [self rearrange];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    if(_webView)
        _webView.delegate = nil;
    self._webView = nil;
    
    self._indicatorView = nil;
    
    self._noResultsLabel = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
	[self rearrange];
}

- (void)rearrange
{
    if(_webView)
    {
        UIInterfaceOrientation statusBarOrientation =[UIApplication sharedApplication].statusBarOrientation;
        
        if(UIInterfaceOrientationLandscapeLeft ==statusBarOrientation || UIInterfaceOrientationLandscapeRight ==statusBarOrientation)
        {
            CGFloat height = [RCTool getScreenSize].width - STATUS_BAR_HEIGHT - self.navigationController.navigationBar.frame.size.height - TAB_BAR_HEIGHT;
            if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
            {
                height = [RCTool getScreenSize].width;
            }
            
            _webView.frame = CGRectMake(0,0,[RCTool getScreenSize].height,height);
            
            if(_indicatorView)
            {
                _indicatorView.center = CGPointMake(self.view.bounds.size.height/2.0,self.view.bounds.size.width/2.0);
            }
        }
        else
        {
            CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT;
            if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
            {
                height = [RCTool getScreenSize].height;
            }
            
            _webView.frame = CGRectMake(0,0,[RCTool getScreenSize].width,height);
            
            if(_indicatorView)
            {
                _indicatorView.center = CGPointMake(self.view.bounds.size.width/2.0,self.view.bounds.size.height/2.0);
            }
        }
    }
    

}

- (void)updateContent:(NSDictionary *)word
{
    if(nil == word)
        return;
    
    if(NO == [RCTool isReachableViaInternet])
	{
        [RCTool showAlert:NSLocalizedString(@"Hint",@"") message:NSLocalizedString(@"Internet Connection Required.", @"")];
        
		return;
	}
    
    self._word = word;
    
    NSString* text = [_word objectForKey:@"word"];
	if([text length])
    {
        self.title = text;
        
        [self explanationOfWord];
        
        [self voiceOfWord];
    }
    
    [self rearrange];
}

- (void)explanationOfWord
{
    NSString* text = [_word objectForKey:@"word"];
    if(0 == [text length])
        return;
    
    //获取单词解释
    NSString* urlString = [[NSString alloc] initWithFormat:@"http://education.yahoo.com/reference/dictionary/entry/%@",text];
    RCDictionaryHttpRequest* temp = [[[RCDictionaryHttpRequest alloc] init] autorelease];
    [temp request:urlString delegate:self token:text];
    [urlString release];
}

- (void)voiceOfWord
{
    NSString* text = [_word objectForKey:@"word"];
    if(0 == [text length])
        return;
    
    //获取单词发音
    NSString* urlString = [[NSString alloc] initWithFormat:@"http://translate.google.com/translate_tts?tl=en&q=%@",text];
    RCVoiceHttpRequest* temp = [[[RCVoiceHttpRequest alloc] init] autorelease];
    [temp request:urlString delegate:self token:text];
    [urlString release];
}

- (void)initWebView
{
    if(nil == _webView)
    {
        CGFloat height = [RCTool getScreenSize].height - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - TAB_BAR_HEIGHT;
        if([RCTool systemVersion] >= 7.0 && ISFORIOS7)
        {
            height = [RCTool getScreenSize].height;
        }
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,[RCTool getScreenSize].width,height)];
        _webView.delegate = self;
        _webView.opaque = NO;
        _webView.backgroundColor = [UIColor clearColor];
        //_webView.scalesPageToFit = YES;
//        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        //隐藏UIWebView shadow
        [RCTool hidenWebViewShadow:_webView];
    }
    
    [self.view addSubview: _webView];
}

- (void)initIndicatorView
{
    if(nil == _indicatorView)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    
    _indicatorView.center = CGPointMake(160, 200 - 44);
}

- (void)initNoResultsLabel
{
    if(nil == _noResultsLabel)
    {
        _noResultsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,160,20)];
    }
    
    _noResultsLabel.font = [UIFont boldSystemFontOfSize: 16];
    _noResultsLabel.textColor = [UIColor colorWithRed:0.47 green:0.47 blue:0.47 alpha:1.00];
    _noResultsLabel.text = @"No results.";
    _noResultsLabel.textAlignment = UITextAlignmentCenter;
    _noResultsLabel.center = CGPointMake(160, 100);
    _noResultsLabel.backgroundColor = [UIColor clearColor];
}

- (void)speak:(id)argument
{
    NSString* text = [_word objectForKey:@"word"];
    if(0 == [text length])
        return;
    
    NSString* fileName = [RCTool voicePathOfWord:text];
    if([fileName length] && [RCTool isExistingFile:fileName])
    {
        if(NO == _isPlaying)
        { 
            NSURL* filePathURL = [NSURL fileURLWithPath:fileName];
            
            if(_player)
            {
                [_player stop];
                self._player = nil;
            }
            
            _player = [[AVAudioPlayer alloc] initWithContentsOfURL:filePathURL 
                                                             error:nil];
            _player.delegate = self;
            [_player prepareToPlay];
            if([_player play])
            {
                _isPlaying = YES;
            }
        }
    }
    else
    {
        _willPlay = YES;
        [self voiceOfWord];
    }
}

- (void)clickRightBarButtonItem:(id)sender
{
    [self explanationOfWord];
    
    [self voiceOfWord];
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"audioPlayerDidFinishPlaying");
    _isPlaying = NO;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"audioPlayerDecodeErrorDidOccur");
    _isPlaying = NO;
}

#pragma mark -
#pragma mark UIWebViewDelegate Method

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType
{
	if(navigationType == UIWebViewNavigationTypeFormSubmitted || 
	   navigationType == UIWebViewNavigationTypeBackForward ||
	   navigationType == UIWebViewNavigationTypeReload ||
	   navigationType == UIWebViewNavigationTypeFormResubmitted)
	{
		return NO;
	}
	
	NSString* urlString = [request.URL absoluteString];
	NSRange range = [urlString rangeOfString:@"http://education.yahoo.com/ref/dictionary/audio" 
									 options:NSCaseInsensitiveSearch];
	if(range.location != NSNotFound)
	{
		[self performSelector:@selector(speak:) withObject:nil afterDelay:0.01];
		return NO;
	}
    
	return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [_indicatorView stopAnimating];
    [_indicatorView removeFromSuperview];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[_indicatorView stopAnimating];
	[_indicatorView removeFromSuperview];
}

#pragma mark -
#pragma mark RCDictionaryHttpRequestDelegate Delegate

- (void)willStartDictionaryHttpRequest:(id)token
{
	[_noResultsLabel removeFromSuperview];
	[_webView addSubview: _indicatorView];
	[_indicatorView startAnimating];
}

- (void)didFinishDictionaryHttpRequest:(id)result token:(id)token
{
    NSString* text = [_word objectForKey:@"word"];
    if(0 == [text length])
        return;
    
    _tryTimes = 0;
    
	if(NO == [text isEqualToString: (NSString*)token])
    {
        [_webView addSubview: _noResultsLabel];
        return;
    }
	
	NSString* body = @"";
	NSString* webpage = (NSString*)result;
	if([webpage length])
	{
		NSRange range = [webpage rangeOfString:@"<div id=\"yeduarticle\">" options:NSCaseInsensitiveSearch];
		if(range.location != NSNotFound)
		{
			webpage = [webpage substringFromIndex:range.location];
			NSRange range1 = [webpage rangeOfString:@"<div id=\"yedurelatedarticles\">" options:NSCaseInsensitiveSearch];
			if(range1.location != NSNotFound)
			{
				webpage = [webpage substringToIndex:range1.location + range1.length];
			}
			else
			{
				range1 = [webpage rangeOfString:@"<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"400\">" options:NSCaseInsensitiveSearch];
				if(range1.location != NSNotFound)
				{
					webpage = [webpage substringToIndex:range1.location];
				}
				else	
					webpage = @"";
			}
		}
		else
			webpage = @"";
		
	}
	
	if([webpage length])
	{
		webpage = [webpage stringByReplacingOccurrencesOfString:@"<a href=\"/reference/dictionary/pronunciation_key\">KEY</a>" withString:@""];
		
		webpage = [webpage stringByReplacingOccurrencesOfString:@"http://l.yimg.com/a/i/edu/ref/ahd/t/pron.jpg" withString:[[NSBundle mainBundle] pathForResource:@"speaker" ofType:@"png"]];
	}
	
	if(0 == [webpage length])
	{
		[_webView addSubview: _noResultsLabel];
        return;
	}
	
	body = webpage;
	NSString* htmlString = [NSString stringWithFormat:@"<html>"
							"<head>"
                            "<style type=\"text/css\">body{-webkit-text-size-adjust: none;}</style>"
							"<link rel=\"stylesheet\" type=\"text/css\" href=\"rss.css\"/>"
							"</head>"
							"<body>"
							"%@"
							"</body>"
							"</html>",body];
	
	NSString *path = [[NSBundle mainBundle] resourcePath];
	path = [path stringByReplacingOccurrencesOfString:@"/" withString:@"//"];
	path = [path stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
	[_webView loadHTMLString:htmlString 
					 baseURL:[NSURL URLWithString: [NSString stringWithFormat:@"file:/%@//",path]]];
}

- (void)didFailDictionaryHttpRequest:(id)token
{
    if(_tryTimes < 3)
    {
    	[self explanationOfWord];
    }
    else
    {
    	[_webView addSubview: _noResultsLabel];
    	[_indicatorView stopAnimating];
    	[_indicatorView removeFromSuperview];
    }
}

#pragma mark - RCVoiceHttpRequestDelegate

- (void)willStartVoiceHttpRequest:(id)token
{
    
}

- (void)didFinishVoiceHttpRequest:(id)result token:(id)token
{
    if(_willPlay)
    {
        _willPlay = NO;
        [self speak:nil];
    }
}

- (void)didFailVoiceHttpRequest:(id)token
{
    
}

@end
