//
//  Common.h
//  jobagent
//
//  Created by Brenden West on 5/8/14.
//
//

#import <Foundation/Foundation.h>
#include <netinet/in.h>
#import <SystemConfiguration/SCNetworkReachability.h>

@interface Common : NSObject

- (id) init;
+ (BOOL)connectedToNetwork;
+ (UIToolbar *)customBarButtons:(NSArray*)buttonProperties;
+ (NSDate *)dateFromString:(NSString *)tmpDate;
+ (NSString *)stringFromDate:(NSDate*)tmpDate;
+ (NSString *)getShortDate:(NSString*)tmpDate;
+ (UITextView *)formatTextView:(UITextView*)textView :(NSString*)placeholder;
+ (void)buttonRounded:(UIButton*)button;

@end
