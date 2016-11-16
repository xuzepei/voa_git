//
//  VOADownloadHttpRequest.h
//  NanGuangTV
//
//  Created by xuzepei on 09-9-9.
//  Copyright 2009 Rumtel Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import"RCHttpRequest.h"

@interface VOADownloadHttpRequest : RCHttpRequest {
	
	
}

- (void)request:(NSString*)url delegate:(id)delegate token:(id)token;

@end
