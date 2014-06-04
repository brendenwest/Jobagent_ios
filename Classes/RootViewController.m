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
#import "Tips.h"
#import "XMLParse.h"
#import "GADBannerView.h"
#import "GADRequest.h"


#define kSampleAdUnitID @"a14f6e8f0c6d11b"
//#define GAD_SIMULATOR_ID @"577bade797151a79f2a87a61c9b5b30c697fee41"

@interface RootViewController ()

@property(nonatomic, weak) AppDelegate *delegate;

@end

@implementation RootViewController

@synthesize txtSearch, txtLocation, curZip, curLat, curLng, tblRecent, btnSearch, btnTips, userSettings;
@synthesize searches, del;


// 98052 = 47.615471,-122.207221


- (IBAction)readTips:(id)sender
{
    
    // load 'Tips' screen
    _tipsVC = [[Tips alloc] init];

    // temporarily set title to 'Back' for appearance on Results view
    self.title = @"Back";
    
    [self.navigationController pushViewController:_tipsVC animated:YES];

}

- (IBAction)backgroundTouched:(id)sender
{
    [txtSearch resignFirstResponder];
    [txtLocation resignFirstResponder];
    
}


// execute search. 
- (void)viewSearchResults {
    
    // save this search
    NSString *thisSearch = [NSString stringWithFormat:@"%@|%@|%@|%@",txtSearch.text,txtLocation.text, curLat, curLng];
    if (![searches containsObject:thisSearch]) {
        [searches insertObject:thisSearch atIndex:0];
        [self.userSettings setValue:searches forKey:@"searches"];
    }
    
    // execute search
    if(_searchVC == nil)
        _searchVC = [[SearchJobs alloc] initWithNibName:nil bundle:nil];
    _searchVC.txtSearch = txtSearch.text;
    _searchVC.txtZip = txtLocation.text;
    
    // temporarily set title to 'Back' for appearance on Results view
    self.title = @"Back";
    
    [self.navigationController pushViewController:_searchVC animated:YES];
	
}

- (IBAction)searchJobs:(id)sender {

    // close keyboard, regardless of which text field was active
    [txtSearch resignFirstResponder];
    [txtLocation resignFirstResponder];

    // check if location field changed
    if (![del connectedToNetwork]) {
        UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Network connection \nappears to be offline" delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
        [noNetworkAlert show];
    } else if (![txtLocation.text length] || ![txtSearch.text length]) {
        UIAlertView *emptyFieldAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Be sure to enter a \nsearch term and zipcode" delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
		[emptyFieldAlert show];
    } else {

        [self checkZip:txtLocation];
        // Don't fire job search if user entered city name instead of zip code
        if ([txtLocation.text isEqualToString:[self.userSettings objectForKey:@"postalcode"]]) {
            [self viewSearchResults];
        }
    }
}



// user clicked on recent searches
- (IBAction)recentSearches:(id)sender {
	txtSearch.text = nil;
	[txtSearch resignFirstResponder];
}



- (void)getAd {
    // Create ad view of the standard size at the bottom of the screen. Account for nav bar & tab bar heights
    // Available AdSize constants are explained in GADAdSize.h.
    
    double statusBarOffset = (IS_OS_7_OR_LATER) ? 20.0 : 0;
    CGPoint origin = CGPointMake(0.0,
                                 self.view.frame.size.height -
                                 CGSizeFromGADAdSize(kGADAdSizeBanner).height-self.navigationController.navigationBar.frame.size.height-self.tabBarController.tabBar.frame.size.height - statusBarOffset);
    
    // Use predefined GADAdSize constants to define the GADBannerView.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:origin];
    
    // Specify the ad unit ID.
    bannerView_.adUnitID = kSampleAdUnitID;
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
}

- (void)getUserLocation {
    // get location for first-time user
    
    NSLog(@"getting location");
    //[activityIndicator startAnimating];
    
    _locationManager = [[CLLocationManager alloc] init];
    if (![CLLocationManager locationServicesEnabled])
    {   //show an alert
        
    } else {
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        [_locationManager startUpdatingLocation];
        _startLocation = nil;
    }
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
	del = (AppDelegate *)[UIApplication sharedApplication].delegate;

	if (userSettings == nil)
	{ 
		self.userSettings = [(AppDelegate *)[[UIApplication sharedApplication] delegate] userSettings]; 
	}

    // default settings for testing
//    [self.userSettings setValue:@"98052" forKey:@"postalcode"];
//    [self.userSettings setValue:@"47.68495" forKey:@"lat"];
//    [self.userSettings setValue:@"-122.28759" forKey:@"lng"];

//    [self.userSettings setValue:@"" forKey:@"postalcode"]; // clear zip for testing

    // check user's location
	if (![[self.userSettings valueForKey:@"postalcode"] length] && [del connectedToNetwork]) { 
        [self getUserLocation];
        
	} else if ([[self.userSettings valueForKey:@"postalcode"] length]) {
        self.txtLocation.text = [self.userSettings objectForKey:@"postalcode"];
        curZip = [self.userSettings objectForKey:@"postalcode"];
        curLat = [self.userSettings objectForKey:@"lat"];
        curLng = [self.userSettings objectForKey:@"lng"];

	}


	if ([[self.userSettings objectForKey:@"searches"] count] > 0) {
        // use recent searches
		searches = [[NSMutableArray alloc] initWithArray:[self.userSettings objectForKey:@"searches"]];
		if (![txtSearch.text length]) {
			txtSearch.text = [[searches objectAtIndex:0] substringToIndex:[[searches objectAtIndex:0] rangeOfString:@"|"].location];
		}
	} else {
		searches = [[NSMutableArray alloc] init];
	}
    
    [self getAd];
    
}

