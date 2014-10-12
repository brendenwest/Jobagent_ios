//
//  Common.m
//  jobagent
//
//  Created by Brenden West on 5/8/14.
//
//

#import "Common.h"

@implementation Common

- (id) init
{
    self = [super init];
	if (self == [super init]) {
		return self;
	}
	
	return nil;
	
}

+ (BOOL)connectedToNetwork  {
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




+ (UIToolbar*)customBarButtons:(NSArray*)buttonProperties {
    // toolbar button constructor
    
    int nButtons = (int)[buttonProperties count];
	// create  array to hold the buttons, which then gets added to the toolbar
    // buttonProperties is an array of arrays. Each sub array
    // has properties for button type, action, and target
	NSMutableArray* buttons = [[NSMutableArray alloc] init];
    UIBarButtonItem* bi;
    
	for (int i=0; i < nButtons; i++) {
        
        int buttonType = (int)[buttonProperties[i][0] integerValue];
        UIViewController *selTarget = buttonProperties[i][2];
        
        if (buttonType == 2) {
            // create a standard "edit" button
            bi = selTarget.editButtonItem;
        } else {
            UIBarButtonSystemItem systemButton = buttonType;
            SEL selAction = NSSelectorFromString(buttonProperties[i][1]);
            
            // create a standard toolbar button
            bi = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:systemButton target:selTarget action:selAction];
        }

        [buttons addObject:bi];
        
        if (nButtons > 1) {
        // create a spacer
            bi = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            [buttons addObject:bi];
        }
    }
		  
    // create a toolbar to have N buttons in the right. Set width according to # of buttons
    UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, nButtons*45, 45)];
	[tools setItems:buttons animated:NO];
    return tools;
	
}

#pragma mark common date functions

/** return date from string **/
+ (NSDate *)dateFromString:(NSString *)tmpDate {
    //	NSLog(@"date string in: %@ ",tmpDate);
	NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
	[inputFormat setDateFormat:@"MM/dd/yy"];
	[inputFormat setFormatterBehavior:NSDateFormatterBehavior10_4];
	[inputFormat setLenient:YES];
    
    NSDate *retDate = [inputFormat dateFromString:tmpDate];
    
    return retDate;
}

/** return short date **/
+ (NSString *)stringFromDate:(NSDate*)tmpDate {
	NSDateFormatter *shortDateFormatter = [[NSDateFormatter alloc ] init];
    [shortDateFormatter setLocale:[NSLocale currentLocale]];
	[shortDateFormatter setDateStyle:NSDateFormatterShortStyle];
	if (!tmpDate) { tmpDate = [NSDate date]; }
        
    NSString *dateString = [shortDateFormatter stringFromDate:tmpDate];
    return dateString;
    
}

+ (NSString *)getShortDate:(NSString*)tmpDate {
	
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


+ (UITextView *)formatTextView:(UITextView*)textView :(NSString*)placeholder {
    textView.layer.cornerRadius = 8;
	textView.layer.borderWidth = 1;
	textView.layer.borderColor = [[UIColor grayColor] CGColor];
    textView.text = placeholder;
    textView.textColor = [UIColor lightGrayColor];
    return textView;
}


@end
