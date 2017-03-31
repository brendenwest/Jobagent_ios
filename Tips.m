//
//  Tips.m
//  jobagent
//
//  Created by mac on 2/24/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"
#import "Tips.h"
#import "Ads.h"

@implementation Tips

@synthesize tableView, btnTips, lblAbout;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    allItems = [[NSArray alloc] init];
    [self requestTips];

    
    // create a custom navigation bar button and set it to always say "Back"
    
    // create a standard "bookmarks" button in the nav bar
    UIBarButtonItem* bi = [[UIBarButtonItem alloc]
                           initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(shareJobAgent:)];
    self.navigationItem.rightBarButtonItem = bi;

    [Ads getAd:self];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [appDelegate trackPV:self.title];

}



-(void)requestTips
{
  
  AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
  [manager GET:[appDelegate.configuration objectForKey:@"tipsUrl"] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
    NSLog(@"JSON: %@", responseObject);
      allItems = [responseObject objectForKey:@"Tips"];
      [self.tableView reloadData];
  } failure:^(NSURLSessionTask *operation, NSError *error) {
    NSLog(@"Error: %@", error);
  }];
  
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
    return [allItems count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Latest news & tips";
}

#pragma mark UITableViewDelegate
	 
// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller

    NSArray *aItem = [allItems objectAtIndex:indexPath.row];
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

    NSArray *item = [allItems objectAtIndex:indexPath.row];
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
    [super viewDidUnload];
}


@end
