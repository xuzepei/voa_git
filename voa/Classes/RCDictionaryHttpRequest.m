//
//  RCDictionaryHttpRequest.m
//  SAT
//
//  Created by xu zepei on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RCDictionaryHttpRequest.h"
#import "RCTool.h"

@implementation RCDictionaryHttpRequest

+ (RCDictionaryHttpRequest*)sharedInstance
{
	static RCDictionaryHttpRequest* sharedInstance = nil;
	if(nil == sharedInstance)
	{
		@synchronized([RCDictionaryHttpRequest class])
		{
            if(nil == sharedInstance)
            {
                sharedInstance = [[RCDictionaryHttpRequest alloc] init];
            }
		}
	}
	
	return sharedInstance;
}

- (BOOL)request:(NSString*)urlString delegate:(id)delegate token:(id)token
{
    if(0 == [urlString length] || _isConnecting == YES)
		return NO;
    
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
        return NO;
	
	NSLog(@"requestDictionary: %@",urlString);
	
    _urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	
	if (_urlConnection)
	{
		_isConnecting = YES;
		[_receivedData setLength: 0];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
        
		if([_delegate respondsToSelector: @selector(willStartDictionaryHttpRequest:)])
			[_delegate willStartDictionaryHttpRequest:_token];
		
        return YES;
	}
    
    return NO;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"requestDictionary:connectionDidFinishLoading- statusCode:%d",_statusCode);
	
	if(200 == _statusCode)
	{
		NSString* xmlString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
		
		if([_delegate respondsToSelector: @selector(didFinishDictionaryHttpRequest:token:)])
			[_delegate didFinishDictionaryHttpRequest:xmlString token:_token];
        
        [xmlString release];
	}
	else
	{
		if([_delegate respondsToSelector: @selector(didFailDictionaryHttpRequest:)])
			[_delegate didFailDictionaryHttpRequest:_token];
	}
	
    
    _isConnecting = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_receivedData setLength:0];
    self._urlConnection = nil;
    
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	NSLog(@"requestDictionary:didFailWithError - statusCode:%d",_statusCode);
    
    if([_delegate respondsToSelector: @selector(didFailDictionaryHttpRequest:)])
        [_delegate didFailDictionaryHttpRequest:_token];
	
    _isConnecting = NO;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [_receivedData setLength:0];
    self._urlConnection = nil;
    
}

@end
