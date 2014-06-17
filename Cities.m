//
//  Cities.m
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "Cities.h"
#import "AppDelegate.h"

@implementation Cities

@synthesize appDelegate, placemarks;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"STR_TITLE_LOCATIONS", nil);

    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = NSLocalizedString(@"STR_BTN_BACK", nil);
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];

    [appDelegate trackPV:self.title];

}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

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



#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Location matches";
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [placemarks count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
	
	NSString *cityTmp = [[placemarks objectAtIndex:indexPath.row] valueForKey:@"locality"];
	NSString *state = [[placemarks objectAtIndex:indexPath.row] valueForKey:@"administrativeArea"];

	cell.textLabel.text = [NSString stringWithFormat:@"%@, %@", cityTmp, state];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// add selected place to user settings and go back to job listings

    CLPlacemark *placemark = [placemarks objectAtIndex:indexPath.row];
    NSLog(@"getting zip for : %@", placemark);

//NSLog(@"place %.4F - %.4F", placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);
    
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:placemark.region.center.latitude longitude:placemark.region.center.longitude];
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
        [geocoder reverseGeocodeLocation:loc completionHandler:
         ^(NSArray* placemarksForZip, NSError* error){
             if (error){
                 NSLog(@"Geocode failed with error: %@", error);
                 return;
             }
             NSLog(@"Received placemarks: %@", placemarksForZip);
             CLPlacemark *newPlacemark = [placemarksForZip objectAtIndex:0];
             
             NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
             [defaults setObject:(NSString *)newPlacemark.postalCode forKey:@"postalcode"];
             [defaults setObject:(NSString *)newPlacemark.locality forKey:@"city"];
             [defaults setObject:(NSString *)newPlacemark.administrativeArea forKey:@"state"];
             [defaults setObject:(NSString *)newPlacemark.ISOcountryCode forKey:@"countryCode"];
             [defaults synchronize];
             
             //    NSLog(@"lat-long is %.4F - %.4F", placemark.region.center.latitude,placemark.region.center.longitude);
             [self.navigationController popViewControllerAnimated:YES];
         }];
    
}


@end

