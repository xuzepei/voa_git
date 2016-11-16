//
//  VOAAppDelegate.m
//  VOA
//
//  Created by xuzepei on 6/16/10.
//  Copyright Rumtel Co.,Ltd 2010. All rights reserved.
//

#import "VOAAppDelegate.h"
#import "WRSysTabBarController.h"
#import "VOACategoriesViewController.h"
#import "VOAVocabularyViewController.h"
#import "VOAFavoritesViewController.h"
#import "VOADownloadViewController.h"
#import "RCTool.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VOASettingViewController.h"
#import "RCHttpRequest2.h"

#define APP_ALERT 111
#define RATE_ALERT 112

@interface VOAAppDelegate (PrivateCoreDataStack)
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@end


@implementation VOAAppDelegate

@synthesize window;
@synthesize _tabBarController;

@synthesize _categoriesViewController;
@synthesize _categoriesNavigationController;

@synthesize _vocabularyViewController;
@synthesize _vocabularyNavigationController;

@synthesize _favoritesViewController;
@synthesize _favoritesNavigationController;

@synthesize _downloadViewController;
@synthesize _downloadNavigationController;

@synthesize _settingViewController;
@synthesize _settingNavigationController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    UIApplication* app = [UIApplication sharedApplication];
	app.applicationIconBadgeNumber = 0;
	[app registerForRemoteNotificationTypes:
	 (UIRemoteNotificationType)(UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeSound)];
	
	// set the software codec too on the queue.
    //	UInt32 val = kAudioQueueHardwareCodecPolicy_PreferSoftware;
    //	AudioQueueRef audioQueue;
    //	AudioQueueSetProperty(audioQueue, kAudioQueueProperty_HardwareCodecPolicy, &val, sizeof(val));
    //	AudioQueueStart(audioQueue, NULL);
	
    //清除旧数据
    [RCTool autoDeleteItems];
	
	//分类
	_categoriesViewController = [[VOACategoriesViewController alloc] initWithNibName:@"VOACategoriesViewController" 
                                                                              bundle:nil];
	
	_categoriesNavigationController = [[UINavigationController alloc] 
                                       initWithRootViewController:_categoriesViewController];
    _categoriesNavigationController.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
	
	//词汇表
//	_vocabularyViewController = [[VOAVocabularyViewController alloc] initWithNibName:@"VOAVocabularyViewController" 
//                                                                              bundle:nil];
//	
//	_vocabularyNavigationController = [[UINavigationController alloc] 
//                                       initWithRootViewController:_vocabularyViewController];
//    _vocabularyNavigationController.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
    
	
	//收藏
	_favoritesViewController = [[VOAFavoritesViewController alloc] initWithNibName:@"VOAFavoritesViewController" 
                                                                            bundle:nil];
	
	_favoritesNavigationController = [[UINavigationController alloc] 
                                      initWithRootViewController:_favoritesViewController];
    _favoritesNavigationController.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
	
	
	//下载
	_downloadViewController = [[VOADownloadViewController alloc] initWithNibName:@"VOADownloadViewController" 
                                                                          bundle:nil];
	
	_downloadNavigationController = [[UINavigationController alloc] 
                                     initWithRootViewController:_downloadViewController];
    
    _downloadNavigationController.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
	
	//设置
	_settingViewController = [[VOASettingViewController alloc] initWithNibName:@"VOASettingViewController" 
																		bundle:nil];
	
	_settingNavigationController = [[UINavigationController alloc] 
									initWithRootViewController:_settingViewController];
    _settingNavigationController.navigationBar.tintColor = NAVIGATION_BAR_COLOR;
	
	
	_tabBarController = [[WRSysTabBarController alloc] initWithNibName:@"WRSysTabBarController" 
																bundle:nil];
    
    NSArray* array = [[NSArray alloc] initWithObjects:
                      _categoriesNavigationController,
                      _favoritesNavigationController,
                      _downloadNavigationController,
                      _settingNavigationController,nil];
    
	
	[_tabBarController setViewControllers:array animated:YES];
	[array release];
	
    //[window addSubview:_tabBarController.view];
    //iOS6中最好这样写
    self.window.rootViewController = _tabBarController;
    [window makeKeyAndVisible];
    
    
    [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
	
    return YES;
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error = nil;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
    //推送设置
    UIApplication* app = [UIApplication sharedApplication];
	app.applicationIconBadgeNumber = 0;
    
	
//	//解决重启后无声音或声音小的问题
//	AudioSessionInitialize(NULL, NULL, NULL, NULL);
//	UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
//	OSStatus err = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
//										   sizeof(sessionCategory),
//										   &sessionCategory);
//	AudioSessionSetActive(TRUE);
//	if (err) {
//		NSLog(@"AudioSessionSetProperty kAudioSessionProperty_AudioCategory failed: %d", err);
//	}
	
	if(_categoriesViewController)
	{
		if(NO == [RCTool isManualRefresh])
         [_categoriesViewController updateContent];
	}
    
    self.showFullScreenAd = YES;
    [self getAppInfo];
	
}

