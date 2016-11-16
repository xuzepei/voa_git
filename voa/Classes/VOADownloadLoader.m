//
//  NGVideoLoader.m
//  NanGuangTV
//
//  Created by xuzepei on 09-9-9.
//  Copyright 2009 Rumtel Co.,Ltd. All rights reserved.
//

/*
 NGVideoLoader class for video downloading
 */

#import "VOADownloadLoader.h"
#import "VOADownloadHttpRequest.h"


@implementation VOADownloadLoader
@synthesize _requestingURLArray;
@synthesize _httpRequestArray;

+ (VOADownloadLoader*)sharedInstance
{
	static VOADownloadLoader* sharedInstance = nil;
	
	if(nil == sharedInstance)
	{
		@synchronized([VOADownloadLoader class])
		{
			sharedInstance = [[VOADownloadLoader alloc] init];
		}
	}
	
	return sharedInstance;
}

- (id)init
{
	if(self = [super init])
	{
		_requestingURLArray = [[NSMutableArray alloc] init];
		_httpRequestArray = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[_requestingURLArray release];
	[_httpRequestArray release];
	
	[super dealloc];
}


- (BOOL)isRequestingURL: (NSString*)urlString
{
	BOOL isRequesting = NO;
	for(NSString* temp in _requestingURLArray)
	{
		if([temp isEqualToString: urlString])
		{
			isRequesting = YES;
			break;
		}
	}
	
	return isRequesting;
}

- (void)removeRequestingURL: (NSString*)urlString
{
	NSInteger index = -1;
	NSUInteger i = 0;
	for(NSString* temp in _requestingURLArray)
	{
		if([temp isEqualToString: urlString])
		{
			index = i;
			break;
		}
		
		i++;
	}
	
	if(index != -1)
		[_requestingURLArray removeObjectAtIndex: index];
}

- (void)removeHttpRequest: (NSString*)urlString
{
	NSInteger index = -1;
	NSUInteger i = 0;
	for(VOADownloadHttpRequest* temp in _httpRequestArray)
	{
		if([temp._requestingURL isEqualToString: urlString])
		{
			index = i;
			break;
		}
		
		i++;
	}
	
	if(index != -1)
		[_httpRequestArray removeObjectAtIndex: index];
}

- (VOADownloadHttpRequest*)getHttpRequest: (NSString*)urlString
{
	VOADownloadHttpRequest* httpRequest = nil;
	for(VOADownloadHttpRequest* temp in _httpRequestArray)
	{
		if([temp._requestingURL isEqualToString: urlString])
		{
			httpRequest = temp;
			break;
		}
	}
	
	return httpRequest;
}

- (void)download:(NSString*)urlString delegate:(id)delegate token:(id)token
{
	if([self isRequestingURL: urlString])
		return;
	
	VOADownloadHttpRequest* httpRequest = [[VOADownloadHttpRequest alloc] init];
	[httpRequest request: urlString 
					 delegate: self 
						token: delegate];
	[_httpRequestArray addObject: httpRequest];
	[httpRequest release];
	
	[_requestingURLArray addObject: urlString];
}

- (void) startHttpRequest: (NSString*)urlString 
				 delegate:(id)delegate token:(id)token
{
	VOADownloadHttpRequest* temp = [self getHttpRequest: urlString];
	if(temp._urlConnection)
		[temp._urlConnection cancel];
	
	[self removeRequestingURL: urlString];
	[self removeHttpRequest: urlString];
	
	[self download: urlString delegate:delegate token: token];
}

- (void) cancelHttpRequest:(NSString*)urlString
{
	VOADownloadHttpRequest* temp = [self getHttpRequest: urlString];
	if(temp._urlConnection)
		[temp._urlConnection cancel];
	
	[_httpRequestArray removeObject: temp];
	if(0 == [_httpRequestArray count])
	{
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}
		
}


#pragma mark -
#pragma mark NGHttpRequestDelegate methods

- (void) didFinishHttpRequest: (id)result token: (id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSString* requestingURL = [dict valueForKey: @"url"];
	id delegate = [dict valueForKey: @"delegate"];
	
	[self removeRequestingURL: requestingURL];
	[self removeHttpRequest: requestingURL];
	
	NSDictionary* temp = [NSDictionary dictionaryWithObjectsAndKeys: requestingURL, @"url", nil];
	if([delegate respondsToSelector: @selector(didFinishDownload:token:)])
		[delegate didFinishDownload:result token:temp];
}

- (void) didFailHttpRequest: (id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSString* requestingURL = [dict valueForKey: @"url"];
	id delegate = [dict valueForKey: @"delegate"];
	
	[self removeRequestingURL: requestingURL];
	[self removeHttpRequest: requestingURL];
	
	NSDictionary* temp = [NSDictionary dictionaryWithObjectsAndKeys: requestingURL, @"url", nil];
	if([delegate respondsToSelector: @selector(didFailDownload:)])
		[delegate didFailDownload:temp];
	
}

- (void) updatePercentage: (float)percentage token: (id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSString* requestingURL = [dict valueForKey: @"url"];
	id delegate = [dict valueForKey: @"delegate"];
	
	NSDictionary* param = [[NSDictionary alloc] initWithObjectsAndKeys: requestingURL, @"url",nil];
	if([delegate respondsToSelector: @selector(updatePercentage:token:)])
		[delegate updatePercentage: percentage token: param];
	[param release];
}

@end
