//
//  SearchJobs.m
//  jobagent
//
//  Created by mac on 3/12/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "SearchJobs.h"
#import "AppDelegate.h"
#import "AFNetworking.h"
#import "Ads.h"
#import "Common.h"
#import "jobagent-Swift.h"

@implementation SearchJobs


- (IBAction)switchJobSite:(id)sender {
    NSString *tag = [[siteList objectAtIndex:_btnJobSite.selectedSegmentIndex] valueForKey:@"tag"];
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"SELF.link contains[c] '%@'",tag]];
   
    jobsForSite = [jobsAll filteredArrayUsingPredicate:sPredicate];
    
    if ([jobsAll count] > 0) {
        [_tableView reloadData];
    } else {
		UIAlertView *noJobs = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"STR_NO_LISTINGS", nil) delegate:NULL cancelButtonTitle:@"Ok" otherButtonTitles:NULL];
		[noJobs show];        
    }
}
    
#pragma mark View methods

- (void)viewDidLoad {
    [super viewDidLoad];
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

}

- (void)uiStateLoading:(BOOL)isLoading {
    if (isLoading) {
        _tableView.hidden = YES;
        _btnJobSite.hidden = YES;
        _uiLoading.hidden = NO;
        [_uiLoading startAnimating];
    } else {
        // table finished loading
        _tableView.hidden = NO;
        [_btnJobSite setEnabled:[_curLocale isEqualToString:@"US"] forSegmentAtIndex:2];
        [_btnJobSite setEnabled:[_curLocale isEqualToString:@"US"] forSegmentAtIndex:3];
        _btnJobSite.hidden = NO;
        [_uiLoading stopAnimating];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *newSearch = [NSString stringWithFormat:@"%@+%@",_keyword, _curLocation];
    [self uiStateLoading:TRUE];
    [appDelegate setPreviousSearch:newSearch];
    [self requestJobs:nil];
    
    _lblSearch.text = [NSString stringWithFormat:NSLocalizedString(@"STR_RESULTS_FOR", nil),_keyword,_curLocation];
    
    // Log pageview w/ Google Analytics
    [appDelegate trackPVFull:@"SearchJobs" :@"search term" :@"search" :_keyword];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}


#pragma mark Search button clicked

- (void)requestJobs:(id)sender
{
	NSString *query = _keyword;
    if (![query integerValue]) {
        query = [query stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    }

    NSString *locationEncoded = [_curLocation stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
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
    searchUrl = [searchUrl stringByReplacingOccurrencesOfString:@"<country>" withString:_curLocale];
  
    //AFNetworking asynchronous url request
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  [manager GET:searchUrl parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
    NSLog(@"JSON: %@", responseObject);
    jobsAll = [responseObject objectForKey:@"jobs"];
    
    [self switchJobSite:nil];
    [self uiStateLoading:FALSE];
    [Ads getAd:self];
  } failure:^(NSURLSessionTask *operation, NSError *error) {
    NSLog(@"Error: %@", error);
  }];
    
}


#pragma mark Table view methods

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    section = _btnJobSite.selectedSegmentIndex; // override default value
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
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[siteList objectAtIndex:currentSection] valueForKey:@"domain"]]];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [jobsForSite count];
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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


- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self performSegueWithIdentifier: @"showJobDetail" sender:tView];

}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showJobDetail"]) {

        NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
        NSMutableDictionary *tmpJob = [[jobsForSite objectAtIndex:indexPath.row] mutableCopy];

        // job feeds use 'pubdate' key but JobDetail uses 'date' key since user can modify the value
        // Convert date string to same format as used by Core Data
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'000'Z'"]; // "2014-06-13T03:53:35.000Z"
        NSDate *date = [dateFormat dateFromString:[tmpJob valueForKey:@"pubdate"]];
        [tmpJob setObject:date forKey:@"date"];
        
        // transfer job description into 'notes' property
        [tmpJob setObject:[tmpJob valueForKey:@"description"] forKey:@"notes"];

//        [[segue destinationViewController] setAJob:[tmpJob mutableCopy]];

    }
}




@end

