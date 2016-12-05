//
//  RCTool.m
//  rsscoffee
//
//  Created by beer on 8/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "RCTool.h"
#import <CommonCrypto/CommonDigest.h>
#import "Reachability.h"
#import "TBXML.h"
#import "VOAAppDelegate.h"
#import "RegexKitLite.h"
#import "Item.h"
#import "RegexKitLite.h"
#import "VOACategory.h"
#import "GTMBase64.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import <CommonCrypto/CommonCryptor.h>

static int g_reachabilityType = -1;


@implementation RCTool

+ (BOOL)checkCrackedApp
{
    static BOOL isCraked = NO;
    
    NSBundle *bundle = [NSBundle mainBundle];
	NSDictionary *info = [bundle infoDictionary];
	if ([info objectForKey: @"SignerIdentity"] != nil)//判断是否为破解App,方法可能已过时
	{
		isCraked = YES;
	}
    else//通过检查是否为jailbreak设备来判断是否为破解App
    {
        NSArray *jailbrokenPath = [NSArray arrayWithObjects:
                                   @"/Applications/Cydia.app",
                                   @"/Applications/RockApp.app",
                                   @"/Applications/Icy.app",
                                   @"/usr/sbin/sshd",
                                   @"/usr/bin/sshd",
                                   @"/usr/libexec/sftp-server",
                                   @"/Applications/WinterBoard.app",
                                   @"/Applications/SBSettings.app",
                                   @"/Applications/MxTube.app",
                                   @"/Applications/IntelliScreen.app",
                                   @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
                                   @"/Applications/FakeCarrier.app",
                                   @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
                                   @"/private/var/lib/apt",
                                   @"/Applications/blackra1n.app",
                                   @"/private/var/stash",
                                   @"/private/var/mobile/Library/SBSettings/Themes",
                                   @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
                                   @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
                                   @"/private/var/tmp/cydia.log",
                                   @"/private/var/lib/cydia", nil];
        
        for(NSString *path in jailbrokenPath)
        {
            if ([[NSFileManager defaultManager] fileExistsAtPath:path])
            {
                isCraked = YES;
                break;
            }
        }
        
    }
    
    return isCraked;
}

+ (NSString*)getUserDocumentDirectoryPath
{
	NSArray* array = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
	if([array count])
		return [array objectAtIndex: 0];
	else
		return @"";
}

+ (NSString *)md5:(NSString *)str 
{
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [NSString stringWithFormat:
			@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], 
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15]
			];	
}

+ (UIWindow*)frontWindow
{
	UIApplication *app = [UIApplication sharedApplication];
    NSArray* windows = [app windows];
    
    for(int i = [windows count] - 1; i >= 0; i--)
    {
        UIWindow *frontWindow = [windows objectAtIndex:i];
        //NSLog(@"window class:%@",[frontWindow class]);
//        if(![frontWindow isKindOfClass:[MTStatusBarOverlay class]])
            return frontWindow;
    }
    
	return nil;
}


#pragma mark -
#pragma mark network

+ (void)setReachabilityType:(int)type
{
	g_reachabilityType = type;
}

+ (int)getReachabilityType
{
	return g_reachabilityType;
}

+ (BOOL)isReachableViaInternet
{
	Reachability* internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return YES;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	
	return NO;
}

+ (BOOL)isReachableViaWiFi
{
	Reachability* internetReach = [Reachability reachabilityForInternetConnection];
	[internetReach startNotifier];
	NetworkStatus netStatus = [internetReach currentReachabilityStatus];
	switch (netStatus)
    {
        case NotReachable:
        {
            return NO;
        }
        case ReachableViaWWAN:
        {
            return NO;
        }
        case ReachableViaWiFi:
        {
			return YES;
		}
		default:
			return NO;
	}
	
	return NO;
}

