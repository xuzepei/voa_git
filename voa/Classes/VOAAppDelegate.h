//
//  VOAAppDelegate.h
//  VOA
//
//  Created by xuzepei on 6/16/10.
//  Copyright Rumtel Co.,Ltd 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@class WRSysTabBarController;
@class VOACategoriesViewController;
@class VOAVocabularyViewController;
@class VOAFavoritesViewController;
@class VOADownloadViewController;
@class VOASettingViewController;
@interface VOAAppDelegate : NSObject <UIApplicationDelegate,GADBannerViewDelegate,GADInterstitialDelegate> {
    
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;

    UIWindow *window;
    WRSysTabBarController* _tabBarController;
	
	VOACategoriesViewController* _categoriesViewController;
	UINavigationController* _categoriesNavigationController;
	
	VOAVocabularyViewController* _vocabularyViewController;
	UINavigationController* _vocabularyNavigationController;
	
	VOAFavoritesViewController* _favoritesViewController;
	UINavigationController* _favoritesNavigationController;
	
	VOADownloadViewController* _downloadViewController;
	UINavigationController* _downloadNavigationController;
	
	VOASettingViewController* _settingViewController;
	UINavigationController* _settingNavigationController;

    UIBackgroundTaskIdentifier _bgTask;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) WRSysTabBarController* _tabBarController;

@property (nonatomic, retain)VOACategoriesViewController* _categoriesViewController;
@property (nonatomic, retain)UINavigationController* _categoriesNavigationController;

@property (nonatomic, retain)VOAVocabularyViewController* _vocabularyViewController;
@property (nonatomic, retain)UINavigationController* _vocabularyNavigationController;

@property (nonatomic, retain)VOAFavoritesViewController* _favoritesViewController;
@property (nonatomic, retain)UINavigationController* _favoritesNavigationController;

@property (nonatomic, retain)VOADownloadViewController* _downloadViewController;
@property (nonatomic, retain)UINavigationController* _downloadNavigationController;

@property (nonatomic,retain)VOASettingViewController* _settingViewController;
@property (nonatomic,retain)UINavigationController* _settingNavigationController;

@property (nonatomic, strong) GADBannerView *adMobAd;
@property (assign)BOOL isAdMobVisible;
@property (nonatomic, strong) GADInterstitial *adInterstitial;

@property (nonatomic,strong) NSString* ad_id;
@property (nonatomic,assign)BOOL showFullScreenAd;


- (NSString *)applicationDocumentsDirectory;

- (NSManagedObjectContext *) managedObjectContext;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

- (void)showInterstitialAd:(UIViewController*)rootViewController;
- (void)getAdInterstitial;



@end

