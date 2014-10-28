//
//  location.m
//  jobagent
//
//  Created by Brenden West on 10/5/14.
//
//

#import "Location.h"

@implementation Location


+ (BOOL)isValidZip:(int)integerZip {
    
    // check that entered location code is valid
    // valid entries either match current stored location or a valid US 5-digit zip
    BOOL validUSzip = integerZip > 9999 && integerZip < 100000;

    if (!validUSzip) {
        UIAlertView *validZipAlert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"STR_VALID_LOCATION", nil) delegate:NULL cancelButtonTitle:@"Ok" otherButtonTitles:NULL];
        [validZipAlert show];
    }
    return validUSzip;
}

+ (void)updateUserLocation:(NSMutableDictionary *)curLocation withPlace:(CLPlacemark *)placemark {
    
    // populate current location w/ new geocode values
    [curLocation setValue:(NSString *)placemark.locality forKey:@"city"];
    [curLocation setValue:(NSString *)placemark.administrativeArea forKey:@"state"];
    [curLocation setValue:(NSString *)placemark.ISOcountryCode forKey:@"country"];
    [curLocation setValue:(NSString *)placemark.postalCode forKey:@"postalcode"];

    // get text for display in location-entry field
    NSString *locationText =  [self getLocationText:placemark.locality withCountry:placemark.ISOcountryCode withZip:placemark.postalCode];
    [curLocation setValue:locationText forKey:@"usertext"];
    
    // save new location to user defaults
    [self setDefaultLocation:curLocation];
    
}

+ (NSString*)getLocationText:(NSString *)city withCountry:(NSString *)country withZip:(NSString *)postalCode {
    // set value for location-entry field.
    // value may be US zip or combination of City, Country
    NSString *locationText = @"";
    
    if ([country isEqualToString:@"US"]) {
        // show postal code
        locationText = postalCode;
    } else if ([country length] > 0) {
        // show city & country
        locationText = [NSString stringWithFormat:@"%@, %@",city,country];
    }
    return locationText;
}


+ (NSMutableDictionary *)getDefaultLocation {
    // set instance variables for current location from user defaults
    
#ifdef DEVLOCATION
    // set dummy values to minimize location detection calls while testing
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   @"98104", @"usertext",
                   @"Seattle", @"city",
                   @"WA", @"state",
                   @"US", @"country",
                   @"98104", @"postalcode",
                   nil];
#else

    // get last-stored user location data from user defaults
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] stringForKey:@"usertext"], @"usertext",
                                            [[NSUserDefaults standardUserDefaults] stringForKey:@"city"], @"city",
                                            [[NSUserDefaults standardUserDefaults] stringForKey:@"state"], @"state",
                                            [[NSUserDefaults standardUserDefaults] stringForKey:@"countryCode"], @"country",
                                            [[NSUserDefaults standardUserDefaults] stringForKey:@"postalcode"], @"postalcode",
                                            nil];

#endif
    
}

+(void)setDefaultLocation:(id)newLocation {
    // store current location to User Defaults
    // may be called from home screen or from cities picker

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *locationText;
    if([newLocation isKindOfClass:[NSMutableDictionary class]])
    {
        [defaults setObject:[newLocation objectForKey:@"city"] forKey:@"city"];
        [defaults setObject:[newLocation objectForKey:@"state"] forKey:@"state"];
        [defaults setObject:[newLocation objectForKey:@"country"] forKey:@"countryCode"];
        [defaults setObject:[newLocation objectForKey:@"postalcode"] forKey:@"postalcode"];
        
        locationText =  [self getLocationText:[newLocation objectForKey:@"city"] withCountry:[newLocation objectForKey:@"country"] withZip:[newLocation objectForKey:@"postalcode"]];

    } else if([newLocation isKindOfClass:[CLPlacemark class]]) {
        newLocation = (CLPlacemark*)newLocation;
        // populate current location w/ new geocode values

        [defaults setObject:[newLocation locality] forKey:@"city"];
        [defaults setObject:[newLocation administrativeArea] forKey:@"state"];
        [defaults setObject:[newLocation ISOcountryCode] forKey:@"countryCode"];
        [defaults setObject:[newLocation postalCode] forKey:@"postalcode"];

        locationText =  [self getLocationText:[newLocation locality] withCountry:[newLocation ISOcountryCode] withZip:[newLocation postalCode]];
        
    }
    [defaults setObject:locationText forKey:@"usertext"];
    [defaults synchronize];
    
}

@end