+ (BOOL)saveImage:(NSData*)data path:(NSString*)path
{
	if(nil == data || 0 == [path length])
		return NO;
	
    NSString* suffix = nil;
	NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
	if(range.location != NSNotFound)
		suffix = [path substringFromIndex:range.location + range.length];
	
	NSString* md5Path = [RCTool md5:path];
	NSString* savePath = nil;
    NSString* saveSmallImagePath = nil;
	if([suffix length])
    {
		savePath = [NSString stringWithFormat:@"%@/%@.%@",[RCTool getUserDocumentDirectoryPath],md5Path,suffix];
        
        saveSmallImagePath = [NSString stringWithFormat:@"%@/%@_s.%@",[RCTool getUserDocumentDirectoryPath],md5Path,suffix];
    }
	else
		return NO;
	
	//保存原图
	if(NO == [data writeToFile:savePath atomically:YES])
        return NO;
	
	
	//保存小图
	UIImage* image = [UIImage imageWithData:data];
	if(nil == image)
		return NO;
    
    if(image.size.width <= 140 || image.size.height <= 140)
    {
        return [data writeToFile:saveSmallImagePath atomically:YES];
    }
	
	CGSize size = CGSizeMake(140, 140);
	// 创建一个bitmap的context  
	// 并把它设置成为当前正在使用的context  
	UIGraphicsBeginImageContext(size);  
	
	// 绘制改变大小的图片  
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];  
	
	// 从当前context中创建一个改变大小后的图片  
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();  
	
	// 使当前的context出堆栈  
	UIGraphicsEndImageContext();  
	
	NSData* data2 = UIImagePNGRepresentation(scaledImage);
	if(data2)
    {
		return [data2 writeToFile:saveSmallImagePath atomically:YES];
    }
	
	return YES;
}


+ (UIImage*)getImage:(NSString*)path
{
	if(0 == [path length])
		return nil;
	
	NSString* suffix = nil;
	NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
	if(range.location != NSNotFound)
		suffix = [path substringFromIndex:range.location + range.length];
	
	NSString* md5Path = [RCTool md5:path];
	NSString* savePath = nil;
	if([suffix length])
		savePath = [NSString stringWithFormat:@"%@/%@.%@",[RCTool getUserDocumentDirectoryPath],md5Path,suffix];
	else
		return nil;
	
	return [UIImage imageWithContentsOfFile:savePath];
}

+ (UIImage*)getSmallImage:(NSString*)path
{
	if(0 == [path length])
		return nil;
	
	NSString* suffix = nil;
	NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
	if(range.location != NSNotFound)
		suffix = [path substringFromIndex:range.location + range.length];
	
	NSString* md5Path = [RCTool md5:path];
	NSString* savePath = nil;
	if([suffix length])
		savePath = [NSString stringWithFormat:@"%@/%@_s.%@",[RCTool getUserDocumentDirectoryPath],md5Path,suffix];
	else
		return nil;
	
	return [UIImage imageWithContentsOfFile:savePath];
}

+ (NSString*)getImageLocalPath:(NSString *)path
{
	if(0 == [path length])
		return nil;
	
    NSString* suffix = nil;
	NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
	if(range.location != NSNotFound)
		suffix = [path substringFromIndex:range.location + range.length];
	
	NSString* md5Path = [RCTool md5:path];
	if([suffix length])
		return [NSString stringWithFormat:@"%@/%@.%@",[RCTool getUserDocumentDirectoryPath],md5Path,suffix];
	else
		return nil;
}


+ (NSString*)getSmallImageLocalPath:(NSString *)path
{
	if(0 == [path length])
		return nil;
	
    NSString* suffix = nil;
	NSRange range = [path rangeOfString:@"." options:NSBackwardsSearch];
	if(range.location != NSNotFound)
		suffix = [path substringFromIndex:range.location + range.length];
	
	NSString* md5Path = [RCTool md5:path];
	if([suffix length])
		return [NSString stringWithFormat:@"%@/%@_s.%@",[RCTool getUserDocumentDirectoryPath],md5Path,suffix];
	else
		return nil;
}

+ (BOOL)isExistingFile:(NSString*)path
{
	if(0 == [path length])
		return NO;
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	return [fileManager fileExistsAtPath:path];
}


