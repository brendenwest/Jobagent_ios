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

	AppDelegate *del;

	IBOutlet UITextField *txtSearch;
	IBOutlet UITextField *txtLocation;
    NSString *curZip;
    NSString *curLat;
    NSString *curLng;
    
	IBOutlet UIButton *btnSearch;
	IBOutlet UIButton *btnTips;
	IBOutlet UITableView	*tblRecent;

	SearchJobs *_searchVC; // for linking to job details
	Tips *_tipsVC; // for linking to tips screen
	Cities *_citiesVC; // for linking to list of cities w/ zips

	NSMutableDictionary *userSettings;
	NSMutableArray *searches;
    
    GADBannerView *bannerView_;
}

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *startLocation;

@property (nonatomic, strong) IBOutlet UITextField *txtSearch;
@property (nonatomic, strong) IBOutlet UITextField *txtLocation;

@property (nonatomic, strong) NSString *curZip;
@property (nonatomic, strong) NSString *curLat;
@property (nonatomic, strong) NSString *curLng;

@property (nonatomic, strong) IBOutlet UIButton *btnSearch;
@property (nonatomic, strong) IBOutlet UIButton *btnTips;

@property (nonatomic, strong) IBOutlet UITableView *tblRecent;

@property (nonatomic, strong) SearchJobs *searchVC;
@property (nonatomic, strong) Tips *tipsVC;
@property (nonatomic, strong) Cities *citiesVC;

@property (nonatomic, strong) AppDelegate *del;

@property (nonatomic, strong) NSMutableDictionary *userSettings;
@property (nonatomic, strong) NSMutableArray *searches;

- (GADRequest *)request;
- (IBAction)searchJobs:(id)sender;
- (IBAction)checkZip:(id)sender;
- (IBAction)recentSearches:(id)sender;
- (IBAction)backgroundTouched:(id)sender;
- (IBAction)readTips:(id)sender;

@end