- (void)viewWillAppear:(BOOL)animated {

    self.title = @"Job Agent";

    if ([txtLocation.text length] && ![[self.userSettings objectForKey:@"postalcode"] isEqualToString:txtLocation.text]) {
        // returning from city selection
        txtLocation.text = [self.userSettings objectForKey:@"postalcode"];
    }

    
	tblRecent.dataSource = self;

    if ([searches count] > 0) {
        tblRecent.hidden = NO;
        [self.tblRecent reloadData];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    
    [del trackPV:@"Home"]; // Google Analytics call needs to happen here, or initial launch event not recorded
}

#pragma mark GADRequest generation

- (GADRequest *)request {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad if on the simulator as well as any test devices
    request.testDevices = @[ GAD_SIMULATOR_ID ];

    // pass current location info on ad request
    [request setLocationWithDescription:[NSString stringWithFormat:@"%@ US",[self.userSettings objectForKey:@"postalcode"]]];

    return request;
}

#pragma mark GADBannerViewDelegate implementation

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Received ad successfully");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
}


#pragma mark Location Manager methods

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError*)error {

    NSLog(@"Location check failed %@",error);
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation {

    NSLog(@"got location");
    
    if (_startLocation == nil || _startLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
        _startLocation = newLocation;
        
        if (newLocation.horizontalAccuracy <= _locationManager.desiredAccuracy) {
            
            // reverse Geocode the lat-long
            [self performCoordinateGeocode:newLocation];
            
            [_locationManager stopUpdatingLocation];
            _locationManager.delegate = nil;

        }
    }


}


- (void)performCoordinateGeocode:(CLLocation *)location
{
    NSLog(@"Geocoding for: %@", location);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            NSLog(@"Geocode failed with error: %@", error);
            return;
        }

        CLPlacemark *placemark = [placemarks objectAtIndex:0];
        [self setUserLocation:placemark :placemark.region.center.latitude :placemark.region.center.longitude];
        
    }];
}


- (void)forwardGeocode:(NSString *)placename
{
    NSLog(@"placename %@",placename);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:placename completionHandler:^(NSArray *placemarks, NSError *error) {
        //Error checking
        
        if ([placemarks count] == 1) { // one city returned. set location accordingly
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSLog(@"one location found %@",placemark);
            CLLocation *loc = [[CLLocation alloc] initWithLatitude:placemark.region.center.latitude longitude:placemark.region.center.longitude];
            [geocoder reverseGeocodeLocation:loc completionHandler:
             ^(NSArray* placemarks, NSError* error){
                 if ([placemarks count] > 0)
                 {
                     NSLog(@"reverse geocode found one location %@",[placemarks objectAtIndex:0]);
                     CLPlacemark *newPlacemark = [placemarks objectAtIndex:0];
                     [self setUserLocation:newPlacemark :loc.coordinate.latitude :loc.coordinate.longitude];
                     
                 }
             }];
        } else if ([placemarks count] > 1) { //
            NSLog(@"> one location found");
                if(_citiesVC == nil)
                    _citiesVC = [[Cities alloc] initWithNibName:nil bundle:nil];
                _citiesVC.placemarks = placemarks;
               [self.navigationController pushViewController:_citiesVC animated:YES];
        }

    }];

}

- (void)setUserLocation:(CLPlacemark *)placemark :(double)latitude :(double)longitude {

    // populate user settings based on new geocode values
    [self.userSettings setValue:(NSString *)placemark.locality forKey:@"city"];
    [self.userSettings setValue:(NSString *)placemark.administrativeArea forKey:@"state"];
    [self.userSettings setValue:(NSString *)placemark.ISOcountryCode forKey:@"country"];
    [self.userSettings setValue:(NSString *)placemark.postalCode forKey:@"postalcode"];
    [self.userSettings setValue:(NSString *)[NSString stringWithFormat:@"%.4F", latitude] forKey:@"lat"];
    [self.userSettings setValue:(NSString *)[NSString stringWithFormat:@"%.4F", longitude] forKey:@"lng"];
    
    [self updateUILocation];

}

- (void)updateUILocation {
    // update current location values in UI
    self.txtLocation.text = [self.userSettings objectForKey:@"postalcode"];
    curZip = [self.userSettings objectForKey:@"postalcode"];
    curLat = [self.userSettings objectForKey:@"lat"];
    curLng = [self.userSettings objectForKey:@"lng"];
    
}

- (IBAction)checkZip:(id)sender {
    // check that entered zip code is valid
    NSString *enteredLocation = txtLocation.text;
    NSLog(@"entered location %@",enteredLocation);
        NSInteger intZip = [enteredLocation integerValue];
        BOOL validZip = intZip > 9999 && intZip < 100000; // US 5-digit zip

        if (!validZip || ![enteredLocation isEqualToString:curZip]) {
            // user entered a string or new zip.
            // get location info from geocoder
            [self forwardGeocode:enteredLocation];
        }
 
}

#pragma mark Text Field methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == txtLocation && textField.text != [userSettings objectForKey:@"postalcode"]) {
        // new location entered
        [self checkZip:textField];
    } else if (textField == txtSearch) {
		[self searchJobs:btnSearch];
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
    headerLabel.text = @"Recent Searches";
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
    if ([del connectedToNetwork]) {
        NSArray *tmpSearch = [[searches objectAtIndex:indexPath.row] componentsSeparatedByString:@"|"];
        txtSearch.text = [tmpSearch objectAtIndex:0];
        [self viewSearchResults];
    } else {
        UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Network connection \nappears to be offline" delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
        [noNetworkAlert show];        
    }
	
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


@end
