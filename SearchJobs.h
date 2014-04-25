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

@interface SearchJobs : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate, GADBannerViewDelegate> {
	
    BOOL done;
    NSUInteger countOfParsedJobs;

	AppDelegate *del;
	NSString *txtSearch;
	NSString *prevSearch;
	NSString *txtZip;
	NSString *txtLat;
	NSString *txtLng;
		
	NSMutableArray *siteList;
    UILabel *lblSearch;
	UITableView	*tableView;
	IBOutlet UISegmentedControl *btnJobSite;
	IBOutlet UIActivityIndicatorView *uiLoading;
	
	JobDetail *_jobDetailVC; // for linking to job details
	
	NSString *feedNew;
	NSNumber *currentSection;
	NSMutableDictionary *userSettings;
	NSMutableArray *jobs;
	NSMutableArray *jobsAll;
	NSMutableArray *sectionHeaders;
	NSMutableDictionary *currentJob;
	UILocalizedIndexedCollation *theCollation;
	
    // Google ad instance
	GADBannerView *bannerView_;
}

@property (nonatomic, strong) NSString *txtSearch;
@property (nonatomic, strong) NSString *prevSearch;
@property (nonatomic, strong) NSString *txtZip;
@property (nonatomic, strong) NSString *txtLat;
@property (nonatomic, strong) NSString *txtLng;

@property (nonatomic, strong) IBOutlet UILabel *lblSearch;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnJobSite;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *uiLoading;

@property (nonatomic, strong) IBOutlet JobDetail *jobDetailVC;

@property (nonatomic, strong) AppDelegate *del;
@property (nonatomic, strong) NSMutableArray *siteList;
@property (nonatomic, strong) NSString *feedNew;
@property (nonatomic, strong) NSNumber *currentSection;
@property (nonatomic, strong) NSMutableArray *jobs;
@property (nonatomic, strong) NSMutableArray *jobsAll;
@property (nonatomic, strong) NSMutableArray *sectionHeaders;
@property (nonatomic, strong) NSMutableDictionary *currentJob;
@property (nonatomic, strong) UILocalizedIndexedCollation *theCollation;


- (IBAction)searchJobs:(id)sender;
- (IBAction)moreJobs:(id)sender;
- (IBAction)switchJobSite:(id)sender;     // for segmented control actions

@end