#pragma mark -
#pragma mark multitaskingSupported

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //AudioSessionInitialize (NULL, NULL, NULL, self);
//    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
//    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,sizeof(sessionCategory),&sessionCategory);
//    AudioSessionSetActive(true);
    
    //    if(NO == [WRTool hasHeadPhone])
    //    {
    //        NSLog(@"no headphone");
    //        UInt32 audioRouteOverride = kAudioSessionOverrideAudioRoute_Speaker;
    //        AudioSessionSetProperty (kAudioSessionProperty_OverrideAudioRoute,sizeof (audioRouteOverride),&audioRouteOverride);
    //        //[[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //    }
	
//    UIApplication* app = [UIApplication sharedApplication]; 
//    _bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:_bgTask];
//        _bgTask = UIBackgroundTaskInvalid;
//    }];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        [app endBackgroundTask:_bgTask];
//        _bgTask = UIBackgroundTaskInvalid;
//    });
//    
//    
//#if TARGET_IPHONE_SIMULATOR
//	NSLog(@"The iPhone simulator does not process background network traffic. "
//          @"Inbound traffic is queued until the keepAliveTimeout:handler: fires.");
//#endif
//    
//	if ([application respondsToSelector:@selector(setKeepAliveTimeout:handler:)]) 
//	{
//		[application setKeepAliveTimeout:600 handler:^{
//			
//			NSLog(@"KeepAliveHandler");
//			
//			// Do other keep alive stuff here.
//		}];
//	}
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"VOA.sqlite"]];
	
	
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
							 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
							 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible
         * The schema for the persistent store is incompatible with current managed object model
         Check the error message to determine what the actual problem was.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	
	[_categoriesViewController release];
	[_categoriesNavigationController release];
	
	[_vocabularyViewController release];
	[_vocabularyNavigationController release];
	
	[_favoritesViewController release];
	[_favoritesNavigationController release];
	
	[_downloadViewController release];
	[_downloadNavigationController release];
	
	[_settingViewController release];
	[_settingNavigationController release];
    
    [_tabBarController release];
    [window release];
    
    self.ad_id = nil;
    self.adMobAd = nil;
    self.adInterstitial = nil;
    
    [super dealloc];
}


#pragma mark - AdMob

- (void)getAppInfo
{
    NSString* urlString = APP_INFO_URL;
    
    RCHttpRequest2* temp = [RCHttpRequest2 sharedInstance];
    [temp request:urlString delegate:self resultSelector:@selector(finishedGetAppInfoRequest:) token:nil];
}

- (void)finishedGetAppInfoRequest:(NSString*)jsonString
{
    if(0 == [jsonString length])
    {
        self.ad_id = [RCTool getAdId];
        
        [self getAD];
        
        return;
    }
    
    [self rate];
    
    NSDictionary* result = [RCTool parseToDictionary:[RCTool decrypt:jsonString]];
    if(result && [result isKindOfClass:[NSDictionary class]])
    {
        //保存用户信息
        [[NSUserDefaults standardUserDefaults] setObject:result forKey:@"app_info"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self doAlert];
        
        self.ad_id = [RCTool getAdId];
        
        [self getAD];
    }
    
}

- (void)initAdMob
{
    if(_adMobAd && nil == _adMobAd.superview)
    {
        [_adMobAd removeFromSuperview];
        _adMobAd.delegate = nil;
        _adMobAd = nil;
    }
    
    _adMobAd = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
    _adMobAd.adUnitID = [RCTool getAdId];
    _adMobAd.delegate = self;
    _adMobAd.alpha = 0.0;
    _adMobAd.rootViewController = self.window.rootViewController;
    [_adMobAd loadRequest:[GADRequest request]];
    
}

- (void)getAD
{
    NSLog(@"getAD");
    
    if(self.adMobAd && self.adMobAd.superview)
    {
        [self.adMobAd removeFromSuperview];
        self.adMobAd = nil;
    }
    
    self.adInterstitial = nil;
    
    [self initAdMob];
}

#pragma mark -
#pragma mark GADBannerDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    NSLog(@"adViewDidReceiveAd");
    
    if(nil == _adMobAd.superview && _adMobAd.alpha == 0.0)
    {
        _adMobAd.alpha = 1.0;
        CGRect rect = _adMobAd.frame;
        rect.origin.x = ([RCTool getScreenSize].width - rect.size.width)/2.0;
        _adMobAd.frame = rect;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_ADBANNER_NOTIFICATION object:nil userInfo:nil];
}

