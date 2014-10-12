//
//  RootViewController.m
//  jobagent
//
//  Created by mac on 4/23/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "RootViewController.h"
#import "AppDelegate.h"
#import "SearchJobs.h"
#import "Cities.h"
#import "Ads.h"
#import "Location.h"
#import "Common.h"

@implementation RootViewController

{
    AppDelegate *appDelegate;
    CLLocation *startLocation;
    NSMutableDictionary *curLocation;
    NSMutableDictionary *userSettings;
    NSMutableArray *searches;
    
}

#pragma mark View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    // get saved searches from storage
    if (userSettings == nil)
        userSettings = [appDelegate userSettings];
    
    [self getRecentSearches];
    
    [Ads getAd:self];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:(BOOL)animated];
NSLog(@"viewWillAppear");

    // set instance variables for current location from user defaults
    curLocation = [Location getDefaultLocation];
    NSLog(@"default location = %@",[curLocation objectForKey:@"postalcode"]);
    
    if (![[curLocation objectForKey:@"usertext"] length] && [Common connectedToNetwork]) {
        // no user location set. Detect current location
        [self detectLocation];
    } else {
        [self updateLocationFields];
    }
    
    _tblRecent.dataSource = self;
    
    if ([searches count] > 0) {
        _tblRecent.hidden = NO;
        [self.tblRecent reloadData];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:(BOOL)animated];
    
    // Google Analytics call needs to happen here to record initial launch event
    [appDelegate trackPV:@"Home"];
}

- (void)getRecentSearches {
    // if user conducted searches earlier, retrieve from storage
    // populate search query field if field is not empty
    if ([[userSettings objectForKey:@"searches"] count] > 0) {
        // use recent searches
        searches = [[NSMutableArray alloc] initWithArray:[userSettings objectForKey:@"searches"]];
        if (![_txtSearch.text length]) {
            _txtSearch.text = [[searches objectAtIndex:0] substringToIndex:[[searches objectAtIndex:0] rangeOfString:@"|"].location];
        }
    } else {
        searches = [[NSMutableArray alloc] init];
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [_txtSearch resignFirstResponder];
    [_txtLocation resignFirstResponder];
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"showSearchResults"]) {
        
        // save this search
        NSString *thisSearch = [NSString stringWithFormat:@"%@|%@|%@",_txtSearch.text,_txtLocation.text,[curLocation objectForKey:@"country"],nil];
        if (![searches containsObject:thisSearch]) {
            [searches insertObject:thisSearch atIndex:0];
            [userSettings setValue:searches forKey:@"searches"];
        }
        
        [[segue destinationViewController] setKeyword:_txtSearch.text];
        [[segue destinationViewController] setCurLocation:_txtLocation.text];
        [[segue destinationViewController] setCurLocale:[curLocation objectForKey:@"country"]];
    } else if ([[segue identifier] isEqualToString:@"showCities"]) {
        [[segue destinationViewController] setPlacemarks:sender];

    }
}


- (IBAction)searchJobs:(id)sender {
    
    if (![Common connectedToNetwork]) {
        UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"STR_NO_NETWORK", nil) delegate:NULL cancelButtonTitle:@"Ok" otherButtonTitles:NULL];
        [noNetworkAlert show];
    } else if (![_txtLocation.text length] || ![_txtSearch.text length]) {
        // remind user to enter value for both search term and location
        UIAlertView *emptyFieldAlert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"STR_EMPTY_FIELD", nil) delegate:NULL cancelButtonTitle:@"Ok" otherButtonTitles:NULL];
		[emptyFieldAlert show];
    } else {
        if ([self isNewLocation:_txtLocation.text]) {
            // user entered a new location value
            [self checkEnteredLocation:_txtLocation];
        }

        // Don't fire job search if user entered invalid location
        // curLocation values may be updated by geocoding action on checkEnteredLocation call
        if ([_txtLocation.text isEqualToString:[curLocation objectForKey:@"usertext"]]) {
            [self performSegueWithIdentifier: @"showSearchResults" sender: nil];

        }
    }
}

#pragma mark Location Manager methods

- (void)detectLocation {
    // get location for first-time user
    NSLog(@"detectLocation");
    
    if (nil == _locationManager)
        _locationManager = [[CLLocationManager alloc] init];
    
    if (![CLLocationManager locationServicesEnabled])
    {   //show an alert
        NSLog(@"locationServices not enabled");
        
    } else {
        _locationManager.delegate = self;
        if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [_locationManager requestWhenInUseAuthorization];
        }
        _locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        [_locationManager startUpdatingLocation];
        startLocation = nil;
        NSLog(@"startUpdatingLocation");
    }
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError*)error {

    NSLog(@"Location check failed %@",error);
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSLog(@"didUpdateToLocation");
       CLLocation* newLocation = [locations lastObject];

    if (startLocation == nil || startLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        startLocation = newLocation;
        
        if (newLocation.horizontalAccuracy <= manager.desiredAccuracy) {
            [self.locationManager stopUpdatingLocation];
            
            // reverse Geocode the lat-long
            [self performCoordinateGeocode:newLocation];
            
            self.locationManager.delegate = nil;

        }
    }


}


