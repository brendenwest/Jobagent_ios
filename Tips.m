//
//  task.m
//  jobagent
//
//  Created by mac on 2/24/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "Tips.h"

#import "GADBannerView.h"
#import "GADRequest.h"

@implementation Tips

@synthesize tableView, btnTips, lblAbout, appDelegate;

- (void)awakeFromNib
{
    // set title here so it applies to both view and tab bar item
    self.title = NSLocalizedString(@"STR_TITLE_TIPS", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = NSLocalizedString(@"STR_TITLE_TIPS", nil);
    lblAbout.text = NSLocalizedString(@"STR_SHARE", nil);

    if (IS_OS_7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

	tableView.dataSource = self;
    
	// create a custom navigation bar button and set it to always say "Back"
    
    self.allItems = [[NSArray alloc] init];
    [self requestTips];

    // Create ad view of the standard size at the bottom of the screen. Account for nav bar & tab bar heights
    // Available AdSize constants are explained in GADAdSize.h.
    
    double statusBarOffset = (IS_OS_7_OR_LATER) ? 20.0 : 0;
    CGPoint origin = CGPointMake(0.0,
                                 [[UIScreen mainScreen] bounds].size.height -
                                 CGSizeFromGADAdSize(kGADAdSizeBanner).height - self.navigationController.navigationBar.frame.size.height -self.tabBarController.tabBar.frame.size.height - statusBarOffset);
    

    // Use predefined GADAdSize constants to define the GADBannerView.
    bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner origin:origin];
    
    // Specify the ad unit ID.
    bannerView_.adUnitID = [appDelegate.configuration objectForKey:@"adUnitID"];
    
    // Let the runtime know which UIViewController to restore after taking
    // the user wherever the ad goes and add it to the view hierarchy.
    bannerView_.rootViewController = self;
    [self.view addSubview:bannerView_];
    
    // Initiate a generic request to load it with an ad.
    [bannerView_ loadRequest:[GADRequest request]];
    
    // create a custom navigation bar button and set it to always say "Back"
    
    
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adView:didFailToReceiveAdWithError:%@", [error localizedDescription]);
}

#pragma mark GADRequest generation

- (GADRequest *)request {
    GADRequest *request = [GADRequest request];
    
    // Make the request for a test ad if on the simulator as well as any test devices
    request.testDevices = @[ GAD_SIMULATOR_ID ];

    NSString* postalCode = [[NSUserDefaults standardUserDefaults]  stringForKey:@"postalcode"];
    NSString* countryCode = [[NSUserDefaults standardUserDefaults]  stringForKey:@"countryCode"];
    
    // pass current location info on ad request
    [request setLocationWithDescription:[NSString stringWithFormat:@"%@ %@",postalCode, countryCode]];
    
    return request;
}

#pragma mark GADBannerViewDelegate implementation

// We've received an ad successfully.
- (void)adViewDidReceiveAd:(GADBannerView *)adView {
    NSLog(@"Received ad successfully");
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [appDelegate trackPV:self.title];

}



-(void)requestTips
{
    NSURL *url = [NSURL URLWithString:[appDelegate.configuration objectForKey:@"tipsUrl"]];
    NSLog(@"url = %@", url);

    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //AFNetworking asynchronous url request
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc]
                                         initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.allItems = [responseObject objectForKey:@"Tips"];
        [self.tableView reloadData];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failed: Status Code: %ld", (long)operation.response.statusCode);
    }];
    [operation start];
}



// Share Job Agent
- (NSArray *)activityViewController:(NSArray *)activityViewController itemsForActivityType:(NSString *)activityType {
    if (![activityType isEqualToString:UIActivityTypePostToTwitter]) {
        // link to Job Agent in app store
        NSString *tinyUrl2 = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",NSLocalizedString(@"URL_JOBAGENT_IOS", nil)];
        
        NSString *shortURLforJobAgent = [NSString stringWithContentsOfURL:[NSURL URLWithString:tinyUrl2]
                                                                 encoding:NSASCIIStringEncoding
                                                                    error:nil];
        
        return @[
                 [NSString stringWithFormat:@"Job Agent works for me - %@", shortURLforJobAgent ]
                 ];
    } else {
        return @[@"Default message"];
    }
}

- (IBAction)shareJobAgent:(id)sender {
    
    NSString *tinyUrl1 = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",[appDelegate.configuration objectForKey:@"jobagentUrlAppStore"]];
    NSString *shortURLforJobAgent = [NSString stringWithContentsOfURL:[NSURL URLWithString:tinyUrl1]
                                                             encoding:NSASCIIStringEncoding
                                                                error:nil];
    
    NSString *postText = [NSString stringWithFormat:@"Job Agent works for me - %@ ", shortURLforJobAgent];
    NSURL *recipients = [NSURL URLWithString:@"info@brisksoft.us"];
    
    NSArray *activityItems;
    activityItems = @[postText, recipients];
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems applicationActivities:nil];
    
    
    [activityController setValue:[NSString stringWithFormat:@"Job Agent app"] forKey:@"subject"];
    
    /* use shortURL */
    
    // Removed un-needed activities
    activityController.excludedActivityTypes = [[NSArray alloc] initWithObjects:
                                                UIActivityTypeCopyToPasteboard,
                                                UIActivityTypePostToWeibo,
                                                UIActivityTypeSaveToCameraRoll,
                                                UIActivityTypeCopyToPasteboard,
                                                UIActivityTypeMessage,
                                                UIActivityTypeAssignToContact,
                                                nil];
    
    [self presentViewController:activityController
                       animated:YES completion:nil];
    
    
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allItems count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Recent";
}

#pragma mark UITableViewDelegate
	 
// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller

    NSArray *aItem = [self.allItems objectAtIndex:indexPath.row];
    if ([[aItem valueForKey:@"link"] length] > 0) {
        // item has a link
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[aItem valueForKey:@"link"]]];
    }

}


#pragma mark UITableViewDataSource

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
	UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-cell"];

	}

    NSArray *item = [self.allItems objectAtIndex:indexPath.row];
	cell.textLabel.text = [item valueForKey:@"title"];
    cell.detailTextLabel.text = [item valueForKey:@"description"];
	cell.textLabel.font = [UIFont systemFontOfSize:14];

	return cell;
}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
	// Release any retained subviews of the main view.
}


@end
