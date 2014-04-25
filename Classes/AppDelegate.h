//
//  jobagentAppDelegate.h
//  jobagent
//
//  Created by mac on 2/23/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "GAI.h"

// Other
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate> {
	
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


- (IBAction)saveAction:sender;

- (BOOL)connectedToNetwork;
- (void)trackPV:(NSString*)screenName;
- (void)trackPVFull:(NSString*)screenName :(NSString*)eventCategory :(NSString*)eventAction :(NSString*)eventLabel;
- (void)trackEvent:(NSString*)category :(NSString*)action :(NSString*)label :(int*)value;

- (NSString*)getShortDate:(NSString*)tmpDate;
- (NSDate*)dateFromString:(NSString*)tmpDate;
- (NSString*)shortDate:(NSDate*)tmpDate;

- (void)setCompany:(NSString *)companyName;
- (NSArray*)getCompanies:(NSString*)companyName;
- (NSArray*)getJobs:(NSString*)jobName;

- (NSArray*)getPeople:(NSString*)personName;
- (void)setPerson:(NSString*)personName withCo:(NSString*)companyName;

- (NSArray*)getEvents:(NSString*)eventName;

- (void)archiveData;


@end