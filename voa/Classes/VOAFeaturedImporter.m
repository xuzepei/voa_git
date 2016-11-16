//
//  VOAFeaturedImporter.m
//  VOA
//
//  Created by xuzepei on 6/16/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOAFeaturedImporter.h"
#import "RCTool.h"
#import "TBXML.h"
#import "VOACategory.h"
#import "Item.h"


@implementation VOAFeaturedImporter
@synthesize _requestUrl;
@synthesize _urlConnection;
@synthesize _delegate;
@synthesize _order;


- (void)dealloc
{
	[_requestUrl release];
	[_urlConnection release];
	[_order release];
	self._delegate = nil;
	
	[super dealloc];
}

- (void)parseItem:(NSString*)xmlString 
 insertionContext:(NSManagedObjectContext*)insertionContext
{
	if(0 == [xmlString length])
		return;
    
    NSString* idString = _order;
    if(0 == [idString length])
        return;
    
    @autoreleasepool {
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id == %@",idString];
        NSManagedObjectID* objectID = [RCTool getExistingEntityObjectIDForName: @"VOACategory"
                                                                     predicate: predicate
                                                               sortDescriptors: nil
                                                                       context: [RCTool getManagedObjectContext]];
        VOACategory* category = nil;
        if(nil == objectID)
            return;
        
        category = (VOACategory*)[RCTool insertEntityObjectForID:objectID
                                         managedObjectContext:insertionContext];
        
        
        /*       <div class="listbox">
         <ul class="e2">
         <li> <a href="/specialVOA/word/18409.html" class="preview"><img src="/uploads/allimg/120618/2214145N1-0-lp.jpg"></a>
         [<b><a href="/specialVOA/word/">词汇掌故</a></b>] <a href="/specialVOA/word/18409.html" class="title"><b>Words and Their Stories: Farm Expressions</b></a> <span class="info"> <small>日期：</small>2012-06-18 22:12:16 <small>点击：</small>12 <small>好评：</small>0 </span>
         </li><li> <a href="/specialVOA/word/17048.html" class="preview"><img src="/images/defaultpic.gif"></a>
         [<b><a href="/specialVOA/word/">词汇掌故</a></b>] <a href="/specialVOA/word/17048.html" class="title">Words and Their Stories: Bigwig</a> <span class="info"> <small>日期：</small>2012-04-08 13:22:54 <small>点击：</small>1397 <small>好评：</small>2 </span>
         </li>
         </ul>
         </div>
         */
        
        
        
        NSRange range = [xmlString rangeOfString:@"<div class=\"listbox\">"];
        if(NSNotFound != range.location)
        {
            xmlString = [xmlString substringFromIndex:range.location + range.length];
            if([xmlString length])
            {
                range = [xmlString rangeOfString:@"<!-- /listbox -->"];
                if(NSNotFound != range.location)
                {
                    xmlString = [xmlString substringToIndex:range.location];
                    NSRange range1 = [xmlString rangeOfString:@"<li> <a href=\'"];
                    
                    while(range1.location != NSNotFound)
                    {
                        NSString* title = nil;
                        NSString* link = nil;
                        //                    NSString* description = nil;
                        NSString* imageUrl = nil;
                        NSString* date = nil;
                        //                    NSString* type = nil;
                        
                        xmlString = [xmlString substringFromIndex:range1.location + range1.length];
                        
                        NSRange range2 = [xmlString rangeOfString:@"\'"];
                        if(range2.location != NSNotFound)
                        {
                            NSString* urlString = [xmlString substringToIndex:range2.location];
                            if([urlString length])
                            {
                                link = [NSString stringWithFormat:@"%@/%@",BASE_URL,urlString];
                            }
                        }
                        
                        
                        NSRange range3 = [xmlString rangeOfString:@"<img src=\'"];
                        if(range3.location != NSNotFound)
                        {
                            xmlString = [xmlString substringFromIndex:range3.location + range3.length];
                            
                            range3 = [xmlString rangeOfString:@"\'/>"];
                            if(range3.location != NSNotFound)
                            {
                                NSString* temp = [xmlString substringToIndex:range3.location];
                                if([temp length])
                                {
                                    if(NO == [temp hasSuffix:@".gif"])
                                    {
                                        temp = [temp stringByReplacingOccurrencesOfString:@"-lp." withString:@"."];
                                        imageUrl = [NSString stringWithFormat:@"%@/%@",BASE_URL,temp];
                                    }
                                }
                            }
                        }
                        
                        NSRange range4 = [xmlString rangeOfString:@"class=\"title\">"];
                        if(range4.location != NSNotFound)
                        {
                            xmlString = [xmlString substringFromIndex:range4.location + range4.length];
                            
                            range4 = [xmlString rangeOfString:@"</"];
                            if(range4.location != NSNotFound)
                            {
                                NSString* temp = [xmlString substringToIndex:range4.location];
                                if([temp length])
                                {
                                    temp = [temp stringByReplacingOccurrencesOfString:@"<b>" withString:@""];
                                    title = temp;
                                }
                            }
                        }
                        
                        
                        NSRange range5 = [xmlString rangeOfString:@"</small>"];
                        if(range5.location != NSNotFound)
                        {
                            xmlString = [xmlString substringFromIndex:range5.location + range5.length];
                            
                            range5 = [xmlString rangeOfString:@"<small>"];
                            if(range5.location != NSNotFound)
                            {
                                NSString* temp = [xmlString substringToIndex:range5.location];
                                if([temp length])
                                {
                                    date = temp;
                                }
                            }
                        }
                        
                        if([link length])
                        {
                            NSString* itemId = [RCTool md5: link];
                            if([itemId length])
                            {
                                NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id = %@",itemId];
                                NSManagedObjectID* objectID = [RCTool getExistingEntityObjectIDForName: @"Item"
                                                                                             predicate: predicate
                                                                                       sortDescriptors: nil
                                                                                               context: insertionContext];
                                
                                
                                Item* item = nil;
                                if(nil == objectID)
                                {
                                    item = [RCTool insertEntityObjectForName:@"Item" 
                                                        managedObjectContext:insertionContext];
                                    
                                    item.id = itemId;
                                }
                                else
                                {
                                    item = (Item*)[RCTool insertEntityObjectForID:objectID
                                                             managedObjectContext:insertionContext];
                                }
                                
                                item.link = link;
                                item.imageUrl = imageUrl;
                                
                                if([title length])
                                    item.title = title;
                                else
                                    item.title = @"No title.";
                                
                                if(0 == [item.pubDate length])
                                {
                                    item.pubDate = date;
                                }	
                                
                                [category addItemsObject:item];
                            }
                        }
                        
                        range1 = [xmlString rangeOfString:@"<li> <a href=\'"];
                        
                    }
                }
            }
            
        }
        
    }
    
}