+ (NSManagedObjectID*)parseFeatured:(NSString*)xmlString requestUrl:(NSString*)requestUrl order:(NSString*)order
{
	if(0 == [xmlString length] || 0 == [requestUrl length])
		return nil;
	
	NSManagedObjectID* categoryObjectID = nil;
	
	TBXML* tbxml = [[TBXML alloc] initWithXMLString:xmlString];
	
	// If TBXML found a root node, process element and iterate all children
	TBXMLElement* rootElement = tbxml.rootXMLElement;
	if (rootElement)
	{
		TBXMLElement* channelElement = [TBXML childElementNamed:@"channel" parentElement:rootElement];
		if(channelElement)
		{
			NSString* idString =  @"";
			TBXMLElement* linkElement = [TBXML childElementNamed:@"link" parentElement:channelElement];
			if(linkElement)
			{
				NSString* link = [TBXML textForElement:linkElement];
				if(0 == [link length])
					link = @"";
				else
				{
					idString = [RCTool md5: link];
				}
				
				if([idString length])
				{
					NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id = %@",idString];
					categoryObjectID = [RCTool getExistingEntityObjectIDForName: @"VOACategory"
                                                                      predicate: predicate
                                                                sortDescriptors: nil
                                                                        context: [RCTool getManagedObjectContext]];
					
					
					VOACategory* category = nil;
					if(nil == categoryObjectID)
					{
						category = [RCTool insertEntityObjectForName:@"VOACategory"
												managedObjectContext:[RCTool getManagedObjectContext]];
						
						category.id = idString;
						
						categoryObjectID = [category objectID];
					}
					else
					{
						category = (VOACategory*)[RCTool insertEntityObjectForID:categoryObjectID
														 managedObjectContext:[RCTool getManagedObjectContext]];
					}
					
					category.link = requestUrl;
					category.order = order;
					
					TBXMLElement* titleElement = [TBXML childElementNamed:@"title" parentElement:channelElement];
					if(titleElement)
					{
						NSString* title = [TBXML textForElement:titleElement];
						if([title length])
						{
							NSRange range = [title rangeOfString:@"VOA News:  " 
														 options:NSCaseInsensitiveSearch];
							if(range.location != NSNotFound)
								category.title = [title substringFromIndex:range.location + range.length];
							else
								category.title = title;
						}
					}
					
					TBXMLElement* pubDateElement = [TBXML childElementNamed:@"pubDate" parentElement:channelElement];
					if(pubDateElement)
					{
						NSString* pubDate = [TBXML textForElement:pubDateElement];
						if([pubDate length])
							category.pubDate = pubDate;
					}
					
					TBXMLElement* itemElement = [TBXML childElementNamed:@"item" parentElement:channelElement];
					if(itemElement)
					{	
						do {
							
							TBXMLElement* temp = [TBXML childElementNamed:@"link" parentElement:itemElement];
							if(temp)
							{
								NSString* link = [TBXML textForElement:temp];
								if([link length])
								{
									NSString* idString = [RCTool md5: link];
									
									if([idString length])
									{
										NSPredicate* predicate = [NSPredicate predicateWithFormat:@"id = %@ && category.id == %@",idString,category.id];
										NSManagedObjectID* objectID = [RCTool getExistingEntityObjectIDForName: @"Item"
																									 predicate: predicate
																							   sortDescriptors: nil
																									   context: [RCTool getManagedObjectContext]];
										
										
										Item* item = nil;
										if(nil == objectID)
										{
											item = [RCTool insertEntityObjectForName:@"Item" 
																managedObjectContext:[RCTool getManagedObjectContext]];
											
											item.id = idString;
										}
										else
										{
											item = (Item*)[RCTool insertEntityObjectForID:objectID
																	 managedObjectContext:[RCTool getManagedObjectContext]];
										}
										
										item.link = link;
										
										temp = [TBXML childElementNamed:@"title" parentElement:itemElement];
										if(temp)
										{
											NSString* title = [TBXML textForElement:temp];
											if([title length])
												item.title = title;
										}
										
										temp = [TBXML childElementNamed:@"description" parentElement:itemElement];
										if(temp)
										{
											NSString* description = [TBXML textForElement:temp];
											if([description length])
												item.itsdescription = description;
										}
										
										temp = [TBXML childElementNamed:@"pubDate" parentElement:itemElement];
										if(temp)
										{
											NSString* pubDate = [TBXML textForElement:temp];
											if([pubDate length])
												item.pubDate = pubDate;
										}
										
										//处理没有发布时期的情况
										if(0 == [item.pubDate length])
										{
											NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
											[dateFormatter setDateFormat:@"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"];
											[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
											NSString* dateString = [dateFormatter stringFromDate:[NSDate date]];
											item.pubDate = dateString;
											[dateFormatter release];
										}	
										
										temp = [TBXML childElementNamed:@"media:group" parentElement:itemElement];
										if(temp)
										{
											temp = [TBXML childElementNamed:@"media:content" parentElement:temp];
											if(temp)
											{
												NSString* imageUrl = [TBXML valueOfAttributeNamed:@"url" 
																					   forElement:temp];
												
												if([imageUrl length])
													item.imageUrl = imageUrl;
											}
										}
										
										[category addItemsObject:item];
									}
								}
							}
                            
							
						} while ((itemElement = itemElement->nextSibling)); 
					}
                    
				}
			}
		}
		
	}
	
	[tbxml release];
	
	return categoryObjectID;
	
}


+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator
{
	VOAAppDelegate* appDelegate = (VOAAppDelegate*)[[UIApplication sharedApplication] delegate];
	return [appDelegate persistentStoreCoordinator];
}

+ (NSManagedObjectContext*)getManagedObjectContext
{
	VOAAppDelegate* appDelegate = (VOAAppDelegate*)[[UIApplication sharedApplication] delegate];
	return [appDelegate managedObjectContext];
}

+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context

{
	if(0 == [entityName length] || nil == context)
		return nil;
	
	//NSManagedObjectContext* context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectIDResultType];
	
	
	//	NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] 
	//															initWithFetchRequest:fetchRequest 
	//															managedObjectContext:context 
	//															sectionNameKeyPath:nil 
	//															cacheName:@"Root"];
	//	
	//	//[context tryLock];
	//	[fetchedResultsController performFetch:nil];
	//	//[context unlock];
	
	NSArray* objectIDs = [context executeFetchRequest:fetchRequest error:nil];
	
	[fetchRequest release];
	
	if(objectIDs && [objectIDs count])
		return [objectIDs lastObject];
	else
		return nil;
}

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors
{
	if(0 == [entityName length])
		return nil;
	
	NSManagedObjectContext* context = [RCTool getManagedObjectContext];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:entityName
											  inManagedObjectContext:context];
	[fetchRequest setEntity:entity];
	
	
	//sortDescriptors 是必传属性
	NSArray *temp = [NSArray arrayWithArray: sortDescriptors];
	[fetchRequest setSortDescriptors:temp];
	
	
	//set predicate
	[fetchRequest setPredicate:predicate];
	
	//设置返回类型
	[fetchRequest setResultType:NSManagedObjectResultType];
	
	NSArray* objects = [context executeFetchRequest:fetchRequest error:nil];
	
	[fetchRequest release];
	
	return objects;
}

