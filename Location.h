//
//  location.h
//  jobagent
//
//  Created by Brenden West on 10/5/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Location : NSObject


+ (NSMutableDictionary *)getDefaultLocation;
+ (void)setDefaultLocation:(id)newLocation;
+ (BOOL)isValidZip:(int)integerZip;
+ (void)updateUserLocation:(NSMutableDictionary *)curLocation withPlace:(CLPlacemark *)placemark;
+ (NSString*)getLocationText:(NSString *)city withCountry:(NSString *)country withZip:(NSString *)postalCode;

@end
