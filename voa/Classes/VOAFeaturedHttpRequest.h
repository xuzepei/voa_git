//
//  VOAFeaturedHttpRequest.h
//  VOA
//
//  Created by xuzepei on 6/16/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RCHttpRequest.h"


@interface VOAFeaturedHttpRequest : RCHttpRequest {

}

+ (VOAFeaturedHttpRequest*)sharedInstance;
- (void)request:(NSString*)urlString 
	   delegate:(id)delegate 
		  token:(id)token;

@end