+ (id)insertEntityObjectForName:(NSString*)entityName 
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(0 == [entityName length] || nil == managedObjectContext)
		return nil;
	
	NSManagedObjectContext* context = managedObjectContext;
	id entityObject = [NSEntityDescription insertNewObjectForEntityForName:entityName 
													inManagedObjectContext:context];
	
	
	return entityObject;
	
}

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID 
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;
{
	if(nil == objectID || nil == managedObjectContext)
		return nil;
	
	return [managedObjectContext objectWithID:objectID];
}

+ (NSDate*)getDateByString:(NSString*)dateString
{
	if(0 == [dateString length])
		return nil;
	
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-d HH':'mm':'ss"];
    //	[dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
    //	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+8"]];
	NSDate* date = [dateFormatter dateFromString:dateString];
	[dateFormatter release];
	
	return date;
}


+ (NSString*)getFilePathByUrl:(NSString*)urlString
{
	if(0 == [urlString length])
		return nil;
	
	return [NSString stringWithFormat:@"%@/%@.mp3",[RCTool getUserDocumentDirectoryPath],[RCTool md5:urlString]];
}

+ (void)deleteFileByUrl:(NSString*)urlString
{
	if(0 == [urlString length])
		return;
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	NSString* filePath = [RCTool getFilePathByUrl:urlString];
	if(0 == [filePath length])
		return;
	
	[fileManager removeItemAtPath:filePath error:nil];
	
}

+ (NSString*)getLocalImageUrl:(NSString*)url
{
	if(0 == [url length])
		return @"";
	NSRange range = [url rangeOfString:@"." options:NSBackwardsSearch];
	if(NSNotFound == range.location)
		return @"";
	
	NSString* suffix = [url substringFromIndex:range.location];
	
	return [NSString stringWithFormat:@"%@/%@%@",[RCTool getUserDocumentDirectoryPath],[RCTool md5:url],suffix];
}

+ (void)saveCoreData
{
	VOAAppDelegate* appDelegate = (VOAAppDelegate*)[[UIApplication sharedApplication] delegate];
	NSError *error = nil;
    if ([appDelegate managedObjectContext] != nil) 
	{
        if ([[appDelegate managedObjectContext] hasChanges] && ![[appDelegate managedObjectContext] save:&error]) 
		{
            
        } 
    }
}

