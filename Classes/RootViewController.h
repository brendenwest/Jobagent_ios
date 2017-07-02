//
//  RootViewController.h
//  jobagent
//
//  Created by mac on 2/23/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "jobagent-Swift.h"

@class AppDelegate, Cities;

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate > {
    
	Cities *_citiesVC; // for linking to list of cities w/ zips
    
}


@property (nonatomic, strong) IBOutlet UITextField *txtSearch;
@property (nonatomic, strong) IBOutlet UITextField *txtLocation;
@property (nonatomic, strong) IBOutlet UIButton *btnSearch;
@property (nonatomic, strong) IBOutlet UILabel *lblCityState;
@property (nonatomic, strong) IBOutlet UITableView *tblRecent;

- (IBAction)searchJobs:(id)sender;
- (IBAction)checkEnteredLocation:(id)sender;
    
@end
