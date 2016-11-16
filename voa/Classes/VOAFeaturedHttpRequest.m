//
//  VOAFeaturedHttpRequest.m
//  VOA
//
//  Created by xuzepei on 6/16/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOAFeaturedHttpRequest.h"
#import "RCTool.h"

@implementation VOAFeaturedHttpRequest

+ (VOAFeaturedHttpRequest*)sharedInstance
{
	static VOAFeaturedHttpRequest* sharedInstance = nil;
	if(nil == sharedInstance)
	{
		@synchronized([VOAFeaturedHttpRequest class])
		{
			sharedInstance = [[VOAFeaturedHttpRequest alloc] init];
		}
	}
	
	return sharedInstance;
}

- (void)request:(NSString*)urlString delegate:(id)delegate token:(id)token
{
	self._delegate = delegate;
	self._token = token;
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	self._requestingURL = urlString;
	urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
	
    if(_urlConnection)
        return;
    
    NSLog(@"requestFeatured: %@",urlString);
	
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if (_urlConnection)
	{
		_isConnecting = YES;
		[_receivedData setLength: 0];
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
	NSLog(@"requestFeatured:connectionDidFinishLoading- statusCode:%d",_statusCode);
	
	if(200 == _statusCode)
	{
		NSString* xmlString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
		
		NSString* order = @"";
		
		if(_token)
		{
			order = [_token objectForKey:@"order"];
			if(0 == [order length])
				order = @"";
		}
		
		NSManagedObjectID* categoryObjectID = [RCTool parseFeatured: xmlString requestUrl:_requestingURL order:order];
		
		[xmlString release];
		
		_isConnecting = NO;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[_receivedData setLength:0];
		self._urlConnection = nil;
		
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self._requestingURL, @"url",
							  self._token,@"token",nil];

		if([_delegate respondsToSelector: @selector(didFinishHttpRequest:token:)])
			[_delegate didFinishHttpRequest:categoryObjectID token:dict];
	}
	else
	{
		
		_isConnecting = NO;
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		[_receivedData setLength:0];
		self._urlConnection = nil;
		
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
							  self._requestingURL, @"url",
							  self._token,@"token",nil];

		if([_delegate respondsToSelector: @selector(didFailHttpRequest:)])
			[_delegate didFailHttpRequest:dict];
	}
	

}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	NSLog(@"requestFeatured:didFailWithError - statusCode:%d",_statusCode);
	
	
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength: 0];
    self._urlConnection = nil;
	
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
						  self._requestingURL, @"url",
						  self._token,@"token",nil];
	
	if([_delegate respondsToSelector: @selector(didFailHttpRequest:)])
		[_delegate didFailHttpRequest: dict];
	

	
}

@end