+ (NSString*)getColorText:(NSString*)text
{
	if(0 == [text length])
		return @"";
	
	text = [text stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
	text = [text stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
	text = [text stringByReplacingOccurrencesOfString:@" " withString:@" "];
	
	//处理（MUSIC:*),(SOUND)
	NSString *regEx = @"\\(MUSIC.*\\)(.?)"; 
	NSArray* array = [text componentsMatchedByRegex:regEx];
	for(NSString* temp in array)
	{
		temp = [temp substringToIndex:[temp length] - 1];
		NSString* temp2 = [temp stringByReplacingOccurrencesOfString:@"\"" withString:@""];
		//NSLog(@"temp:%@",temp2);
		text = [text stringByReplacingOccurrencesOfString:temp withString:[NSString stringWithFormat:@"<font color=\"#743e1c\" size=4 >%@</font>",temp2]];
	}
	
	
	//处理IN THE NEWS
	text = [text stringByReplacingOccurrencesOfString:@"IN THE NEWS" withString:@"<font color=\"#a5acb0\" face=\"Helvetica-Oblique\" size=4 >IN THE NEWS</font>"];
	
	//处理VOA Special English
	text = [text stringByReplacingOccurrencesOfString:@"VOA Special English" withString:@"<font color=\"#502d7f\" face=\"Helvetica-Oblique\" size=4 >VOA Special English</font>"];
	
	//处理VOICE ONE,VOICE TWO
	text = [text stringByReplacingOccurrencesOfString:@"VOICE ONE:" withString:@"<font color=\"#09511d\" size=4>VOICE ONE:</font>"];
	text = [text stringByReplacingOccurrencesOfString:@"VOICE TWO:" withString:@"<font color=\"#e98617\" size=4>VOICE TWO:</font>"];
	
	//处理VOICE ONE,VOICE TWO
	text = [text stringByReplacingOccurrencesOfString:@"VOICE ONE:" withString:@"<font color=\"#09511d\" size=4>VOICE ONE:</font>"];
	text = [text stringByReplacingOccurrencesOfString:@"VOICE TWO:" withString:@"<font color=\"#e98617\" size=4>VOICE TWO:</font>"];
	
	//处理STEVE EMBER,SHIRLEY GRIFFITH
	text = [text stringByReplacingOccurrencesOfString:@"STEVE EMBER:" withString:@"<font color=\"#09511d\" size=4>STEVE EMBER:</font>"];
	text = [text stringByReplacingOccurrencesOfString:@"SHIRLEY GRIFFITH:" withString:@"<font color=\"#e98617\" size=4>SHIRLEY GRIFFITH:</font>"];
	
	//处理BOB DOUGHTY,FAITH LAPIDUS
	text = [text stringByReplacingOccurrencesOfString:@"BOB DOUGHTY:" withString:@"<font color=\"#09511d\" size=4>BOB DOUGHTY:</font>"];
	text = [text stringByReplacingOccurrencesOfString:@"FAITH LAPIDUS:" withString:@"<font color=\"#e98617\" size=4>FAITH LAPIDUS:</font>"];
	
	//处理DOUNG JOHNSON,SHIRLEY GRIFFITH
	text = [text stringByReplacingOccurrencesOfString:@"DOUG JOHNSON:" withString:@"<font color=\"#09511d\" size=4>DOUG JOHNSON:</font>"];
	//text = [text stringByReplacingOccurrencesOfString:@"SHIRLEY GRIFFITH:" withString:@"<font color=\"#fbbc2f\" size=4>SHIRLEY GRIFFITH:</font>"];
	
	//处理STEVE EMBER,BARBARA KLEIN
	//text = [text stringByReplacingOccurrencesOfString:@"DOUG JOHNSON:" withString:@"<font color=\"#09511d\" size=4>DOUG JOHNSON:</font>"];
	text = [text stringByReplacingOccurrencesOfString:@"BARBARA KLEIN:" withString:@"<font color=\"#e98617\" size=4>BARBARA KLEIN:</font>"];
	
	//处理"*"
	regEx = @":[^/=#]*\"[^/=#]*\"(.?)"; 
	array = [text componentsMatchedByRegex:regEx];
	for(NSString* temp in array)
	{
		temp = [temp substringToIndex:[temp length] - 1];
		temp = [temp substringFromIndex:1];
		//NSLog(@"temp2:%@",temp);
		text = [text stringByReplacingOccurrencesOfString:temp 
											   withString:
				[NSString stringWithFormat:@"<font color=\"#8b1221\" face=\"Helvetica-Oblique\">%@</font>",temp]];
	}
	
	return text;
}

+ (BOOL)isNeedHandleItem:(Item*)item
{	
    //	if([item.isCachedImages boolValue])
    //		return NO;
	
	if([item.isHidden boolValue] || ([item.address length] && [item.text length]))
		return NO;
	
	return YES;
}

+ (BOOL)isBigFont
{
	NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
	NSNumber* b = [temp objectForKey:@"bigFont"];
	if(b)
        return [b boolValue];
	
	return NO;
}

+ (BOOL)isAutoScroll
{
	NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
	NSNumber* b = [temp objectForKey:@"autoScroll"];
	if(b)
		return [b boolValue];
	
	return YES;
}

+ (BOOL)isManualRefresh
{
	NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
	NSNumber* b = [temp objectForKey:@"manualRefresh"];
	if(b)
		return [b boolValue];
	
	return NO;
}

+ (BOOL)isWifiOnly
{
	NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
	NSNumber* b = [temp objectForKey:@"wifiOnly"];
	if(b)
		return [b boolValue];
	
	return NO;
}

+ (BOOL)isImageUrl:(NSString*)urlString
{
	NSRange range = [urlString rangeOfString:@"." options:NSBackwardsSearch];
	if(NSNotFound == range.location)
		return NO;
	
	NSString* suffix = [urlString substringFromIndex:range.location];
	BOOL isValid = NO;
	if(NSOrderedSame == [suffix compare:@".png" options:NSCaseInsensitiveSearch])
		isValid = YES;
	if(NSOrderedSame == [suffix compare:@".bmp" options:NSCaseInsensitiveSearch])
		isValid = YES;
	else if(NSOrderedSame == [suffix compare:@".jpeg" options:NSCaseInsensitiveSearch])
		isValid = YES;
	else if(NSOrderedSame == [suffix compare:@".jpg" options:NSCaseInsensitiveSearch])
		isValid = YES;
	else if(NSOrderedSame == [suffix compare:@".ico" options:NSCaseInsensitiveSearch])
		isValid = YES;
	else if(NSOrderedSame == [suffix compare:@".gif" options:NSCaseInsensitiveSearch])
		isValid = YES;
	
	return isValid;
}

+ (void)adjustAD:(CGFloat)offset_y
{
//	VOAAppDelegate* appDelegate = (VOAAppDelegate*)[UIApplication sharedApplication].delegate;
//	
//	if(appDelegate._iAdBannerView)
//	{
//		CGRect rect = appDelegate._iAdBannerView.frame;
//		rect.origin.y = offset_y;
//		appDelegate._iAdBannerView.frame = rect;
//	}
//	
////	if(appDelegate._bannerView)
////	{
////		CGRect rect = appDelegate._bannerView.frame;
////		rect.origin.y = offset_y;
////		appDelegate._bannerView.frame = rect;
////	}
}

+ (void)autoDeleteItems
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* temp = [userDefaults objectForKey:@"autoDeleteItems_30"];
    if(temp && NO == [temp boolValue])
        return;
    
    NSManagedObjectContext* context = [RCTool getManagedObjectContext];
    
    NSArray* array = [RCTool getExistingEntityObjectsForName: @"VOACategory"
                                                   predicate: nil
                                             sortDescriptors: nil];
    
    for(NSManagedObject* object in array)
    {
        [context deleteObject:object];
    }
    
    array = [RCTool getExistingEntityObjectsForName: @"Item"
                                          predicate: nil
                                    sortDescriptors: nil];
    
    for(NSManagedObject* object in array)
    {
        [context deleteObject:object];
    }
    
    [RCTool saveCoreData];
    
    
    [userDefaults setObject:[NSNumber numberWithBool:NO] forKey:@"autoDeleteItems_30"];
    [userDefaults synchronize];
    
}


/**
 显示提示筐
 */
+ (void)showAlert:(NSString*)aTitle message:(NSString*)message
{
	if(0 == [aTitle length] || 0 == [message length])
		return;
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: aTitle
													message: message
												   delegate: self
										  cancelButtonTitle: @"OK"
										  otherButtonTitles: nil];
    alert.tag = 110;
	[alert show];
	[alert release];
	
    
}

