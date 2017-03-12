//
//  RCTool.h
//  rsscoffee
//
//  Created by beer on 8/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Item;
@interface RCTool : NSObject {

}

+ (BOOL)checkCrackedApp;
+ (NSString*)getUserDocumentDirectoryPath;
+ (NSString *)md5:(NSString *)str;
+ (UIWindow*)frontWindow;

+ (BOOL)saveImage:(NSData*)data path:(NSString*)path;
+ (NSString*)getImageLocalPath:(NSString *)path;
+ (NSString*)getSmallImageLocalPath:(NSString *)path;
+ (UIImage*)getImage:(NSString*)path;
+ (UIImage*)getSmallImage:(NSString*)path;
+ (BOOL)isExistingFile:(NSString*)path;

+ (void)setReachabilityType:(int)type;
+ (int)getReachabilityType;
+ (BOOL)isReachableViaWiFi;
+ (BOOL)isReachableViaInternet;

+ (NSManagedObjectID*)parseFeatured:(NSString*)xmlString requestUrl:(NSString*)requestUrl order:(NSString*)order;

+ (NSPersistentStoreCoordinator*)getPersistentStoreCoordinator;
+ (NSManagedObjectContext*)getManagedObjectContext;
+ (NSManagedObjectID*)getExistingEntityObjectIDForName:(NSString*)entityName
											 predicate:(NSPredicate*)predicate
									   sortDescriptors:(NSArray*)sortDescriptors
											   context:(NSManagedObjectContext*)context;

+ (NSArray*)getExistingEntityObjectsForName:(NSString*)entityName
								  predicate:(NSPredicate*)predicate
							sortDescriptors:(NSArray*)sortDescriptors;

+ (id)insertEntityObjectForName:(NSString*)entityName 
		   managedObjectContext:(NSManagedObjectContext*)managedObjectContext;

+ (id)insertEntityObjectForID:(NSManagedObjectID*)objectID 
		 managedObjectContext:(NSManagedObjectContext*)managedObjectContext;


+ (NSDate*)getDateByString:(NSString*)dateString;

+ (NSString*)getFilePathByUrl:(NSString*)urlString;

+ (void)deleteFileByUrl:(NSString*)urlString;

+ (NSString*)getLocalImageUrl:(NSString*)url;

+ (void)saveCoreData;

+ (NSString*)getColorText:(NSString*)text;

+ (BOOL)isNeedHandleItem:(Item*)item;

+ (BOOL)isBigFont;
+ (BOOL)isAutoScroll;
+ (BOOL)isManualRefresh;
+ (BOOL)isWifiOnly;

+ (BOOL)isImageUrl:(NSString*)urlString;

+ (void)autoDeleteItems;

+ (void)showAlert:(NSString*)aTitle message:(NSString*)message;
+ (void)hidenWebViewShadow:(UIWebView*)webView;

+ (void)deleteOldData;

#pragma mark - 单词发音文件相关方法
/**
 单词发音文件本地保存路径
 */
+ (NSString*)voicePathOfWord:(NSString*)word;

/**
 保存单词发音文件到本地
 */
+ (void)saveVoice:(NSString*)word data:(NSData*)data;

#pragma mark - 兼容iOS6和iPhone5

+ (CGSize)getScreenSize;

+ (CGRect)getScreenRect;

+ (BOOL)isIpad;

+ (CGFloat)systemVersion;

+ (void)showInterstitialAd;

#pragma mark - App Info

+ (NSString*)getAdId;
+ (NSString*)getScreenAdId;
+ (int)getScreenAdRate;
+ (NSString*)getAppURL;
+ (BOOL)isOpenAll;
+ (UIView*)getAdView;
+ (NSString*)decrypt:(NSString*)text;
+ (NSString*)getTextById:(NSString*)textId;
+ (NSArray*)getOtherApps;
+ (NSDictionary*)getAlert;
+ (NSString*)getUrlByType:(int)type;

#pragma mark -
+ (NSDictionary*)parseToDictionary:(NSString*)jsonString;
+ (int)tryToShowScreenAdTimes;
+ (void)setTryToShowScreenAdTimes:(int)times;

@end
