//
//  VOAFeaturedLoader.h
//  VOA
//
//  Created by xuzepei on 6/9/11.
//  Copyright 2011 Rumtel Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VOAFeaturedHttpRequest.h"

@interface VOAFeaturedLoader : NSObject<RCHttpRequestDelegate> {

	NSMutableArray* _willRequestArray;
	NSMutableArray* _requestingURLArray;
	NSMutableArray* _failedURLArray;
	
}

@property(nonatomic, retain)NSMutableArray* _willRequestArray;
@property(nonatomic, retain)NSMutableArray* _requestingURLArray;
@property(nonatomic, retain)NSMutableArray* _failedURLArray;

+ (VOAFeaturedLoader*)sharedInstance;
- (BOOL)download:(NSString*)url delegate:(id)delegate order:(id)order;
- (BOOL)isRequestingURL: (NSString*)urlString;

@end


@protocol VOAFeaturedLoaderDelegate
@optional
- (void)startLoad:(id)token;
- (void)succeedLoad:(id)result token:(id)token;
- (void)failedLoad:(id)token;

@end
