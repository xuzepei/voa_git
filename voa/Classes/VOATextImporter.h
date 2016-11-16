//
//  VOATextImporter.h
//  VOA
//
//  Created by xuzepei on 6/19/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface VOATextImporter : NSOperation {
	
	NSString* _requestUrl;
	NSURLConnection* _urlConnection;
	NSManagedObjectID* _objectID;
	id _delegate;
}

@property (nonatomic, retain) NSString* _requestUrl;
@property (nonatomic, retain) NSURLConnection* _urlConnection;
@property (nonatomic, retain) NSManagedObjectID* _objectID;
@property (nonatomic, assign) id _delegate;

- (void)main;

@end