/**
 隐藏UIWebView拖拽时顶部的阴影效果
 */
+ (void)hidenWebViewShadow:(UIWebView*)webView
{
    if(nil == webView)
        return;
    
    if ([[webView subviews] count])
    {
        for (UIView* shadowView in [[[webView subviews] objectAtIndex:0] subviews])
        {
            [shadowView setHidden:YES];
        }
        
        // unhide the last view so it is visible again because it has the content
        [[[[[webView subviews] objectAtIndex:0] subviews] lastObject] setHidden:NO];
    }
}

+ (void)deleteOldData
{
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"isFavorited == NO && isDownloaded == NO && isHidden == NO"];
    
	NSArray* array = [RCTool getExistingEntityObjectsForName:@"Item"
                                                   predicate:predicate
                                             sortDescriptors:nil
                                           ];
    
    for(Item* item in array)
    {
        NSString* pubDate = item.pubDate;
        if([pubDate length])
        {
            NSDate* date = [RCTool getDateByString:pubDate];
            NSDate* today = [NSDate date];
            if([today timeIntervalSinceDate:date] <= 3*7*24*60*60)
                continue;
            
        }
        
        item.isHidden = [NSNumber numberWithBool:YES];
    }
    
    [RCTool saveCoreData];
}


+ (NSString*)voicePathOfWord:(NSString*)word
{
    if(0 == [word length])
        return nil;
    
    NSString* md5Path = [RCTool md5:word];
	if([md5Path length])
	{
		return [NSString stringWithFormat:@"%@/voices/%@.mp3",
                [RCTool getUserDocumentDirectoryPath],md5Path];
	}
    
    return nil;
}

