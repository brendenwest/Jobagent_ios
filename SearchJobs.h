//
//  JobSearch2.h
//  jobagent
//
//  Created by mac on 3/12/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GADBannerView.h"


@class AppDelegate, JobDetail;

@interface SearchJobs : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate> {

	AppDelegate *del;
	NSString *txtSearch;
	NSString *prevSearch;
	NSString *txtZip;
		
    UILabel *lblSearch;
	UITableView	*tableView;
	IBOutlet UISegmentedControl *btnJobSite;
	IBOutlet UIActivityIndicatorView *uiLoading;
	
	JobDetail *_jobDetailVC; // for linking to job details
	
	NSMutableDictionary *userSettings;
	
    // Google ad instance
	GADBannerView *bannerView_;
}

@property (nonatomic, strong) NSString *txtSearch;
@property (nonatomic, strong) NSString *prevSearch;
@property (nonatomic, strong) NSString *txtZip;

@property (nonatomic, strong) IBOutlet UILabel *lblSearch;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnJobSite;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *uiLoading;

@property (nonatomic, strong) IBOutlet JobDetail *jobDetailVC;

@property (nonatomic, strong) AppDelegate *del;
@property (nonatomic, strong) NSArray *siteList;
@property (nonatomic, strong) NSString *feedNew;
@property (nonatomic, strong) NSNumber *currentSection;
@property (nonatomic, strong) NSMutableArray *jobsAll;
@property (nonatomic, strong) NSArray *jobsForSite;


- (IBAction)requestJobs:(id)sender;
- (IBAction)switchJobSite:(id)sender;     // for segmented control actions

@end