- (void)main 
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	if (_delegate && [_delegate respondsToSelector:@selector(featuredImporterDidStart:)]) 
	{
		[_delegate performSelectorOnMainThread:@selector(featuredImporterDidStart:) 
									withObject:self
								 waitUntilDone:YES];
    }
	
	NSManagedObjectContext* insertionContext = [[NSManagedObjectContext alloc] init];
	
	[insertionContext setPersistentStoreCoordinator:[RCTool getPersistentStoreCoordinator]];
    if (_delegate && [_delegate respondsToSelector:@selector(importerDidSave:)]) 
	{
        [[NSNotificationCenter defaultCenter] addObserver:_delegate 
												 selector:@selector(importerDidSave:) 
													 name:NSManagedObjectContextDidSaveNotification 
												   object:insertionContext];
    }
	
	
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	NSString* urlString = [_requestUrl stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
	[request setURL:[NSURL URLWithString: urlString]];
	[request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[request setTimeoutInterval: TIME_OUT];
	[request setHTTPShouldHandleCookies:FALSE];
	[request setHTTPMethod:@"GET"];
	
	NSLog(@"getFeaturedFrom:%@",_requestUrl);
	
	NSError* error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request 
                                         returningResponse:NULL 
                                                     error:&error];
	
	NSString* xmlString = nil;
	if(data)
	{
		xmlString = [[NSString alloc] initWithData:data 
										  encoding:NSUTF8StringEncoding];
		
		
		[self parseItem: xmlString insertionContext:insertionContext];
		
		
		[xmlString release];
		
		NSError *saveError = nil;
		if([insertionContext hasChanges])
		{
			if(NO == [insertionContext save:&saveError])
				NSLog(@"Unhandled error saving managed object context in %s:%@",
					  __FILE__,[saveError localizedDescription]);
		}
	}
	
	
    if (_delegate && [_delegate respondsToSelector:@selector(importerDidSave:)]) 
	{
        [[NSNotificationCenter defaultCenter] removeObserver:_delegate 
														name:NSManagedObjectContextDidSaveNotification 
													  object:insertionContext];
    }
	
	[insertionContext release];
	
	
	if (_delegate && [_delegate respondsToSelector:@selector(featuredImporterDidFinish:)]) 
	{
		[_delegate performSelectorOnMainThread:@selector(featuredImporterDidFinish:) 
									withObject:self
								 waitUntilDone:YES];
	}
	
    [pool release];
}

@end