- (void)performCoordinateGeocode:(CLLocation *)location
{
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            return;
        }

        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        [self setUserLocation:placemark];
        
    }];
}


- (void)forwardGeocode:(NSString *)placename
{
    NSLog(@"forwardGeocode - %@", placename);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:placename completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        NSLog(@"placemarks count - %lu", (unsigned long)[placemarks count]);
        NSLog(@"placemarks error - %@", error.description);
        
        if ([placemarks count] == 1) { // one city returned. set location accordingly
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:placemark.region.center.latitude longitude:placemark.region.center.longitude];
            
            [geocoder reverseGeocodeLocation:loc completionHandler:
             ^(NSArray* placemarks, NSError* error){
                 if ([placemarks count] > 0)
                 {
             NSLog(@"got new placemark");
                     CLPlacemark *newPlacemark = [placemarks objectAtIndex:0];
                     [Location updateUserLocation:curLocation withPlace:newPlacemark];
//                     NSLog(@"new location = %@",curLocation);
                     [self updateLocationFields];
                     
                 }
             }];
        } else if ([placemarks count] > 1) {
            [self performSegueWithIdentifier: @"showCities" sender: placemarks];
        }

    }];

}

- (BOOL)isNewLocation:(NSString*)entry {
    // return true if user entry differs from last stored value
    return (![entry isEqualToString:[curLocation objectForKey:@"usertext"]]);
}

- (void)setUserLocation:(CLPlacemark *)placemark {

    // populate current location w/ new geocode values
    
    [Location updateUserLocation:(NSMutableDictionary *)curLocation withPlace:(CLPlacemark *)placemark];
    [self updateLocationFields];

}

- (void)updateLocationFields {
    // update current location values in UI
NSLog(@"updateLocationFields");
NSLog(@"curLocation = %@",curLocation);
    
    if ([curLocation objectForKey:@"country"] == nil) {
        NSLog(@"no curLocale");
    }
    if ([[curLocation objectForKey:@"usertext"] length] && [[curLocation objectForKey:@"country"] isEqual:@"US"]) {
        _lblCityState.hidden = NO;
        _lblCityState.text = [NSString stringWithFormat:@"%@, %@",[curLocation objectForKey:@"city"], [curLocation objectForKey:@"state"]];
    } else if ([[curLocation objectForKey:@"city"] length] && ![[curLocation objectForKey:@"country"] isEqual:@"US"]) {
        _lblCityState.hidden = YES;
    }
    _txtLocation.text = [curLocation objectForKey:@"usertext"];
}

- (IBAction)checkEnteredLocation:(id)sender {
    NSLog(@"checkEnteredLocation");
    // called when user has entered a new location value
    // check that entered location code is valid
    // if entry is an integer, run zip validation rules. Don't check zip for string entries
    NSString *enteredLocation = _txtLocation.text;
    int integerZip = (int)[enteredLocation integerValue];
    BOOL isValidZip = (integerZip > 0) ? [Location isValidZip:integerZip] : 0;
    
    if ((isValidZip || integerZip == 0) && ![enteredLocation isEqualToString:[curLocation objectForKey:@"usertext"]]) {
NSLog(@"checkEnteredLocation for new");
        // user entered a string or new zip.
        // get location info from geocoder
        
#ifdef DEVLOCATION
        [curLocation setValue:enteredLocation forKey:@"usertext"];
#else
        [self forwardGeocode:enteredLocation];
#endif

    }
 
}

#pragma mark Text Field methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    if (textField == _txtSearch) {
        [self searchJobs:_btnSearch];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == _txtLocation && [self isNewLocation:_txtLocation.text]) {
        // new location entered
        [self checkEnteredLocation:textField];
	}
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    // Create a custom section header view.
    UIControl *headerView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 25)] ;
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 300, 20)];
    UILabel *headerLine = [[UILabel alloc] initWithFrame:CGRectMake(5, 23, 300, 2)];
    headerLabel.text = NSLocalizedString(@"STR_RECENT", nil);
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLine.backgroundColor = [UIColor lightGrayColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:16];
    [headerView addSubview:headerLabel];
    [headerView addSubview:headerLine];
    
    return headerView;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [searches count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSArray *tmpSearch = [[searches objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"];

	cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", [tmpSearch objectAtIndex:0], [tmpSearch objectAtIndex:1]];
    		
	cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}


// Table row selected 
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
        NSArray *tmpSearch = [[searches objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"];
        _txtSearch.text = [tmpSearch objectAtIndex:0];
        [curLocation setValue:[tmpSearch objectAtIndex:1] forKey:@"usertext"];
        _txtLocation.text = [tmpSearch objectAtIndex:1];
        // TODO add check for users w/ o locale setting
        [curLocation setValue:[tmpSearch objectAtIndex:2] forKey:@"country"];
        [self searchJobs:nil];
	
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:(BOOL)animated];

    [Location setDefaultLocation:curLocation];
}
- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    [super viewDidUnload];
}


@end
