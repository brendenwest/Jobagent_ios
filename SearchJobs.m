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
#import "XMLParse.h"
#import "GADBannerView.h"

static NSString *kSafariUA = @"Mozilla/5.0 (iPhone; CPU iPhone OS 5_0 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A334 Safari/7534.48.3";

@implementation SearchJobs

@synthesize txtSearch, prevSearch, lblSearch, txtZip, txtLat, txtLng, btnJobSite, uiLoading, siteList, tableView;
@synthesize feedNew, currentSection, jobs, jobsAll, sectionHeaders, currentJob, theCollation, del;
@synthesize jobDetailVC = _jobDetailVC;


- (IBAction)moreJobs:(id)sender {
	// link to full site for selected search-engine 
	NSArray *aSite = [[siteList objectAtIndex:[currentSection integerValue]] componentsSeparatedByString:@"^"];	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[aSite objectAtIndex:1]]];		
}

- (IBAction)switchJobSite:(id)sender {
    if (btnJobSite.selectedSegmentIndex <= [self.jobsAll count]-1) {
        [self.tableView reloadData]; 
    } else {
		UIAlertView *noJobs = [[UIAlertView alloc] initWithTitle:@"No Listings" message:@"No listings for this site" delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
		[noJobs show];        
    }
}
    
- (void)viewDidAppear:(BOOL)animated {
    NSString *newSearch = [NSString stringWithFormat:@"%@+%@",txtSearch, txtZip];
    if (txtSearch && ![newSearch isEqualToString:prevSearch]) {
        prevSearch = newSearch;
		[self searchJobs:nil];
	}	
    [uiLoading stopAnimating];

}

- (void)viewDidLoad {
    [super viewDidLoad];
	    
	self.title = @"Search Results";
	tableView.hidden = YES;
    btnJobSite.hidden = YES;
    uiLoading.hidden = NO;
    [uiLoading startAnimating];

    if (IS_OS_7_OR_LATER) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
// NSString* encodedUrl = [url stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
	// format is name, url, feed
	self.siteList = [NSMutableArray arrayWithObjects: 

                     @"CareerBuilder^http://www.careerbuilder.com^http://api.careerbuilder.com/v1/jobsearch?DeveloperKey=WD1B7QV6MZZXBTC2CT7K&Keywords=<JOBTYPE>&Location=<ZIPCODE>&OrderBy=Date", 
                     @"Jobs by ^http://www.indeed.com^http://api.indeed.com/ads/apisearch?publisher=4401016323531060&q=<JOBTYPE>&l=<ZIPCODE>&sort=date&radius=&st=&jt=&start=&limit=30&fromage=30&filter=&latlong=0&co=us&chnl=&userip=97.74.215.83&useragent=safari&v=2",
                     @"classifieds by Oodle^http://www.oodle.com^http://api.oodle.com/api/v2/listings?key=BE3A6CD6445D&region=usa&location=<ZIPCODE>&category=job&q=<JOBTYPE>&sort=ctime_reverse&num=30",
                    @"LinkUp^http://www.linkup.com^http://www.linkup.com/developers/v-1/search-handler.js?api_key=131a8858030d3b157cdb5221648eb155&embedded_search_key=0712dee93e7e15ba5a2c52c1c25de159&orig_ip=97.74.215.83&keyword=<JOBTYPE>&location=<ZIPCODE>&distance=10&sort=d",
					 nil];
	
	del = (AppDelegate *)[UIApplication sharedApplication].delegate;

    theCollation = [UILocalizedIndexedCollation currentCollation];
	tableView.dataSource = self;
	

	// create a custom navigation bar button and set it to always say "Back"
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
     

}


#pragma mark job functions
/** split job title and company **/
- (NSArray *)getJobAndCompany:(NSString *)jobtitle {
	if ([jobtitle rangeOfString:@" at "].length > 0) { // SimplyHired
		return [jobtitle componentsSeparatedByString:@" at "];	
	} else {
		return [jobtitle componentsSeparatedByString:@" - "];	
	}
}

#pragma mark Search button clicked

- (void)searchJobs:(id)sender
{ 
		
	NSString *query = [txtSearch stringByReplacingOccurrencesOfString:@" " withString:@"+"];
	
	jobsAll = [[NSMutableArray alloc] init];
	sectionHeaders = [[NSMutableArray alloc] init];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];

	for (int i = 0; i < [siteList count]; i++) {
		NSArray *aSite = [[siteList objectAtIndex:i] componentsSeparatedByString:@"^"];
						
		feedNew = [[aSite objectAtIndex:2] stringByReplacingOccurrencesOfString:@"<JOBTYPE>" withString:query];	

        // format DICE query
		if ([feedNew rangeOfString:@"dice"].location != NSNotFound) { //Dice
			NSString *latlong = [NSString stringWithFormat:@"%@,%@",txtLat,txtLng];
			feedNew = [feedNew stringByReplacingOccurrencesOfString:@"<LATLONG>" withString:latlong];
			feedNew = [feedNew stringByReplacingOccurrencesOfString:@" " withString:@"%20"];	// for Dice
			feedNew = [feedNew stringByReplacingOccurrencesOfString:@"|" withString:@"%7c"];	// for Dice

        }
		else {
			feedNew = [feedNew stringByReplacingOccurrencesOfString:@"<ZIPCODE>" withString:txtZip];
		}
//  NSLog(@"url = %@",feedNew);
        // Create the XML parser    
        NSArray	*ignoreListArray =  [NSArray arrayWithObjects: 
                                     @"/oodle_response/current", @"/oodle_response/meta", nil];
        NSArray	*propertyListArray = [NSArray arrayWithObjects: 
                                      @"/rss/channel/item/title",
                                      @"/rss/channel/item/link",
                                      @"/rss/channel/item/description",
                                      @"/rss/channel/item/pubDate",
                                      @"/rss/channel/item/source",

                                      // indeeed
                                      @"/response/results/result/jobtitle",
                                      @"/response/results/result/company",
                                      @"/response/results/result/city",
                                      @"/response/results/result/date",
                                      @"/response/results/result/snippet",
                                      @"/response/results/result/url",
                                      @"/response/results/result/formattedLocation",

                                      // careerbuilder
                                      @"/ResponseJobSearch/Results/JobSearchResult/Company",
                                      @"/ResponseJobSearch/Results/JobSearchResult/JobDetailsURL",
                                      @"/ResponseJobSearch/Results/JobSearchResult/Location",
                                      @"/ResponseJobSearch/Results/JobSearchResult/PostedDate",
                                      @"/ResponseJobSearch/Results/JobSearchResult/JobTitle",
                                      @"/ResponseJobSearch/Results/JobSearchResult/DescriptionTeaser",
                                      @"/ResponseJobSearch/Results/JobSearchResult/EmploymentType",
                                      @"/ResponseJobSearch/Results/JobSearchResult/Pay",

                                      // Oodle
                                      @"/oodle_response/listings/element/title",
                                      @"/oodle_response/listings/element/body",
                                      @"/oodle_response/listings/element/url",
                                      @"/oodle_response/listings/element/attributes/company",
                                      @"/oodle_response/listings/element/attributes/employee_type",
                                      @"/oodle_response/listings/element/location/citycode",
                                      @"/oodle_response/listings/element/ctime",
                                      @"/oodle_response/listings/element/source/name",


                                      // Linkup
                                      @"/linkup_job_search/jobs/job/job_title",
                                      @"/linkup_job_search/jobs/job/job_title_link",
                                      @"/linkup_job_search/jobs/job/job_company",
                                      @"/linkup_job_search/jobs/job/job_location",
                                      @"/linkup_job_search/jobs/job/job_date_added",
                                      @"/linkup_job_search/jobs/job/job_description",
                                      
                                      nil];

        XMLParse *parser = [[XMLParse alloc] initWithURL:[NSURL URLWithString:feedNew] ignoring:ignoreListArray treatAsProperty:propertyListArray];
        
        // Parse the XML
        NSDictionary* dataDict = [parser parse];
        // Array of job node identifiers 
        NSArray *jobNodeTitles = [NSArray arrayWithObjects:@"item",@"JobSearchResult",@"result",@"job", @"element", nil];
        
        NSMutableArray* tmpJobs = [[NSMutableArray alloc] init];
        for (NSDictionary* tmpJobs2 in [dataDict objectForKey:CHILDREN_KEY]) {
            for (NSDictionary* theJob in [tmpJobs2 objectForKey:CHILDREN_KEY]) {

                // reformat Indeed records to match RSS
                if ([[theJob valueForKey:@"jobtitle"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"jobtitle"] forKey:@"title"];                    
                }
                if ([[theJob valueForKey:@"snippet"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"snippet"] forKey:@"description"];                    
                }
                if ([[theJob valueForKey:@"date"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"date"] forKey:@"pubDate"];                    
                }
                if ([[theJob valueForKey:@"formattedLocation"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"formattedLocation"] forKey:@"city"];                    
                }
                if ([[theJob valueForKey:@"url"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"url"] forKey:@"link"];                    
                }

                // reformat Careerbuilder records to match RSS
                if ([[theJob valueForKey:@"JobTitle"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"JobTitle"] forKey:@"title"];                    
                }
                if ([[theJob valueForKey:@"Company"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"Company"] forKey:@"company"];                    
                }
                if ([[theJob valueForKey:@"Location"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"Location"] forKey:@"city"];                    
                }
                if ([[theJob valueForKey:@"DescriptionTeaser"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"DescriptionTeaser"] forKey:@"description"];                    
                }
                if ([[theJob valueForKey:@"PostedDate"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"PostedDate"] forKey:@"pubDate"];                    
                }
                if ([[theJob valueForKey:@"JobDetailsURL"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"JobDetailsURL"] forKey:@"link"];                    
                }
                if ([[theJob valueForKey:@"EmploymentType"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"EmploymentType"] forKey:@"type"];                    
                }
                if ([[theJob valueForKey:@"Pay"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"Pay"] forKey:@"pay"];                    
                }

/*
 <listings>
Mediations Paralegal Job#: 155838 Positions: 1 Posted: 06/13/2012 Position category: Full
 
 <ctime>1340011181</ctime>
NSDate *date = [NSDate dateWithTimeIntervalSince1970:1234567];
 */
                // reformat Oodle records to match RSS
                if ([[theJob allKeys] containsObject:@"ctime"])  {
                
                     if ([[[[theJob objectForKey:@"_children_"] objectAtIndex:3] valueForKey:@"citycode"] length] > 0) {
                     [theJob setValue:[[[theJob objectForKey:@"_children_"] objectAtIndex:3] valueForKey:@"citycode"] forKey:@"city"];                    
                     }
                     
                    if ([[[[theJob objectForKey:@"_children_"] objectAtIndex:9] valueForKey:@"company"] length] > 0) {
                        [theJob setValue:[[[theJob objectForKey:@"_children_"] objectAtIndex:9] valueForKey:@"company"] forKey:@"company"];                    
                    }
                    if ([[[[theJob objectForKey:@"_children_"] objectAtIndex:9] valueForKey:@"employee_type"] length] > 0) {
                        [theJob setValue:[[[theJob objectForKey:@"_children_"] objectAtIndex:9] valueForKey:@"employee_type"] forKey:@"type"];                    
                    }

                }
                if ([[theJob valueForKey:@"body"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"body"] forKey:@"description"];                    
                }
                if ([[theJob valueForKey:@"ctime"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"ctime"] forKey:@"pubDate"];                    
                }
 
                // reformat LinkUp records to match RSS
                if ([[theJob valueForKey:@"job_title"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"job_title"] forKey:@"title"];                    
                }
                if ([[theJob valueForKey:@"job_company"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"job_company"] forKey:@"company"];                    
                }
                if ([[theJob valueForKey:@"job_description"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"job_description"] forKey:@"description"];                    
                }
                if ([[theJob valueForKey:@"job_date_added"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"job_date_added"] forKey:@"pubDate"];                    
                }
                if ([[theJob valueForKey:@"job_title_link"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"job_title_link"] forKey:@"link"];                    
                }
                if ([[theJob valueForKey:@"job_location"] length] > 0) {
                    [theJob setValue:[theJob valueForKey:@"job_location"] forKey:@"city"];                    
                }

                if ([jobNodeTitles containsObject:[theJob objectForKey:ELEMENT_KEY]]) {
                    // tag each job w/ section identifier
                    [theJob setValue:[NSNumber numberWithInt:i] forKey:@"sectionNum"];
                    [tmpJobs addObject:theJob];
                    
                }
            }
        }
		
//        NSLog(@"# of jobs = %i",[tmpJobs count]);
		// sort the jobs for this section
        [sectionHeaders addObject:[aSite objectAtIndex:0]];
        if ([tmpJobs count] > 0) {
            [self.jobsAll addObject:[tmpJobs sortedArrayUsingDescriptors:sortDescriptors]];
        } else {
            [self.jobsAll addObject:tmpJobs];            
        }
		[self.tableView reloadData];
        tableView.hidden = NO;
        btnJobSite.hidden = NO;

	}

}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
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
    headerLabel.text = [sectionHeaders objectAtIndex:section];
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
    NSArray *aSite = [[siteList objectAtIndex:1] componentsSeparatedByString:@"^"]; 
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[aSite objectAtIndex:1]]];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.jobsAll objectAtIndex:btnJobSite.selectedSegmentIndex] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
	
    NSArray *tmpJob = [[self.jobsAll objectAtIndex:btnJobSite.selectedSegmentIndex] objectAtIndex:indexPath.row];

    NSString *company = ([[tmpJob valueForKey:@"source"] length] > 0) ? [tmpJob valueForKey:@"source"] : ([[tmpJob valueForKey:@"company"] length] > 0) ? [tmpJob valueForKey:@"company"] : @"";
    
    // Careerbuilder has different key format from RSS feeds
    NSString *title = ([[tmpJob valueForKey:@"title"] length] > 0) ? [tmpJob valueForKey:@"title"] :  @"";
    
    
    if (!company.length) {
        
        //DICE: Agile Global Solutions, Inc Seattle, WA<br /
        if (indexPath.section == 1) {
            NSString *strScan = [tmpJob valueForKey:@"description"];
            NSScanner *aScanner = [NSScanner scannerWithString:strScan];
            NSString *separatorString = @"<br";
            NSString *separatorString2 = @", ";

            [aScanner scanUpToString:separatorString intoString:&company];
            aScanner = [NSScanner scannerWithString:company];
//    NSLog(@"1st pass = %@", company);
            [aScanner scanUpToString:separatorString2 intoString:&company];

            NSRange rangeDesc1 = [[tmpJob valueForKey:@"description"] rangeOfString:@":</b>"];
            if (rangeDesc1.location != NSNotFound) {
                [tmpJob setValue:[[tmpJob valueForKey:@"description"] substringFromIndex:rangeDesc1.location+5] forKey:@"description"];
            }

        } else if (indexPath.section == 3) { // Simply Hired
            // <title><![CDATA[Mobile Software Developer - IMDb at Amazon.com (Seattle, WA)]]></title>         
        
            NSRange range = [title rangeOfString:@" at "];

            if (range.location != NSNotFound) {
                company = [title substringFromIndex:range.location+4];
                title = [title substringToIndex:range.location];
//      NSLog(@"1st pass = %@", company);
                range = [company rangeOfString:@" ("];
                if (range.location != NSNotFound) {
                    company = [company substringToIndex:range.location];                    
                }
            }
            [tmpJob setValue:title forKey:@"title"];

        }
//        NSLog(@"2nd pass = %@", company);
        [tmpJob setValue:company forKey:@"company"];

    } 

    //**************
    
	NSString *jobdate = ([[tmpJob valueForKey:@"pubDate"] length] > 0) ? [NSString stringWithFormat:@"%@ - ",[del getShortDate:[tmpJob valueForKey:@"pubDate"]]] : [NSString stringWithFormat:@" "];

    NSString *location = ([[tmpJob valueForKey:@"Location"] length] > 0) ? [NSString stringWithFormat:@"%@ - ",[tmpJob valueForKey:@"Location"]] : @"";

	cell.textLabel.text = [tmpJob valueForKey:@"title"];
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@ %@",jobdate, company, location];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.textLabel.font = [UIFont systemFontOfSize:14];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	if(self.jobDetailVC == nil)
		self.jobDetailVC = [[JobDetail alloc] initWithNibName:@"JobDetail" bundle:nil];
		
	self.jobDetailVC.aJob = [[self.jobsAll objectAtIndex:btnJobSite.selectedSegmentIndex] objectAtIndex:indexPath.row];
    	
	[self.navigationController pushViewController:self.jobDetailVC animated:YES];
	
}


- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    lblSearch.text = [NSString stringWithFormat:@"Job listings for '%@' in %@",txtSearch,txtZip];
	if (self.currentJob) {
		self.currentJob = nil;
	}

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
    [request setLocationWithDescription:[NSString stringWithFormat:@"%@ US",[del.userSettings objectForKey:@"postalcode"]]];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:request]; 

    // Log pageview w/ Google Analytics
    [del trackPVFull:@"SearchJobs" :@"search term" :@"search" :txtSearch];
}

- (void)dealloc {

}


@end

