//
//  Cities.m
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "Cities.h"
#import "AppDelegate.h"
#import "jobagent-Swift.h"

@implementation Cities

@synthesize appDelegate, placemarks;


- (void)viewDidLoad {
    [super viewDidLoad];
	
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	
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
    [super viewDidUnload];
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
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:placemark.location.coordinate.latitude
                                                 longitude:placemark.location.coordinate.longitude];
    
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
        [geocoder reverseGeocodeLocation:loc completionHandler:
         ^(NSArray* placemarksForZip, NSError* error){
             if (error){
                 NSLog(@"Geocode failed with error: %@", error);
                 return;
             }
             NSLog(@"Received placemarks: %@", placemarksForZip);
             CLPlacemark *newPlacemark = [placemarksForZip objectAtIndex:0];

             [Location setDefaultLocation:newPlacemark];
             
             [self.navigationController popViewControllerAnimated:YES];
         }];
    
}


@end