+ (void)saveVoice:(NSString*)word data:(NSData*)data
{
    if(nil == data || 0 == [word length])
		return;
    
    NSString* directoryPath = [NSString stringWithFormat:@"%@/voices",[RCTool getUserDocumentDirectoryPath]];
    if(NO == [RCTool isExistingFile:directoryPath])
    {
        NSFileManager* fileManager = [NSFileManager defaultManager];
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:NULL];
    }
	
	NSString* md5Path = [RCTool md5:word];
	NSString* savePath = nil;
	if([md5Path length])
		savePath = [NSString stringWithFormat:@"%@/voices/%@.mp3",[RCTool getUserDocumentDirectoryPath],md5Path];
	else
		return;
	
	[data writeToFile:savePath atomically:YES];
}

#pragma mark - 兼容iOS6和iPhone5

+ (CGSize)getScreenSize
{
    return [[UIScreen mainScreen] bounds].size;
}

+ (CGRect)getScreenRect
{
    return [[UIScreen mainScreen] bounds];
}

+ (BOOL)isIphone5
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize size = [[UIScreen mainScreen] bounds].size;
        if(568 == size.height)
        {
            return YES;
        }
    }
    
    return NO;
}

+ (CGFloat)systemVersion
{
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    return systemVersion;
}

+ (void)showInterstitialAd
{
//    VOAAppDelegate* appDelegate =(VOAAppDelegate*)[UIApplication sharedApplication].delegate;
//    [appDelegate showInterstitialAd];
}

#pragma mark - App Info

+ (NSString*)getAdId
{
//    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
//    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
//    {
//        NSString* ad_id = [app_info objectForKey:@"ad_id"];
//        if([ad_id length])
//            return ad_id;
//    }
    
    return AD_ID;
}

+ (NSString*)getScreenAdId
{
//    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
//    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
//    {
//        NSString* ad_id = [app_info objectForKey:@"mediation_id"];
//        if(0 == [ad_id length])
//            ad_id = [app_info objectForKey:@"screen_ad_id"];
//        
//        if([ad_id length])
//            return ad_id;
//    }
    
    return SCREEN_AD_ID;
}

+ (int)getScreenAdRate
{
//    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
//    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
//    {
//        NSString* ad_rate = [app_info objectForKey:@"screen_ad_rate"];
//        if([ad_rate intValue] > 0)
//            return [ad_rate intValue];
//    }
    
    return SCREEN_AD_RATE;
}

+ (NSString*)getAppURL
{
//    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
//    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
//    {
//        NSString* link = [app_info objectForKey:@"link"];
//        if([link length])
//            return link;
//    }
    
    return APP_URL;
}

+ (BOOL)isOpenAll
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSString* openall = [app_info objectForKey:@"openall"];
        if([openall isEqualToString:@"1"])
            return YES;
    }
    
    return NO;
}

+ (UIView*)getAdView
{
    VOAAppDelegate* appDelegate = (VOAAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if(appDelegate.adMobAd.alpha)
    {
        UIView* adView = appDelegate.adMobAd;
        if(adView)
            return adView;
    }
    
    return nil;
}

+ (NSString*)decryptUseDES:(NSString*)cipherText key:(NSString*)key {
    // 利用 GTMBase64 解碼 Base64 字串
    NSData* cipherData = [GTMBase64 decodeString:cipherText];
    unsigned char buffer[4096*100];
    memset(buffer, 0, sizeof(char));
    size_t numBytesDecrypted = 0;
    
    // IV 偏移量不需使用
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [cipherData bytes],
                                          [cipherData length],
                                          buffer,
                                          4096*100,
                                          &numBytesDecrypted);
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesDecrypted];
        plainText = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return plainText;
}

+ (NSString *)encryptUseDES:(NSString *)clearText key:(NSString *)key
{
    NSData *data = [clearText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    unsigned char buffer[4096];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          4096,
                                          &numBytesEncrypted);
    
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *dataTemp = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        plainText = [GTMBase64 stringByEncodingData:dataTemp];
    }else{
        NSLog(@"DES加密失败");
    }
    return plainText;
}

