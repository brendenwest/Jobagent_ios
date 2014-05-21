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

@synthesize del, placemarks, location;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Locations";

    del = (AppDelegate *)[UIApplication sharedApplication].delegate;
	
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.tableView reloadData];

    [del trackPV:self.title];

}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

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
	
	NSString *zip = [[placemarks objectAtIndex:indexPath.row] valueForKey:@"postalCode"];
	NSString *cityTmp = [[placemarks objectAtIndex:indexPath.row] valueForKey:@"locality"];
	NSString *state = [[placemarks objectAtIndex:indexPath.row] valueForKey:@"administrativeArea"];

//    NSLog(@"city, state, zip %@, %@ - %@", cityTmp, state, zip);

	cell.textLabel.text = [NSString stringWithFormat:@"%@, %@ - %@", cityTmp, state, zip];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	// add selected place to user settings and go back to job listings

    location = [placemarks objectAtIndex:indexPath.row];

//NSLog(@"place %.4F - %.4F", placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);

    [del.userSettings setValue:location.postalCode forKey:@"postalcode"];
    [del.userSettings setValue:[NSString stringWithFormat:@"%.4F",location.region.center.latitude] forKey:@"lat"];
    [del.userSettings setValue:[NSString stringWithFormat:@"%.4F",location.region.center.longitude] forKey:@"lng"];
    
//    NSLog(@"lat-long is %.4F - %.4F", placemark.region.center.latitude,placemark.region.center.longitude);
     [self.navigationController popViewControllerAnimated:YES];
	
}


@end

