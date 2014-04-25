#import "AppDelegate.h"
#import "RootViewController.h"

#include <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>

#import "GAI.h"
#import "GAIFields.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"

#import "People.h"
#import "Leads.h"
#import "Companies.h"
#import "Tasks.h"
#import "Events.h"
#import "More.h"
#import "Job.h"

/** Google Analytics configuration constants **/
static NSString *const kGaPropertyId = @"UA-30717261-1"; // Job Agent property ID.
static int const kGaDispatchPeriod = 15;
static NSString *const kAllowTracking = @"allowTracking";
static BOOL *const kGaDryRun = NO;


@implementation AppDelegate

@synthesize window=_window;
@synthesize tabBarController=_tabBarController;
@synthesize navigationController =_navigationController;

@synthesize prevSearch, userSettings;
@synthesize managedObjectModel;
@synthesize managedObjectContext;
@synthesize persistentStoreCoordinator;
@synthesize applicationDocumentsDirectory;


- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    
    NSDictionary *appDefaults = @{kAllowTracking: @(YES)};
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    // User must be able to opt out of tracking
    [GAI sharedInstance].optOut =
    ![[NSUserDefaults standardUserDefaults] boolForKey:kAllowTracking];
    
    // Initialize Google Analytics with a N-second dispatch interval. There is a
    // tradeoff between battery usage and timely dispatch.
    [GAI sharedInstance].dispatchInterval = kGaDispatchPeriod;
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    [[GAI sharedInstance] setDryRun:kGaDryRun];
    // Set the log level to verbose.
//    [[GAI sharedInstance].logger setLogLevel:kGAILogLevelVerbose];
    self.tracker = [[GAI sharedInstance] trackerWithTrackingId:kGaPropertyId];


    return TRUE;
    
}


- (BOOL)connectedToNetwork  {
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    if (!didRetrieveFlags)
    {
        NSLog(@"Error. Could not recover network reachability flags");
        return 0;
    }
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}

#pragma mark log data to Google Analytics


- (void)trackPVFull:(NSString*)screenName :(NSString*)eventCategory :(NSString*)eventAction :(NSString*)eventLabel
{
    
    NSLog(@"logging pv for %@ and event %@",screenName,eventCategory);

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
    NSLog(@"logging pv for %@",screenName);
    
    // Google Analytics v3
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    // Sending the same screen view hit using [GAIDictionaryBuilder createAppView]
    [tracker send:[[[GAIDictionaryBuilder createAppView] set:screenName
                                                      forKey:kGAIScreenName] build]];
    
    // Clear the screen name field when we're done.
    [tracker set:kGAIScreenName
           value:nil];
    
}


- (void)trackEvent:(NSString*)trackCategory :(NSString*)trackAction :(NSString*)trackLabel :(int*)value
{
/*
    [self.tracker sendEventWithCategory:trackCategory
                        withAction:trackAction
                         withLabel:trackLabel
                              withValue:[NSNumber numberWithInt:*value]];

     new syntax
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:trackCategory     // Event category (required)
                                                          action:trackAction  // Event action (required)
                                                           label:trackLabel          // Event label
                                                           value:value] build]];    // Event value

*/
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
	
    Leads *leadsVC = [[Leads alloc] initWithNibName:nil bundle:nil];
    leadsVC.managedObjectContext = context;
	
    Companies *companiesVC = [[Companies alloc] initWithNibName:nil bundle:nil];
    companiesVC.managedObjectContext = context;
	
    People *peopleVC = [[People alloc]  initWithNibName:nil bundle:nil];
    peopleVC.managedObjectContext = context;
    
    Events *eventsVC = [[Events alloc] initWithNibName:nil bundle:nil];
    eventsVC.managedObjectContext = context;
	
    Tasks *tasksVC = [[Tasks alloc] initWithNibName:nil bundle:nil];
    tasksVC.managedObjectContext = context;
    
    
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
	NSString *settingsFile = [self.applicationDocumentsDirectory stringByAppendingPathComponent:@"userSettings.xml"];
	NSData *xmlData = [NSPropertyListSerialization dataFromPropertyList:userSettings 
																 format:NSPropertyListXMLFormat_v1_0 
													   errorDescription:nil];
	[xmlData writeToFile:settingsFile atomically:YES];
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Handle the error.
        } 
    }
    NSString *settingsFile = [self.applicationDocumentsDirectory stringByAppendingPathComponent:@"userSettings.xml"];
    NSData *xmlData = [NSPropertyListSerialization dataFromPropertyList:userSettings 
                                                                 format:NSPropertyListXMLFormat_v1_0 
                                                       errorDescription:nil];
    [xmlData writeToFile:settingsFile atomically:YES];

}

#pragma mark -
#pragma mark Saving

/**
 Performs the save action for the application, which is to send the save:
 message to the application's managed object context.
 */
- (IBAction)saveAction:(id)sender {
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        // Handle error
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//		exit(-1);  // Fail
    }
	
}

#pragma mark userSettings
/**
 Returns userSettings dictionary
 */
