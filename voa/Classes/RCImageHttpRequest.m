//
//  RCImageHttpRequest.m
//  rsscoffee
//
//  Created by xuzepei on 5/9/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "RCImageHttpRequest.h"
#import "RCTool.h"


@implementation RCImageHttpRequest

+ (RCImageHttpRequest*)sharedInstance
{
	static RCImageHttpRequest* sharedInstance = nil;
	if(nil == sharedInstance)
	{
		@synchronized([RCImageHttpRequest class])
		{
			sharedInstance = [[RCImageHttpRequest alloc] init];
		}
	}
	
	return sharedInstance;
}

- (id)init
{
	if(self = [super init])
	{
		
	}
	
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)saveImage: (NSString*)url delegate: (id)delegate token:(id)token
{
	_saveToLocal = YES;
	self._delegate = delegate;
	self._token = token;
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	NSString* urlString = url;
	self._requestingURL = urlString;
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
	
    if(_urlConnection)
        return;
    
	//NSLog(@"saveImage: %@",urlString);
    
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	if (_urlConnection)
	{
		_isConnecting = YES;
		[_receivedData setLength:0];
		
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self._requestingURL, @"url",
							  self._token,@"token",nil];
		if([_delegate respondsToSelector: @selector(willStartHttpRequest:)])
			[_delegate willStartHttpRequest:dict];
	}
}

- (void)downloadImage: (NSString*)url delegate:(id)delegate token:(id)token
{
	_saveToLocal = NO;
	self._delegate = delegate;
	self._token = token;
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	NSString* urlString = url;
	self._requestingURL = urlString;
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
    
    if(_urlConnection)
        return;
	
	//NSLog(@"downloadImage: %@",urlString);
    
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if(_urlConnection)
	{
		_isConnecting = YES;
		[_receivedData setLength:0];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self._requestingURL, @"url",
							  self._token,@"token",nil];
		if([_delegate respondsToSelector: @selector(willStartHttpRequest:)])
			[_delegate willStartHttpRequest:dict];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//NSLog(@"downloadImage:connectionDidFinishLoading- statusCode:%d",_statusCode);
	
	if(200 == _statusCode)
	{
		UIImage* image = [UIImage imageWithData: _receivedData];
		
		if(image)
		{
			if(_saveToLocal)
			{
				[RCTool saveImage:_receivedData path:self._requestingURL];
			}
			
			NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
								  self._requestingURL, @"url",
								  [NSNumber numberWithBool:_saveToLocal],@"isSaved",
								  self._token,@"token",nil];
			if([_delegate respondsToSelector: @selector(didFinishHttpRequest:token:)])
				[_delegate didFinishHttpRequest: image token: dict];
		}
	}
	else
	{
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self._requestingURL, @"url",
							  self._token,@"token",nil];
		if([_delegate respondsToSelector: @selector(didFailHttpRequest:)])
			[_delegate didFailHttpRequest:dict];
	}
	
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength:0];
    self._urlConnection = nil;
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	//NSLog(@"downloadImage:didFailWithError- statusCode:%d",_statusCode);
	
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  self._requestingURL, @"url",
						  self._token,@"token",nil];
	if([_delegate respondsToSelector: @selector(didFailHttpRequest:)])
		[_delegate didFailHttpRequest:dict];
	
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength:0];
    self._urlConnection = nil;
}

@end
