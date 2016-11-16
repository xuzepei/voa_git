//
//  VOATextImporter.m
//  VOA
//
//  Created by xuzepei on 6/19/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import "VOATextImporter.h"
#import "RCTool.h"
#import "Item.h"


@implementation VOATextImporter
@synthesize _requestUrl;
@synthesize _urlConnection;
@synthesize _objectID;
@synthesize _delegate;


- (void)dealloc
{
	[_requestUrl release];
	[_urlConnection release];
	[_objectID release];
	self._delegate = nil;
	
	[super dealloc];
}

- (NSString*)cacheImages:(NSString*)text
{
	if(0 == [text length])
		return text;
    
    if([text length])
	{
        NSString* tempText = [[[NSString alloc] initWithString:text] autorelease];
        
        NSMutableArray* imageUrlArray = [[NSMutableArray alloc] init];
        
        NSRange range = [tempText rangeOfString:@"<img" options:NSCaseInsensitiveSearch];

        while(range.location != NSNotFound)
        {
            tempText = [tempText substringFromIndex:range.location + range.length];
            
            NSRange range1 = [tempText rangeOfString:@"src=\"" options:NSCaseInsensitiveSearch];
            if(range1.location != NSNotFound)
            {
                tempText = [tempText substringFromIndex:range1.location + range1.length];
                
                range1 = [tempText rangeOfString:@"\""];
                if(range1.location != NSNotFound)
                {
                    NSString* imageUrl = [tempText substringToIndex:range1.location];
                    if([imageUrl length])
                        [imageUrlArray addObject: imageUrl];
                }
            }
            
            range = [tempText rangeOfString:@"<img" options:NSCaseInsensitiveSearch];
        }
        
        for(NSString* imageUrl in imageUrlArray)
        {
            if([imageUrl hasPrefix:BASE_URL])
                continue;
            
            NSString* temp = [[NSString alloc] initWithFormat:@"%@%@",BASE_URL,imageUrl];
            text = [text stringByReplacingOccurrencesOfString:imageUrl withString:temp];
            [temp release];
        }

        [imageUrlArray release];
	}

	return text;
	
}