- (NSMutableDictionary *) userSettings {
	
    if (userSettings != nil) {
        return userSettings;
    }
	
    NSString *settingsFile = [self.applicationDocumentsDirectory stringByAppendingPathComponent:@"userSettings.xml"];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:settingsFile]) {
		userSettings = [NSMutableDictionary dictionaryWithContentsOfFile:settingsFile];
	} else {
		userSettings = [NSMutableDictionary dictionaryWithObjectsAndKeys:
						@"", @"city", @"", @"state",@"", @"postalcode", @"", @"country",
						@"", @"lat", @"", @"lng", @"", @"linkedin",
						nil];
	}
	
	return userSettings;
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
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];    
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
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle the error.
    }    
    
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

#pragma mark GET from sqlite
-(NSArray *)getEvents:(NSString *)eventName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity: [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext]];
	[fetchRequest setResultType:NSDictionaryResultType];
	if (eventName) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", eventName];
		[fetchRequest setPredicate:predicate];	
	}
	
	NSError *error = nil;
	return [managedObjectContext executeFetchRequest: fetchRequest error: &error];	
}

-(NSArray *)getJobs:(NSString *)jobName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity: [NSEntityDescription entityForName:@"Job" inManagedObjectContext:managedObjectContext]];
	[fetchRequest setResultType:NSDictionaryResultType];
	if (jobName) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title LIKE %@", jobName];
		[fetchRequest setPredicate:predicate];	
	}
	
	NSError *error = nil;
	return [managedObjectContext executeFetchRequest: fetchRequest error: &error];
	
}


-(NSArray *)getCompanies:(NSString *)companyName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity: [NSEntityDescription entityForName:@"Company" inManagedObjectContext:managedObjectContext]];
	[fetchRequest setResultType:NSDictionaryResultType];
	if (companyName) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coName LIKE %@", companyName];
		[fetchRequest setPredicate:predicate];	
	}
	
	NSError *error = nil;
	return [managedObjectContext executeFetchRequest: fetchRequest error: &error];
	
}

#pragma mark SAVE to DB

- (void)setCompany:(NSString *)companyName {
	if ([companyName length] > 0) {
		NSFetchRequest *companyFetchRequest = [[NSFetchRequest alloc] init];
		[companyFetchRequest setEntity: [NSEntityDescription entityForName:@"Company" inManagedObjectContext:managedObjectContext]];
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"coName LIKE[cd] %@", companyName];
		[companyFetchRequest setPredicate:predicate];	
		
		NSError *error = nil;
		NSArray *companies = [managedObjectContext executeFetchRequest: companyFetchRequest error: &error];
		
		if ([companies count] == 0) {
			// insert new company
			NSManagedObject *company = [NSEntityDescription insertNewObjectForEntityForName: @"Company" inManagedObjectContext: managedObjectContext];
			[company setValue:companyName forKey:@"coName"];	
		} else {
			// company already exists
		}
		
	}
}

-(NSArray *)getPeople:(NSString *)personName {
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity: [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext]];
	[fetchRequest setResultType:NSDictionaryResultType];
	if (personName) {
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name LIKE %@", personName];
		[fetchRequest setPredicate:predicate];	
	}
	
	NSError *error = nil;
	return [managedObjectContext executeFetchRequest: fetchRequest error: &error];
	
}

-(NSArray *)getPerson:(NSString *)personName {
        NSString *firstName = [NSString stringWithFormat:@"%@",[personName substringToIndex:[personName rangeOfString:@" "].location]];
        NSString *lastName = [personName substringFromIndex:[personName rangeOfString:@" "].location+1];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity: [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext]];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"firstName LIKE[cd] %@ AND lastName LIKE[cd] %@", firstName, lastName];
        [fetchRequest setPredicate:predicate];	
        
        NSError *error = nil;
        NSArray *people = [managedObjectContext executeFetchRequest: fetchRequest error: &error];
        return people;
}


- (void)setPerson:(NSString *)personName withCo:(NSString *)companyName {
	if ([personName length] > 0) {
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity: [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext]];

        NSString *firstName = @"";
        NSString *lastName = personName;
        NSPredicate *predicate;

        if ([personName rangeOfString:@" "].location != NSNotFound) {
            firstName = [personName substringToIndex:[personName rangeOfString:@" "].location];
            lastName = [personName substringFromIndex:[personName rangeOfString:@" "].location+1];
            predicate = [NSPredicate predicateWithFormat:@"lastName LIKE[c] %@ AND firstName LIKE[c] %@", lastName, firstName];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"lastName LIKE[c] %@ AND NOT firstName.length > 0", lastName];
        }
		[fetchRequest setPredicate:predicate];	
		
		NSError *error = nil;
        NSArray *people = [managedObjectContext executeFetchRequest: fetchRequest error: &error];

		if ([people count] == 0) { 	// person not found
			// insert new person
			NSManagedObject *person = [NSEntityDescription insertNewObjectForEntityForName: @"Person" inManagedObjectContext: managedObjectContext];

			[person setValue:firstName forKey:@"firstName"];	
			[person setValue:lastName forKey:@"lastName"];	
			[person setValue:companyName forKey:@"company"];	
		}
		
	}
}


#pragma mark backup data to E-mail