- (void)adView:(GADBannerView *)bannerView
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"didFailToReceiveAdWithError");
    
    [self performSelector:@selector(initAdMob) withObject:nil afterDelay:10];
}

- (void)getAdInterstitial
{
    [RCTool setTryToShowScreenAdTimes:[RCTool tryToShowScreenAdTimes] + 1];
    
    if([RCTool tryToShowScreenAdTimes] <= [RCTool getScreenAdRate])
        return;
    
    if(nil == _adInterstitial)
    {
        _adInterstitial = [[GADInterstitial alloc] initWithAdUnitID:[RCTool getScreenAdId]];
        _adInterstitial.delegate = self;
    }
    
    [_adInterstitial loadRequest:[GADRequest request]];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    NSLog(@"interstitialDidReceiveAd");
    
    //    if(self.showFullScreenAd)
    //    {
    //        self.showFullScreenAd = NO;
    //
    //        [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_FULLSCREENAD_NOTIFICATION object:nil userInfo:nil];
    //    }
    
    if(interstitial.isReady)
    {
        [RCTool setTryToShowScreenAdTimes:0];
        [interstitial presentFromRootViewController:self.window.rootViewController];
    }
    
}

- (void)interstitial:(GADInterstitial *)ad
didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"%s",__FUNCTION__);
    
    //[self performSelector:@selector(getAdInterstitial) withObject:nil afterDelay:10];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    self.adInterstitial = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_ADBANNER_NOTIFICATION object:nil userInfo:nil];
    //    [self getAdInterstitial];
}

- (void)showInterstitialAd:(UIViewController*)rootViewController
{
    if(_adInterstitial.isReady)
    {
        [_adInterstitial presentFromRootViewController:rootViewController];
    }
}

#pragma mark - Push Notification

- (void)sendProviderDeviceToken:(NSData*)devToken
{
    if(nil == devToken)
        return;
    
    NSString* temp = [devToken description];
    NSString* token = [temp stringByTrimmingCharactersInSet:
                       [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    NSLog(@"token:%@",token);
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken
{
    //[self sendProviderDeviceToken: devToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    NSLog(@"Error in registration. Error: %@", err);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@",[userInfo valueForKeyPath:@"aps.alert"]);
    
    UIApplication* app = [UIApplication sharedApplication];
    if(app.applicationIconBadgeNumber)
        app.applicationIconBadgeNumber = 0;
    else
    {
        NSString* message = [userInfo valueForKeyPath:@"aps.alert"];
        if([message length])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: APP_NAME
                                                            message: message delegate: self
                                                  cancelButtonTitle: @"Ok"
                                                  otherButtonTitles: nil];
            [alert show];
        }
    }
}

#pragma mark - App Info

- (void)doAlert
{
    NSDictionary* alert = [RCTool getAlert];
    if(alert)
    {
        int type = [[alert objectForKey:@"type"] intValue];
        NSString* title = [alert objectForKey:@"title"];
        NSString* message = [alert objectForKey:@"message"];
        
        NSString* b0_name = @"Cancel";
        b0_name = [alert objectForKey:@"b0_name"];
        
        NSString* b1_name = @"OK";
        b1_name = [alert objectForKey:@"b1_name"];
        
        if(0 == type)
        {
            UIAlertView* temp = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:b0_name otherButtonTitles:nil];
            temp.tag = APP_ALERT;
            [temp show];
        }
        else
        {
            UIAlertView* temp = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:b0_name otherButtonTitles:b1_name,nil];
            temp.tag = APP_ALERT;
            [temp show];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(APP_ALERT == alertView.tag)
    {
        NSLog(@"%d",buttonIndex);
        
        NSDictionary* alert = [RCTool getAlert];
        if(alert)
        {
            int type = [[alert objectForKey:@"type"] intValue];
            if(0 == type || (1 == type && 1 == buttonIndex))
            {
                NSString* urlString = [alert objectForKey:@"url"];
                if([urlString length])
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
                }
            }
        }
    }
    else if(RATE_ALERT == alertView.tag)
    {
        if(1 == buttonIndex)
        {
            NSString* urlString = [RCTool getAppURL];
            if([urlString length])
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        }
    }
}

#pragma mark - Rate

- (void)rate
{
    if(NO == [RCTool isOpenAll])
        return;
    
    NSString* untiltimes = [[NSUserDefaults standardUserDefaults] objectForKey:@"untiltimes"];
    NSInteger i = [untiltimes integerValue];
    if(i == 20)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"VOA Special English Review" message:@"If you enjoy using VOA Special English, please give it good rate and review on AppStore. Thanks a lot." delegate:self cancelButtonTitle:nil otherButtonTitles:@"NO",@"OK", nil];
        alert.tag = RATE_ALERT;
        [alert show];
    }
    else if(i > 20)
    {
        return;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",++i] forKey:@"untiltimes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


@end

