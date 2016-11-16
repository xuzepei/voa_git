//
//  RCDictionaryHttpRequest.h
//  SAT
//
//  Created by xu zepei on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHttpRequest.h"

@protocol RCDictionaryHttpRequestDelegate <NSObject>
- (void)willStartDictionaryHttpRequest: (id)token;
- (void)didFinishDictionaryHttpRequest:(id)result token:(id)token;
- (void)didFailDictionaryHttpRequest:(id)token;

@end

@interface RCDictionaryHttpRequest : RCHttpRequest
{
}

+ (RCDictionaryHttpRequest*)sharedInstance;
- (BOOL)request:(NSString*)urlString 
	   delegate:(id)delegate 
		  token:(id)token;

@end