- (void)archiveData {
	// need UI to get e-mail address and save to user-settings	
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // Check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
			NSString *dataFile = [self.applicationDocumentsDirectory stringByAppendingPathComponent:@"archive.txt"];
			NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];		
			[fetchRequest setResultType:NSDictionaryResultType];
			[fetchRequest setEntity: [NSEntityDescription entityForName:@"Job" inManagedObjectContext:managedObjectContext]];
			//			[fetchRequest setPropertiesToFetch:[NSArray arrayWithObjects:@"title",@"company",@"link",nil]];
			
			NSError *error = nil;
			NSMutableArray *fetchResults = [NSMutableArray arrayWithArray:[managedObjectContext executeFetchRequest: fetchRequest error: &error]];
			
			// ADD Activities
			[fetchRequest setEntity: [NSEntityDescription entityForName:@"Event" inManagedObjectContext:managedObjectContext]];
			[fetchResults addObjectsFromArray:[managedObjectContext executeFetchRequest: fetchRequest error: &error]];
			
			// ADD Companies
			[fetchRequest setEntity: [NSEntityDescription entityForName:@"Company" inManagedObjectContext:managedObjectContext]];
			[fetchResults addObjectsFromArray:[managedObjectContext executeFetchRequest: fetchRequest error: &error]];
			
			// ADD People
			[fetchRequest setEntity: [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext]];
			[fetchResults addObjectsFromArray:[managedObjectContext executeFetchRequest: fetchRequest error: &error]];
			
			// ADD Tasks
			[fetchRequest setEntity: [NSEntityDescription entityForName:@"Task" inManagedObjectContext:managedObjectContext]];
			[fetchResults addObjectsFromArray:[managedObjectContext executeFetchRequest: fetchRequest error: &error]];
			
			//			NSLog(@"items: %i",[fetchResults count]);
			[fetchResults writeToFile:dataFile atomically:NO];
			
        }
    }
	
	
	//	}
	/*
	 - check that user can send mail
	 - fetch data for jobs, companies, people, activities
	 - store data in text file  
	 - compose mail. Attach text file
	 - send mail
	 */
	
	//	[recipients release];
}


#pragma mark date functions
/** return date from string **/
- (NSDate *)dateFromString:(NSString *)tmpDate {
//	NSLog(@"date string in: %@ ",tmpDate);
	NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
	[inputFormat setDateFormat:@"MM/dd/yy"];
	[inputFormat setFormatterBehavior:NSDateFormatterBehavior10_4];	
	[inputFormat setLenient:YES];

    NSDate *retDate = [inputFormat dateFromString:tmpDate];
    
    return retDate;
}	

/** return short date **/
- (NSString *)shortDate:(NSDate*)tmpDate {	
	NSDateFormatter *outputFormat = [[NSDateFormatter alloc ] init];
	[outputFormat setDateStyle:NSDateFormatterShortStyle];
	if (!tmpDate) { tmpDate = [NSDate date]; }

    NSString *retDate = [outputFormat stringFromDate:tmpDate];
    return retDate;

}

- (NSString *)getShortDate:(NSString*)tmpDate {
	
	NSDateFormatter *outputFormat = [[NSDateFormatter alloc ] init];
	[outputFormat setDateStyle:NSDateFormatterShortStyle];	
    NSString *retString = [outputFormat stringFromDate:[NSDate date]];
	
	if ([tmpDate length] > 0 && ![tmpDate isEqual:@"(null)"]) { 
		
		NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
		[inputFormat setFormatterBehavior:NSDateFormatterBehavior10_4];	
		[inputFormat setLenient:YES];
		
		// indeed: Sat, 03 Apr 2010 12:22:58 GMT
		[inputFormat setDateFormat:@"eee, dd MMM yyyy hh:mm:ss 'GMT'"];
		NSDate *formattedDate = [inputFormat dateFromString:tmpDate];
        
		//NSLog(@"gsd, indeed date out: %@ ",formattedDate);
		
		if (formattedDate == nil) { // try Craigslist format
			// cr: 2010-04-03T17:04:30-07:00
			[inputFormat setDateFormat:@"yyyy-MM-dd'T'hh:mm:ssZZZZ"];
			formattedDate = [inputFormat dateFromString:tmpDate];
			//NSLog(@"gsd, CR date out: %@ ",formattedDate);
		}
		if (formattedDate == nil) { // try Linkup format
			// LI: April 21, 2010
			[inputFormat setDateFormat:@"MMMM dd, yyyy"];
			formattedDate = [inputFormat dateFromString:tmpDate];
			//NSLog(@"gsd, LU date out: %@ ",formattedDate);
		}
		if (formattedDate == nil) { // try system format
			// 2010-04-06 00:00:00 -0700
			[inputFormat setDateFormat:@"yyyy-MM-dd hh:mm:ss ZZZZ"];
			formattedDate = [inputFormat dateFromString:tmpDate];
		}


		if (formattedDate == nil) { // return current date

		} else {
			retString = [outputFormat stringFromDate:formattedDate];
		}
        
	} else { // no date input
        retString = [outputFormat stringFromDate:[NSDate date]];
	}
    return retString;
}


@end