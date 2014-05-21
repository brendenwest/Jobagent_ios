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

+ (UIToolbar*)customBarButtons:buttonProperties {

    long nButtons = [buttonProperties count]/3;
	// create a toolbar to have N buttons in the right. Set width according to # of buttons
	UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, nButtons*45, 45)];
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] init];
    
	for (int i=0; i < [buttonProperties count]; i+=3) {
        Class systemButton = NSClassFromString(buttonProperties[i]);
        SEL selAction = NSSelectorFromString(buttonProperties[i+1]);
        Class selTarget = NSClassFromString(buttonProperties[i+2]);

        
        // create a standard toolbar button
        UIBarButtonItem* bi = [[UIBarButtonItem alloc]
						   initWithBarButtonSystemItem:systemButton target:selTarget action:selAction];
        [buttons addObject:bi];
        NSLog(@"i=%d; button=%@ target=%@, action=%@",i, systemButton,selTarget, buttonProperties[i+1]);

        if ([buttonProperties count] > 3) {
        // create a spacer
            bi = [[UIBarButtonItem alloc]
              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            [buttons addObject:bi];
        }
    }
		  
	// stick the buttons into the toolbar
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
+ (NSString *)shortDate:(NSDate*)tmpDate {
	NSDateFormatter *outputFormat = [[NSDateFormatter alloc ] init];
	[outputFormat setDateStyle:NSDateFormatterShortStyle];
	if (!tmpDate) { tmpDate = [NSDate date]; }
    
    NSString *retDate = [outputFormat stringFromDate:tmpDate];
    return retDate;
    
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