- (void)parseText:(NSString*)xmlString 
 insertionContext:(NSManagedObjectContext*)insertionContext
{
	if(0 == [xmlString length])
		return;
	
	if(nil == _objectID)
		return;
	
    @autoreleasepool {
        NSString* address = nil;
        NSString* text = nil;
        
/*        <div class="content">
        <table width="100%">
        <tbody><tr>
        <td><span style="float:left"><script type="text/javascript"> var cpro_id = 'u243491';</script>
        <script type="text/javascript" src="http://cpro.baidu.com/cpro/ui/c.js"></script><script type="text/javascript" charset="utf-8" src="http://pos.baidu.com/ecom?di=u243491&amp;tm=BAIDU_CPRO_SETJSONADSLOT&amp;fn=BAIDU_CPRO_SETJSONADSLOT&amp;baidu_id="></script><div style="display:none">-</div> <iframe id="cproIframe2" src="http://cpro.baidu.com/cpro/ui/uijs.php?tu=u243491&amp;tn=text_default_250_250&amp;n=xiaomudao123_cpr&amp;rsi1=250&amp;rsi0=250&amp;rad=&amp;rss0=%23FFFFFF&amp;rss1=%23FFFFFF&amp;rss2=%23FF0000&amp;rss3=%23444444&amp;rss4=%23008000&amp;rss5=&amp;rss6=%23e10900&amp;rsi5=4&amp;ts=1&amp;at=103&amp;ch=0&amp;cad=1&amp;aurl=&amp;rss7=&amp;cpa=1&amp;fv=11&amp;cn=0&amp;if=16&amp;word=http%3A%2F%2Fwww.voa365.com%2FspecialVOA%2Fword%2F18409.html&amp;refer=http%3A%2F%2Fwww.voa365.com%2FspecialVOA%2Fword%2F&amp;ready=1&amp;jk=16a8368bb6ee03ab&amp;jn=3&amp;lmt=1340001508&amp;csp=1280,800&amp;csn=1231,778&amp;ccd=24&amp;chi=50&amp;cja=true&amp;cpl=10&amp;cmi=101&amp;cce=true&amp;csl=en-US&amp;did=2&amp;rt=49&amp;dt=1340030609&amp;pn=4|text_default_960_90|103&amp;ev=50331648&amp;c01=0&amp;prt=1340030608328" width="250" height="250" align="center,center" marginwidth="0" marginheight="0" scrolling="no" frameborder="0" allowtransparency="true"></iframe>
        </span>
        <p><embed width="350" height="68" border="0" align="bottom" defaultframe="datawindow" invokeurls="1" clicktoplay="0" enablecontextmenu="1" allowscan="1" transparentatstart="0" animationatstart="0" autorewind="0" autostart="1" showcaptioning="0" showgotobar="0" autosize="0" showstatusbar="1" showdisplay="0" showtracker="1" showaudiocontrols="1" showpositioncontrols="0" showcontrols="1" name="MediaPlayer" pluginspage="http://www.microsoft.com/isapi/redir.dll?prd=windows&amp;sbp=mediaplayer&amp;ar=media&amp;sba=plugin&amp;" type="application/x-mplayer2" src="/uploads/media/2012/06/18/se-ws-farm-16jun12.mp3"> </p>
        <p><a href="/uploads/media/2012/06/18/se-ws-farm-16jun12.mp3" target="_blank">音频下载</a></p>
        <div class="watermark"><a title="Bonnie the cow is milked by Erik Ramfjord, at the Douglas Ranch in Paicines, California " rel="ibox" href="http://gdb.voanews.eu/396754A6-2CE9-45D5-B8B7-9131DAB0E013_mw800_s.jpg"><img border="0" src="/uploads/allimg/120618/2214145N1-0.jpg" alt="" class="photo" style="width: 360px; height: 202px;"></a></div>
        <p><strong><span style="font-size: xx-small;"><span class="imageCaption">Bonnie the cow is milked by Erik Ramfjord, at the Douglas Ranch in Paicines, California </span></span></strong></p>
        <p><span class="firstLetter">N</span>ow, the VOA Special English program WORDS AND THEIR STORIES. <br>
        &nbsp;<br>
        In the early days of human history, people survived by hunting wild  animals, or gathering wild grains and plants for food. Then, some people  learned to grow crops and raise animals for food. They were the first  farmers.<br>
            &nbsp;<br>
        Since the sixteenth century, the word farm has meant agricultural land.  But a much older meaning of the word farm is linked to economics. The  word farm comes from the Latin word, firma, which means an unchanging  payment.<br>
        &nbsp;<br>
        Experts say the earliest meaning of the English word <strong>farm</strong> was a yearly payment made as a tax or rent.<br>
        &nbsp;<br>
        Farmers in early England did not own their land. They paid every year to use agricultural lands.<br>
        &nbsp;<br>
        In England, farmers used hawthorn trees along the edges of property. They called this row of hawthorns a<strong> hedge</strong>.<br>
        &nbsp;<br>
        Hedging fields was how careful farmers marked and protected them.<br>
        &nbsp;<br>
        Soon, people began to use the word <strong>hedging </strong>to describe steps that could be taken to protect against financial loss.<br>
        &nbsp;<br>
        Hedging is common among gamblers who make large bets. A gambler bets a  lot of money on one team. But, to be on the safe side, he also places a  smaller bet on the other team, to reduce a possible loss.<br>
        &nbsp;<br>
        You might say that someone is <strong>hedging his bet</strong> when he invests in several different kinds of businesses. One business may fail, but likely not all.<br>
        &nbsp;<br>
        Farmers know that it is necessary to <strong>make hay while the sun shines</strong>.<br>
            &nbsp;<br>
        Hay has to be cut and gathered when it is dry. So a wise farmer never  postpones gathering his hay when the sun is shining. Rain may soon  appear.<br>
        &nbsp;<br>
        A wise person copies the farmer. He works when conditions are right.<br>
        &nbsp;<br>
        A new mother, for example, quickly learns to try to sleep when her baby  is quiet, even in the middle of the day. If the mother delays, she may  lose her chance to sleep. So, the mother learns to make hay while the  sun shines.<br>
            &nbsp;<br>
        Beans are a popular farm crop. But beans are used to describe something of very little value in the expression, <strong>not worth a hill of beans</strong>. The expression is often used today.<br>
        &nbsp;<br>
        You could say, for example, that a bad idea is not worth a hill of beans.<br>
            &nbsp;<br>
        Language expert Charles Earle Funk said the expression was first used  almost seven hundred years ago. He said Robert of Gloucester described a  message from the King of Germany to King John of England as <strong>altogether not worth a bean</strong>.<br>
        &nbsp;<br>
        (MUSIC)<br>
        &nbsp;<br>
        This VOA Special English program, WORDS AND THEIR STORIES, was written  by Marilyn Rice Christiano. Maurice Joyce was the narrator. I'm Shirley  Griffith.</p>
        
        
        </td></tr>
        </tbody></table>
        </div>
*/
        
        NSRange range = [xmlString rangeOfString:@"<div class=\"content\">"];
        if(range.location != NSNotFound)
        {
            xmlString = [xmlString substringFromIndex:range.location + range.length];
            range = [xmlString rangeOfString:@"<a href=\""];
            if(range.location != NSNotFound)
            {
                xmlString = [xmlString substringFromIndex:range.location + range.length];
                range = [xmlString rangeOfString:@"\""];
                if(range.location != NSNotFound)
                    address = [xmlString substringToIndex:range.location];
                
            }
            
        }

        
        NSRange range1 = [xmlString rangeOfString:@"<p>"];
        if(range1.location != NSNotFound)
        {
            xmlString = [xmlString substringFromIndex:range1.location];
            range1 = [xmlString rangeOfString:@"<!-- /content -->"];
            if(range1.location != NSNotFound)
            {
                text = [xmlString substringToIndex:range1.location];
//                text = [text stringByReplacingOccurrencesOfString:@"&nbsp;<br />" withString:@""];
            }
        }
        
        if([address length])
        {
            Item* item = (Item*)[RCTool insertEntityObjectForID:_objectID
                                           managedObjectContext:insertionContext];
            if(item)
            {
                if([text length])
                {
                    item.text = [self cacheImages:text];
                }
                
                if(NO == [address hasPrefix:@"http"])
                {
                    address = [NSString stringWithFormat:@"%@/%@",BASE_URL,address];
                }
                
                item.address = address;
            }
        }
    }

	
}

- (void)main 
{
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	if (_delegate && [_delegate respondsToSelector:@selector(textImporterDidStart:)]) 
	{
		[_delegate performSelectorOnMainThread:@selector(textImporterDidStart:) 
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
	
	NSLog(@"getTextFrom:%@",_requestUrl);
	
	NSError* error = nil;
	NSData* data = [NSURLConnection sendSynchronousRequest:request 
										 returningResponse:NULL 
													 error:&error];
	
	NSString* xmlString = nil;
	if(data)
	{
		xmlString = [[NSString alloc] initWithData:data 
										  encoding:NSUTF8StringEncoding];
		
		[self parseText: xmlString insertionContext:insertionContext];
		
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
	
	
	if (_delegate && [_delegate respondsToSelector:@selector(textImporterDidFinish:)]) 
	{
		[_delegate performSelectorOnMainThread:@selector(textImporterDidFinish:) 
									withObject:self
								 waitUntilDone:YES];
	}
	
    [pool release];
}





@end
