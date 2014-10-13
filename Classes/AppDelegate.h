//
//  jobagentAppDelegate.h
//  jobagent
//
//  Created by mac on 2/23/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "GAI.h"


@class RootViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate> {
	
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSString *settingsFile;

}

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableDictionary *userSettings;
@property (strong, nonatomic, readonly) NSDictionary *configuration;
@property (nonatomic, strong) NSString *previousSearch;
@property(nonatomic, strong) id<GAITracker> tracker;


- (void)saveAction:sender;

// Google Analytics methods
- (void)trackPV:(NSString*)screenName;
- (void)trackPVFull:(NSString*)screenName :(NSString*)eventCategory :(NSString*)eventAction :(NSString*)eventLabel;

// Core Data methods
- (void)setCompany:(NSString *)companyName;
- (void)setPerson:(NSString*)personName withCo:(NSString*)companyName;

@end