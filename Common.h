//
//  Common.h
//  jobagent
//
//  Created by Brenden West on 5/8/14.
//
//

#import <Foundation/Foundation.h>

@interface Common : NSObject

- (id) init;
+ (UIToolbar *)customBarButtons:buttonProperties;
+ (NSDate *)dateFromString:(NSString *)tmpDate;
+ (NSString *)shortDate:(NSDate*)tmpDate;
+ (NSString *)getShortDate:(NSString*)tmpDate;


@end
