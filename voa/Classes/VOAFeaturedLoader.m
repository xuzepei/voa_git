//
//  VOAFeaturedLoader.m
//  VOA
//
//  Created by xuzepei on 6/9/11.
//  Copyright 2011 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOAFeaturedLoader.h"


@implementation VOAFeaturedLoader
@synthesize _willRequestArray;
@synthesize _requestingURLArray;
@synthesize _failedURLArray;

+ (VOAFeaturedLoader*)sharedInstance
{
	static VOAFeaturedLoader* sharedInstance = nil;
	if (nil == sharedInstance)
	{
		@synchronized([VOAFeaturedLoader class])
		{
			sharedInstance = [[VOAFeaturedLoader alloc] init];
		}
	}
	
	return sharedInstance;
}

- (id)init
{
	if(self = [super init])
	{
		_willRequestArray = [[NSMutableArray alloc] init];
		_requestingURLArray = [[NSMutableArray alloc] init];
		_failedURLArray = [[NSMutableArray alloc] init];
	}
	
	return self;
}

- (void)dealloc
{
	[_willRequestArray release];
	[_requestingURLArray release];
	[_failedURLArray release];
	
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

- (void)removeRequestingURL:(NSString*)urlString
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

- (BOOL)isFailedRequestingURL:(NSString*)urlString
{
	int i = 0;
	for(NSString* temp in _failedURLArray)
	{
		if([temp isEqualToString: urlString])
		{
			i++;
		}
	}
	
	if(i >= 3)
		return YES;
	
	return NO;
}

- (BOOL)download:(NSString*)url delegate:(id)delegate order:(id)order
{
	if(0 == [url length])
		return NO;
	
	if([self isRequestingURL: url])
		return NO;
	
	if([self isFailedRequestingURL: url])
		return NO;
	
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys: 
						  url, @"url", 
						  delegate, @"delegate", 
						  order,@"order",nil];
	
	if(0 == [_requestingURLArray count])
	{
		VOAFeaturedHttpRequest* request = [[[VOAFeaturedHttpRequest alloc] init] autorelease];
		[request request:url delegate:self token:dict];
		[_requestingURLArray addObject:url];
	}
	else
	{
		[_willRequestArray addObject:dict];
	}

	return YES;
}

- (void)doNext
{
	if([_willRequestArray count] && 0 == [_requestingURLArray count])
	{
		NSDictionary* dict = [_willRequestArray objectAtIndex:0];
		
		NSString* url = [dict objectForKey:@"url"];
		if([url length])
		{
			VOAFeaturedHttpRequest* request = [[[VOAFeaturedHttpRequest alloc] init] autorelease];
			[request request:url delegate:self token:dict];
			[_requestingURLArray addObject:url];
		}
		
		[_willRequestArray removeObjectAtIndex:0];
	}
}


#pragma mark -
#pragma mark RCHttpRequestDelegate

- (void) willStartHttpRequest: (id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSString* urlString = [dict objectForKey: @"url"];
	NSDictionary* temp = (NSDictionary*)[dict objectForKey:@"token"];
	id delegate = [temp objectForKey:@"delegate"];
	
	if([delegate respondsToSelector: @selector(startLoad:)])
		[delegate startLoad:urlString];
}

- (void)didFinishHttpRequest: (id)result token: (id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSString* urlString = [dict objectForKey: @"url"];
	NSDictionary* temp = (NSDictionary*)[dict objectForKey:@"token"];
	id delegate = [temp objectForKey:@"delegate"];
	
	[self removeRequestingURL: urlString];
	
	if([urlString length])
	{
		if([delegate respondsToSelector: @selector(succeedLoad:token:)])
			[delegate succeedLoad:result token:urlString];
	}
	
	
	[self doNext];
}

- (void) didFailHttpRequest:(id)token
{
	NSDictionary* dict = (NSDictionary*)token;
	NSString* urlString = [dict objectForKey: @"url"];
	NSDictionary* temp = (NSDictionary*)[dict objectForKey:@"token"];
	id delegate = [temp objectForKey:@"delegate"];
	[self removeRequestingURL: urlString];
	[_failedURLArray addObject: urlString];
	
	if([delegate respondsToSelector: @selector(failedLoad:)])
		[delegate failedLoad:urlString];
	
	[self doNext];
}

@end
