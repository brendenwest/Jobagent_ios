//
//  Cities.h
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@class AppDelegate;

@interface Cities : UITableViewController {

    AppDelegate *appDelegate;

	NSArray *placemarks;
	
}

@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSArray *placemarks;


@end