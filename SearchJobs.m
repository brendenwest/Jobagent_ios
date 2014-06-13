//
//  SearchJobs.m
//  jobagent
//
//  Created by mac on 3/12/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "SearchJobs.h"
#import "JobDetail.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "GADBannerView.h"
#import "Common.h"

@implementation SearchJobs

@synthesize txtSearch, prevSearch, lblSearch, curLocation, curLocale, btnJobSite, uiLoading, siteList, tableView;
@synthesize feedNew, currentSection, jobsAll, jobsForSite, appDelegate;
@synthesize jobDetailVC = _jobDetailVC;


- (IBAction)switchJobSite:(id)sender {
    NSString *tag = [[siteList objectAtIndex:btnJobSite.selectedSegmentIndex] valueForKey:@"tag"];
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF.link contains[c] '%@'",tag]];
   
    jobsForSite = [self.jobsAll filteredArrayUsingPredicate:sPredicate];
    
    if ([self.jobsAll count] > 0) {
        [self.tableView reloadData]; 
    } else {
		UIAlertView *noJobs = [[UIAlertView alloc] initWithTitle:@"No Listings" message:@"No listings for this site" delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
		[noJobs show];        
    }
}
    
- (void)viewDidAppear:(BOOL)animated {
    NSString *newSearch = [NSString stringWithFormat:@"%@+%@",txtSearch, curLocation];
    if (txtSearch && ![newSearch isEqualToString:prevSearch]) {
        prevSearch = newSearch;
		[self requestJobs:nil];
	} else {
        [uiLoading stopAnimating];
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
	    
	self.title = @"Search Results";
	tableView.hidden = YES;
    btnJobSite.hidden = YES;
    uiLoading.hidden = NO;
    [uiLoading startAnimating];

    if (IS_OS_7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    siteList = [NSArray arrayWithObjects:
                [NSDictionary dictionaryWithObjectsAndKeys:
                 @"CareerBuilder", @"displayName" , @"http://www.careerbuilder.com", @"domain", @"careerbuilder", @"tag", nil],
                [NSDictionary dictionaryWithObjectsAndKeys:
                 @"Jobs by ", @"displayName", @"http://www.indeed.com", @"domain", @"indeed", @"tag", nil],
                [NSDictionary dictionaryWithObjectsAndKeys:
                 @"classifieds by Oodle", @"displayName", @"http://www.oodle.com", @"domain", @"oodle", @"tag", nil],
                [NSDictionary dictionaryWithObjectsAndKeys:
                 @"LinkUp", @"displayName", @"http://www.linkup.com", @"domain", @"linkup", @"tag", nil], nil];
    
	appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

	tableView.dataSource = self;
	
	// create a custom navigation bar button and set it to always say "Back"
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
     

}


#pragma mark Search button clicked

- (void)requestJobs:(id)sender
{
	NSString *query = [txtSearch stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *locationEncoded = [curLocation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    
    NSString *searchUrl;
    #ifdef DEVAPI
        searchUrl = [NSString stringWithFormat:@"%@%@",[appDelegate.configuration objectForKey:@"apiDomainDev"],[appDelegate.configuration objectForKey:@"searchUrl"]];
    #else
        searchUrl = [NSString stringWithFormat:@"%@%@",[appDelegate.configuration objectForKey:@"apiDomainProd"],[appDelegate.configuration objectForKey:@"searchUrl"]];
    #endif
    
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<kw>" withString:query];
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<location>" withString:locationEncoded];
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<max>" withString:[settings stringForKey:@"maxResults"]];
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<age>" withString:[settings stringForKey:@"ageResults"]];
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<distance>" withString:[settings stringForKey:@"distanceResults"]];
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<country>" withString:curLocale];
    
    NSURL *url = [NSURL URLWithString:searchUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.jobsAll = [responseObject objectForKey:@"jobs"];
        
        [self switchJobSite:nil];

        tableView.hidden = NO;
        btnJobSite.hidden = NO;
        [uiLoading stopAnimating];
     
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed: Status Code: %ld", (long)operation.response.statusCode);
    }];
    [operation start];
    
}


#pragma mark Table view methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    section = btnJobSite.selectedSegmentIndex; // override default value
    // Creates a header view.
    NSInteger labelWidth = (section == 1) ? 65 : 300;
    UIControl *headerView = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, 320, 25)] ;
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, labelWidth, 20)];
    headerLabel.text = [[siteList objectAtIndex:section] valueForKey:@"displayName"];
    headerLabel.textColor = [UIColor darkGrayColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:14];
    UIControl *headerBorder = [[UIControl alloc] initWithFrame:CGRectMake(0, 24, 320, 1)];
    headerBorder.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:headerLabel];

    
    if (section == 1) {
        
        CGRect imageRect = CGRectMake(labelWidth+1, 5.0f, 54.0f, 20.0f);
        UIImageView *headerImage = [[UIImageView alloc] initWithFrame:imageRect];
        UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"indeed_logo" ofType: @"gif"]];
        [headerImage setImage:image];
        headerImage.opaque = YES;
        
        [headerView addSubview:headerImage];
        [headerView addTarget:self action:@selector(linkToSource:) forControlEvents:UIControlEventTouchDown];
    }
    [headerView addSubview:headerBorder];
    return headerView;
}


