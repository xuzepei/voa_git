//
//  NGVideoLoader.h
//  NanGuangTV
//
//  Created by xuzepei on 09-9-9.
//  Copyright 2009 Rumtel Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VOADownloadHttpRequest.h"

@interface VOADownloadLoader : NSObject <RCHttpRequestDelegate> {
	
	NSMutableArray* _requestingURLArray;
	NSMutableArray* _httpRequestArray;
}

@property (nonatomic, retain)NSMutableArray* _requestingURLArray;
@property (nonatomic, retain)NSMutableArray* _httpRequestArray;

+ (VOADownloadLoader*)sharedInstance;
- (void)download:(NSString*)urlString delegate:(id)delegate token:(id)token;
- (void) startHttpRequest: (NSString*)urlString delegate:(id)delegate token:(id)token;
- (void) cancelHttpRequest:(NSString*)urlString;

@end


@protocol VOADownloadLoaderDelegate <NSObject>
@optional
- (void) didStartDownload: (id)token;
- (void) didFinishDownload: (id)result token: (id)token;
- (void) didFailDownload: (id)token;
- (void) updateDownloadPercentage: (float)percentage token: (id)token;
@end
