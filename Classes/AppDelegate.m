#import "AppDelegate.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

#import "Events.h"
#import "jobagent-Swift.h"

/** Google Analytics configuration constants **/
/** Other settings in appconfig.plist **/
#ifdef DRYRUN
    static BOOL const kGaDryRun = YES;
#else
    static BOOL const kGaDryRun = NO;
#endif

@import GoogleMobileAds;

@implementation AppDelegate

@synthesize managedObjectContext;
@synthesize configuration = _configuration;


- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {

    // get bundle defaults
    [self registerDefaultsFromSettingsBundle];
    [Settings onLaunch];
    
    [self setContextForVCs];
    
    // load values from appconfig.plist
    _configuration = [self configuration];
    
    // User must be able to opt out of tracking
    [GAI sharedInstance].optOut = ![_configuration objectForKey:@"kAllowTracking"];
    
    // Initialize Google Analytics with a N-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    [GAI sharedInstance].dispatchInterval = (int)[_configuration objectForKey:@"kGaDispatchPeriod"];
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] setDryRun:kGaDryRun];
    // Set the log level to verbose.
//    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:[_configuration objectForKey:@"kGaPropertyId"]];
    
        
    if (launchOptions != nil)
    {
        NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil)
            [self handleRemoteNotification:dictionary];
    } else {
        // clear notification badge
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;

    }
    
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:1 * 1024 * 1024
                                                            diskCapacity:5 * 1024 * 1024
                                                                diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    
    return TRUE;
    
}

- (void)registerDefaultsFromSettingsBundle
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults synchronize];
    
    NSString *settingsBundle = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
    
    if(!settingsBundle)
    {
        NSLog(@"Could not find Settings.bundle");
        return;
    }
    
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:[settingsBundle stringByAppendingPathComponent:@"Root.plist"]];
    NSArray *preferences = [settings objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *defaultsToRegister = [[NSMutableDictionary alloc] initWithCapacity:[preferences count]];
    
    for (NSDictionary *prefSpecification in preferences)
    {
        NSString *key = [prefSpecification objectForKey:@"Key"];
        if (key)
        {
            // check if value readable in userDefaults
            id currentObject = [userDefaults objectForKey:key];
            if (currentObject == nil)
            {
                // not readable: set value from Settings.bundle
                id objectToSet = [prefSpecification objectForKey:@"DefaultValue"];
                [defaultsToRegister setObject:objectToSet forKey:key];
            }
            else
            {
                // already readable: don't touch
                NSLog(@"Key %@ is readable (value: %@), nothing written to defaults.", key, currentObject);
            }
        }
    }
    
    [userDefaults registerDefaults:defaultsToRegister];
    [userDefaults synchronize];
}

- (void)application:(UIApplication *)app didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [self handleRemoteNotification:userInfo];
}

-(void)handleRemoteNotification:(NSDictionary*)payload
{
    NSString *message = [[payload valueForKey:@"aps"] valueForKey:@"alert"];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"News"
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alert show];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}



#pragma mark log data to Google Analytics


- (void)trackPVFull:(NSString*)screenName :(NSString*)eventCategory :(NSString*)eventAction :(NSString*)eventLabel
{
    
    // Google Analytics v3
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // Sending the same screen view hit using [GAIDictionaryBuilder createAppView]
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:screenName
                                                      forKey:kGAIScreenName] build]];
    
    if (eventCategory != nil) {
        // Send category (params) with screen hit
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:eventCategory     // Event category (required)
                                                          action:eventAction  // Event action (required)
                                                          label:eventLabel          // Event label
                                                          value:nil] build]];    // Event value
    }

    // Clear the screen name field when we're done.
    [tracker set:kGAIScreenName
           value:nil];
}

- (void)trackPV:(NSString*)screenName
{
    // Google Analytics v3
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // Sending the same screen view hit using [GAIDictionaryBuilder createAppView]
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:screenName
                                                      forKey:kGAIScreenName] build]];
    
    // Clear the screen name field when we're done.
    [tracker set:kGAIScreenName
           value:nil];
    
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	// low on memory: do whatever you can to reduce your memory foot print here
}


- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    
	NSManagedObjectContext *context = [self managedObjectContext];
    if (!context) {
        // Handle the error.
    }
    
    Events *eventsVC = [[Events alloc] initWithNibName:nil bundle:nil];
    eventsVC.managedObjectContext = context;
     
	
#ifdef IS_SIMULATOR
#else
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#endif

}


// Delegation methods
- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
    // device token handled by UA library
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Handle the error.
        } 
    }
    
    [self synchUserDefaults];
    
}

- (void)synchUserDefaults {
    // Store user settings

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (Settings.searches != NULL) {
        [defaults setValue:Settings.searches forKey:@"searches"];
    }
    [defaults synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Handle the error.
        } 
    }
    
    [self synchUserDefaults];
    
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    return YES;
}

#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (void)saveAction:(id)sender {
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        // Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//		exit(-1);  // Fail
    }
	
}


- (NSDictionary *)configuration
{
    if (_configuration == nil)
    {
        NSMutableDictionary *configuration = [[NSMutableDictionary alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // init configuration map
        NSDictionary *configMap = [NSDictionary dictionaryWithObjectsAndKeys:
                                   @"jobagentUrlAppStore",     @"jobagentUrlAppStore",
                                   @"kGaPropertyId",           @"kGaPropertyId",
                                   @"kGaDispatchPeriod",       @"kGaDispatchPeriod",
                                   @"kAllowTracking",          @"kAllowTracking",
                                   @"adUnitID",                @"adUnitID",
                                   @"apiDomainDev",            @"apiDomainDev",
                                   @"apiDomainProd",           @"apiDomainProd",
                                   @"searchUrl",               @"searchUrl",
                                   @"tipsUrl",                 @"tipsUrl",
                                   nil];
        

        // loading configuration from stored plist
            for (NSString *key in configMap.allKeys)
            {
                id object = [userDefaults objectForKey:key];
                if (object != nil)
                {
                    [configuration setObject:object forKey:key];
                }
            }
   
        

        // loading the rest of configuration from default plist
        if (configuration.allKeys.count < configMap.allKeys.count)
        {
            NSString *defaultConfFile = [[NSBundle mainBundle] pathForResource:@"appconfig" ofType:@"plist"];
            NSDictionary *defaultConfig = [NSDictionary dictionaryWithContentsOfFile:defaultConfFile];
            
            for (NSString *key in configMap.allKeys)
            {
                id defaultObject = [defaultConfig objectForKey:[configMap objectForKey:key]];
                id storedObject = [configuration objectForKey:key];
                if (storedObject == nil && defaultObject != nil)
                {
                    [configuration setObject:defaultObject forKey:key];
                    [userDefaults setObject:defaultObject forKey:key];
                }
            }
            
            [userDefaults synchronize];
        }

        _configuration = configuration;
    }
    
    return _configuration;
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
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType: NSMainQueueConcurrencyType];
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
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"jobagent" ofType:@"momd"];
    NSURL *momURL = [NSURL fileURLWithPath:path];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:momURL];
    
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
    
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"jobagent.sqlite"]];
    
    NSError *error = nil;
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
    						 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
    						 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle the error.
    }    
    
    return persistentStoreCoordinator;
}


#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


@end
