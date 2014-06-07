//
//  RootViewController.h
//  jobagent
//
//  Created by mac on 2/23/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GADBannerView.h"

@class AppDelegate, SearchJobs, Tips, Cities;

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate, CLLocationManagerDelegate > {

	AppDelegate *appDelegate;

	IBOutlet UITextField *txtSearch;
	IBOutlet UITextField *txtLocation;
    NSString *curLocation;
    NSString *curLocale;
    
	IBOutlet UIButton *btnSearch;
	IBOutlet UIButton *btnTips;
	IBOutlet UILabel *lblCityState;
	IBOutlet UITableView	*tblRecent;

	SearchJobs *_searchVC; // for linking to job details
	Tips *_tipsVC; // for linking to tips screen
	Cities *_citiesVC; // for linking to list of cities w/ zips

	NSMutableArray *searches;
    
    GADBannerView *bannerView_;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *startLocation;

@property (nonatomic, strong) IBOutlet UITextField *txtSearch;
@property (nonatomic, strong) IBOutlet UITextField *txtLocation;

@property (nonatomic, strong) NSString *curLocation;
@property (nonatomic, strong) NSString *curLocale;

@property (nonatomic, strong) IBOutlet UIButton *btnSearch;
@property (nonatomic, strong) IBOutlet UIButton *btnTips;
@property (nonatomic, strong) IBOutlet UILabel *lblCityState;

@property (nonatomic, strong) IBOutlet UITableView *tblRecent;

@property (nonatomic, strong) AppDelegate *appDelegate;

@property (nonatomic, strong) NSMutableDictionary *userSettings;
@property (nonatomic, strong) NSMutableArray *searches;

- (GADRequest *)request;
- (IBAction)searchJobs:(id)sender;
- (IBAction)checkZip:(id)sender;
- (IBAction)recentSearches:(id)sender;
- (IBAction)backgroundTouched:(id)sender;
- (IBAction)readTips:(id)sender;

@end
