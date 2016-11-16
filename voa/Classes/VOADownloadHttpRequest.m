//
//  VOADownloadHttpRequest.m
//  NanGuangTV
//
//  Created by xuzepei on 09-9-9.
//  Copyright 2009 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOADownloadHttpRequest.h"
#import "RCTool.h"


@implementation VOADownloadHttpRequest

- (void)updatePercentage
{
	_currentLength += [_receivedData length];
	
	float percentage = 0;
	if(_currentLength >= 0 && self._expectedContentLength >= 0)
		percentage = _currentLength / (long double) self._expectedContentLength;
	
	NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:_requestingURL, @"url", self._token, @"delegate",nil];
	if([_delegate respondsToSelector: @selector(updatePercentage:token:)])
		[_delegate updatePercentage: percentage token:dict];
	[dict release];
}

- (void)writeDataToFile
{
	if([_receivedData length])
	{
		NSString* filePath = [RCTool getFilePathByUrl: _requestingURL];
		NSString* tempFilePath = [NSString stringWithFormat:@"%@_TEMP",filePath];
		char* fileName = (char*)[tempFilePath UTF8String];
		FILE* fp;
		fp = fopen(fileName,"ab");
		if(fp)
		{
			if(fwrite([_receivedData bytes], [_receivedData length], 1, fp))
			{
				fclose(fp);
				[self updatePercentage];
				[_receivedData setLength:0];
			}
			else 
			{
				fclose(fp);
				NSLog(@"write file failed!");
			}
		}
		else 
		{
			NSLog(@"open file failed!");
		}

	}
}

- (void)removeOldFile
{
	NSString* filePath = [RCTool getFilePathByUrl: _requestingURL];
	NSString* tempFilePath = [NSString stringWithFormat:@"%@_TEMP",filePath];
	[[NSFileManager defaultManager] removeItemAtPath: filePath error:nil];
	[[NSFileManager defaultManager] removeItemAtPath: tempFilePath error:nil];
}

- (void)request:(NSString*)url delegate:(id)delegate token:(id)token
{
	self._delegate = delegate;
	self._token = token;
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	NSString* urlString = url;
	NSRange range = [urlString rangeOfString:@"%"];
	if(range.location == NSNotFound)
		urlString = [urlString stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
	
	NSLog(@"downloadFile:%@",urlString);
	self._requestingURL = urlString;
	[self removeOldFile];
	
	if (_urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES])
	{
		_isConnecting = YES;
		[_receivedData setLength:0];
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
		NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:_requestingURL, @"url", self._token, @"delegate",nil];
		if([_delegate respondsToSelector: @selector(updatePercentage:token:)])
			[_delegate updatePercentage: 0 token:dict];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	self._statusCode = [(NSHTTPURLResponse*)response statusCode];
	NSDictionary* header = [(NSHTTPURLResponse*)response allHeaderFields];
	NSString *content_type = [header valueForKey:@"Content-Type"];
	_contentType = CT_UNKNOWN;
	if (content_type) 
	{
		if ([content_type rangeOfString:@"xml"].location != NSNotFound) 
			_contentType = CT_XML;
		else if ([content_type rangeOfString:@"json"].location != NSNotFound)
			_contentType = CT_JSON;
	}
	
	self._expectedContentLength = [response expectedContentLength];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_receivedData appendData: data];
	[self writeDataToFile];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"downloadFile:connectionDidFinishLoading- statusCode:%d",_statusCode);
	
	if(200 == _statusCode)
	{
		[self writeDataToFile];
		
		if(_currentLength == _expectedContentLength)
		{
			NSString* filePath = [RCTool getFilePathByUrl: _requestingURL];
			NSString* tempFilePath = [NSString stringWithFormat:@"%@_TEMP",filePath];
			
			if(0 == rename([tempFilePath UTF8String],[filePath UTF8String]))
			{
				NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:_requestingURL, @"url", self._token, @"delegate",nil];
				if([_delegate respondsToSelector: @selector(didFinishHttpRequest:token:)])
				[_delegate didFinishHttpRequest: filePath token:dict];
				
				_isConnecting = NO;
				[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
				[_receivedData setLength:0];
				self._urlConnection = nil;
				
				return;
			}
		}
	}

	//handel error
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength:0];
	self._urlConnection = nil;
	[self removeOldFile];
	
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:_requestingURL, @"url", self._token, @"delegate",nil];
	if([_delegate respondsToSelector: @selector(updatePercentage:token:)])
		[_delegate updatePercentage:0 token:dict];
	if([_delegate respondsToSelector: @selector(didFailHttpRequest:)])
		[_delegate didFailHttpRequest: dict];

}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
	NSLog(@"downloadFile:didFailWithError- statusCode:%d",_statusCode);
	//handel error
	
	_isConnecting = NO;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	[_receivedData setLength:0];
    self._urlConnection = nil;
	
	[self removeOldFile];
	
	NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:_requestingURL, @"url", self._token, @"delegate",nil];
	if([_delegate respondsToSelector: @selector(updatePercentage:token:)])
		[_delegate updatePercentage:0 token:dict];
	if([_delegate respondsToSelector: @selector(didFailHttpRequest:)])
		[_delegate didFailHttpRequest: dict];

}

@end