+ (NSString*)decrypt:(NSString*)text
{
    if(0 == [text length])
        return @"";
    
    NSString* key = SECRET_KEY;
    NSString* encrypt = text;
    NSString* decrypt = [RCTool decryptUseDES:encrypt key:key];
    
    if([decrypt length])
        return decrypt;
    
    return @"";
}

+ (NSString*)getTextById:(NSString*)textId
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* text_dict = [app_info objectForKey:@"text_dict"];
        if([text_dict isKindOfClass:[NSDictionary class]])
        {
            if([RCTool isOpenAll])
            {
                NSString* text = [text_dict objectForKey:textId];
                if([text length])
                    return text;
            }
        }
    }
    
    if([textId isEqualToString:@"ti_0"])
    {
        return @"设置";
    }
    else if([textId isEqualToString:@"ti_1"])
    {
        return @"精品应用推荐";
    }
    else if([textId isEqualToString:@"ti_2"])
    {
        return @"点击清除缓存";
    }
    else if([textId isEqualToString:@"ti_3"])
    {
        return @"去评价";
    }
    else if([textId isEqualToString:@"ti_4"])
    {
        return @"意见反馈";
    }
    else if([textId isEqualToString:@"ti_5"])
    {
        return @"缓存已成功清除";
    }
    else if([textId isEqualToString:@"ti_6"])
    {
        return @"下拉可以刷新了";
    }
    else if([textId isEqualToString:@"ti_7"])
    {
        return @"松开马上刷新了";
    }
    else if([textId isEqualToString:@"ti_8"])
    {
        return @"正在帮你刷新中...";
    }
    else if([textId isEqualToString:@"ti_9"])
    {
        return @"上拉可以加载更多数据了";
    }
    else if([textId isEqualToString:@"ti_10"])
    {
        return @"松开马上加载更多数据了";
    }
    else if([textId isEqualToString:@"ti_11"])
    {
        return @"正在帮你加载中...";
    }
    
    return @"";
}

+ (NSArray*)getOtherApps
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        return [app_info objectForKey:@"other_apps"];
    }
    
    return nil;
}

+ (NSDictionary*)getAlert
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* dict = [app_info objectForKey:@"alert"];
        if(dict && [dict isKindOfClass:[NSDictionary class]])
            return dict;
    }
    
    return nil;
}

+ (NSString*)getUrlByType:(int)type
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* info = [app_info objectForKey:[NSString stringWithFormat:@"url_info_%d",type]];
        if(info && [info isKindOfClass:[NSDictionary class]])
        {
            return [info objectForKey:@"url"];
        }
    }
    
    if(0 == type)
    {
        return URL_0;
    }
    else if(1 == type)
    {
        return URL_1;
    }
    else if(2 == type)
    {
        return URL_2;
    }
    else if(3 == type)
    {
        return URL_3;
    }
    
    return @"";
}

+ (BOOL)isEncrypted:(int)type
{
    NSDictionary* app_info = [[NSUserDefaults standardUserDefaults] objectForKey:@"app_info"];
    
    if(app_info && [app_info isKindOfClass:[NSDictionary class]])
    {
        NSDictionary* info = [app_info objectForKey:[NSString stringWithFormat:@"url_info_%d",type]];
        if(info && [info isKindOfClass:[NSDictionary class]])
        {
            return [[info objectForKey:@"isen"] isEqualToString:@"1"];
        }
    }
    
    return YES;
}


#pragma mark -

+ (NSDictionary*)parseToDictionary:(NSString*)jsonString
{
    if(0 == [jsonString length])
        return nil;
    
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if(nil == data)
        return nil;
    
    NSError* error = nil;
    NSJSONSerialization* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if(error)
    {
        NSLog(@"parse errror:%@",[error localizedDescription]);
        return nil;
    }
    
    if([json isKindOfClass:[NSDictionary class]])
    {
        return (NSDictionary *)json;
    }
    
    return nil;
}

+ (int)tryToShowScreenAdTimes
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    NSNumber* b = [temp objectForKey:@"tryToShowScreenAdTimes"];
    if(b)
        return [b intValue];
    
    return 0;
}

+ (void)setTryToShowScreenAdTimes:(int)times
{
    NSUserDefaults* temp = [NSUserDefaults standardUserDefaults];
    [temp setObject:[NSNumber numberWithInt:times] forKey:@"tryToShowScreenAdTimes"];
    [temp synchronize];
}

+ (UIImage *)imageWithImage:(UIImage *)image
               scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
