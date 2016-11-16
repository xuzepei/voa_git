//
//  VOAFeaturedImporter.h
//  VOA
//
//  Created by xuzepei on 6/16/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VOAFeaturedImporter : NSOperation {

	NSString* _requestUrl;
	NSURLConnection* _urlConnection;
	id _delegate;
	NSString* _order;
	
}

@property (nonatomic, retain) NSString* _requestUrl;
@property (nonatomic, retain) NSURLConnection* _urlConnection;
@property (nonatomic, assign) id _delegate;
@property (nonatomic, retain) NSString* _order;

- (void)main;

@end
