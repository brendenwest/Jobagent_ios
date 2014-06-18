//
//  jobagentAppDelegate.h
//  jobagent
//
//  Created by mac on 2/23/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "GAI.h"

// define value for determining pre-iOS 7 devices
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

// define value to set analytics 'dryRun' and exclude dev traffic from reports
#define DRYRUN

// define value to bypass reverse geocoding and minimize Google api requests when testing search results
#define DEVLOCATION

// define value to use local job-search API
//#define DEVAPI


@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate> {
	
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext; 
	NSMutableDictionary *userSettings;
	
    UIWindow *window;
    UITabBarController *tabBarController;
    UINavigationController *navigationController;
    NSString *prevSearch;
}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, strong) IBOutlet UINavigationController *navigationController;

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSString *applicationDocumentsDirectory;
@property (nonatomic, strong) NSMutableDictionary *userSettings;
@property (nonatomic, strong) NSString *prevSearch;
@property(nonatomic, strong) id<GAITracker> tracker;
@property (strong, nonatomic, readonly) NSDictionary *configuration;


- (IBAction)saveAction:sender;

- (BOOL)connectedToNetwork;
- (void)trackPV:(NSString*)screenName;
- (void)trackPVFull:(NSString*)screenName :(NSString*)eventCategory :(NSString*)eventAction :(NSString*)eventLabel;

- (void)setCompany:(NSString *)companyName;
- (NSArray*)getCompanies:(NSString*)companyName;
- (NSArray*)getJobs:(NSString*)jobName;

- (NSArray*)getPeople:(NSString*)personName;
- (void)setPerson:(NSString*)personName withCo:(NSString*)companyName;

- (NSArray*)getEvents:(NSString*)eventName;


@end