- (void)linkToSource:(id)sender {
    //[[siteList objectAtIndex:currentSection] valueForKey:@"domain"]
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[siteList objectAtIndex:currentSection] valueForKey:@"domain"]]];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return [[self.jobsAll objectAtIndex:btnJobSite.selectedSegmentIndex] count];
    return [jobsForSite count];
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    NSArray *tmpJob = [jobsForSite objectAtIndex:indexPath.row];
    
	cell.textLabel.text = [tmpJob valueForKey:@"title"];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ ~ %@ ~ %@",[Common getShortDate:[tmpJob valueForKey:@"pubdate"]], [tmpJob valueForKey:@"company"], [tmpJob valueForKey:@"location"]];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if(self.jobDetailVC == nil)
		self.jobDetailVC = [[JobDetail alloc] initWithNibName:@"JobDetail" bundle:nil];
    
    NSDictionary *tmpJob = [jobsForSite objectAtIndex:indexPath.row];
    
    // Convert date string to same format as used by Core Data
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'000'Z'"]; // "2014-06-13T03:53:35.000Z"
    NSDate *date = [dateFormat dateFromString:[tmpJob valueForKey:@"pubdate"]];
    
	self.jobDetailVC.aJob = [tmpJob mutableCopy];
    // job feeds use 'pubdate' key but JobDetail uses 'date' key since user can modify the value
    [self.jobDetailVC.aJob setValue:date forKey:@"date"];
	[self.navigationController pushViewController:self.jobDetailVC animated:YES];
	
}


- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    lblSearch.text = [NSString stringWithFormat:@"Job listings for '%@' in %@",txtSearch,curLocation];

    // Google ads
    // Create a view of the standard size at the bottom of the screen.
    bannerView_ = [[GADBannerView alloc]
                   initWithFrame:CGRectMake(0.0, 
                                            self.view.frame.size.height -
                                            GAD_SIZE_320x50.height,
                                            GAD_SIZE_320x50.width,
                                            GAD_SIZE_320x50.height)];
    
    // Specify the ad's "unit identifier." This is your AdMob Publisher ID.
    bannerView_.adUnitID = @"a14f6e8f0c6d11b";
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    GADRequest *request = [GADRequest request];
    request.testDevices = [NSArray arrayWithObjects:
                           GAD_SIMULATOR_ID,                             // Simulator
                           @"577bade797151a79f2a87a61c9b5b30c697fee41",  // Test iOS Device
                           nil];
    
    // pass current location info on ad request
    [request setLocationWithDescription:[NSString stringWithFormat:@"%@ US",[[NSUserDefaults standardUserDefaults] stringForKey:@"postalcode"]]];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:request]; 

    // Log pageview w/ Google Analytics
    [appDelegate trackPVFull:@"SearchJobs" :@"search term" :@"search" :txtSearch];
}


@end

