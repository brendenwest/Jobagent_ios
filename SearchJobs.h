//
//  JobSearch2.h
//  jobagent
//
//  Created by mac on 3/12/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AppDelegate, JobDetail;

@interface SearchJobs : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {

	AppDelegate *appDelegate;
				
	NSMutableDictionary *userSettings;
    NSString *prevSearch;
    NSArray *siteList;
    NSString *feedNew;
    NSNumber *currentSection;
    NSMutableArray *jobsAll;
    NSArray *jobsForSite;
	
}

// set from home screen
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSString *curLocation;
@property (nonatomic, strong) NSString *curLocale;

@property (nonatomic, strong) IBOutlet UILabel *lblSearch;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnJobSite;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *uiLoading;


- (IBAction)requestJobs:(id)sender;
- (IBAction)switchJobSite:(id)sender;     // for segmented control actions

@end
