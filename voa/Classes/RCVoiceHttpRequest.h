//
//  RCVoiceHttpRequest.h
//  SAT
//
//  Created by xu zepei on 5/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHttpRequest.h"

@protocol RCVoiceHttpRequestDelegate <NSObject>
- (void)willStartVoiceHttpRequest: (id)token;
- (void)didFinishVoiceHttpRequest:(id)result token:(id)token;
- (void)didFailVoiceHttpRequest:(id)token;

@end

@interface RCVoiceHttpRequest : RCHttpRequest
{
}

+ (RCVoiceHttpRequest*)sharedInstance;
- (BOOL)request:(NSString*)urlString 
	   delegate:(id)delegate 
		  token:(id)token;

@end
