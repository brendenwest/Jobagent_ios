//
//  JobDetail.m
//  jobagent
//
//  Created by mac on 3/9/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "JobDetail.h"
#import "Job.h"
#import "Company.h"
#import "AppDelegate.h"
#import "WebVC.h"

@implementation JobDetail

@synthesize jobTitle, company, location, pubDate, jobType, pay, description, jobActions, del;
@synthesize managedObjectContext;
@synthesize aJob = _aJob;
@synthesize webVC = _webVC;


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Job Detail";

    if (IS_OS_7_OR_LATER) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

	if (managedObjectContext == nil) 
	{ 
		managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
	}
	
	del = (AppDelegate *)[UIApplication sharedApplication].delegate;

	// set border around text view
	description.layer.cornerRadius = 8;
	description.layer.borderWidth = 1;
	description.layer.borderColor = [[UIColor grayColor] CGColor];	
	
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	
    [jobActions addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	jobTitle.text = [_aJob objectForKey:@"title"];
	company.text = [_aJob objectForKey:@"company"];
	location.text = [_aJob objectForKey:@"city"];
	description.text = [_aJob objectForKey:@"description"];
	pubDate.text = ([[_aJob objectForKey:@"pubDate"] length] > 0) ? [del getShortDate:[_aJob objectForKey:@"pubDate"]] : @"";
	jobType.text = ([[_aJob objectForKey:@"type"] length] > 0) ? [_aJob objectForKey:@"type"] : @"";
	pay.text = ([[_aJob objectForKey:@"pay"] length] > 0) ? [_aJob objectForKey:@"pay"] : @"";

    // Log pageview w/ Google Analytics
    [del trackPVFull:@"Listing" :@"job site" :@"listings" :[_aJob valueForKey:@"sectionNum"]];
    
}


- (NSArray *)activityViewController:(NSArray *)activityViewController itemsForActivityType:(NSString *)activityType {
    if (![activityType isEqualToString:UIActivityTypePostToTwitter]) {
        // link to Job Agent in app store
        NSString *tinyUrl2 = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",NSLocalizedString(@"URL_JOBAGENT_IOS", nil)];
        
        NSString *shortURLforJobAgent = [NSString stringWithContentsOfURL:[NSURL URLWithString:tinyUrl2]
                                                       encoding:NSASCIIStringEncoding
                                                          error:nil];
        
        return @[
                 [NSString stringWithFormat:@"<a href='%@'>%@</a> - via Job Agent app %@", [_aJob valueForKey:@"link"], [_aJob valueForKey:@"title"], shortURLforJobAgent ]
                 ];
    } else {
        return @[@"Default message"];
    }
}

- (void)shareJob {
    NSLog(@"sharing in general");
    

    NSString *tinyUrl1 = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",[_aJob valueForKey:@"link"]];
    NSString *shortURLforJob = [NSString stringWithContentsOfURL:[NSURL URLWithString:tinyUrl1]
                                                        encoding:NSASCIIStringEncoding
                                                           error:nil];

    NSString *postText = [NSString stringWithFormat:@"%@ - %@", [_aJob valueForKey:@"title"], shortURLforJob];
    NSURL *recipients = [NSURL URLWithString:@""];
    
    NSArray *activityItems;
    activityItems = @[postText, recipients];
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems applicationActivities:nil];

    
    [activityController setValue:[NSString stringWithFormat:@"Job lead - %@",[_aJob valueForKey:@"title"] ] forKey:@"subject"];

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

- (void)sendMail {
	// add check for can't send mail

	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	NSString *subject = [NSString stringWithFormat:@"Job lead - %@", [_aJob valueForKey:@"title"]];
	NSString *body = [NSString stringWithFormat:@"Check out this job :\n\n %@ \n \n Sent via Job Agent app.\n\n http://itunes.apple.com/us/app/job-agent/id517622797?ls=1&mt=8", [_aJob valueForKey:@"link"]];
	
	mailController.mailComposeDelegate = self;
	[mailController setSubject:subject];
	[mailController setMessageBody:body isHTML:YES];
    [self presentViewController:mailController animated:YES completion:NULL];

}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error 
{
	if (error) {
		UIAlertView *cantMailAlert = [[UIAlertView alloc] initWithTitle:@"Mail error" message:[error localizedDescription] delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
		[cantMailAlert show];
	} else if (result == MFMailComposeResultSent) { // mail was sent
        
        [self saveToLeads:[NSNumber numberWithInt:1]];	// save lead if it was mailed
    }
    [controller dismissViewControllerAnimated:YES completion:nil];

}


- (void)saveToLeads:(NSNumber *)selectedAction {

	NSManagedObject *lead = [NSEntityDescription insertNewObjectForEntityForName: @"Job" inManagedObjectContext: managedObjectContext];

	[lead setValue:jobTitle.text forKey:@"title"];	
	[lead setValue:description.text forKey:@"notes"];
	[lead setValue:[del dateFromString:[_aJob valueForKey:@"pubDate"]] forKey:@"date"];
	[lead setValue:[_aJob valueForKey:@"link"] forKey:@"link"];
	[lead setValue:[_aJob valueForKey:@"city"] forKey:@"city"];
	[lead setValue:[_aJob valueForKey:@"company"] forKey:@"company"];	

	[lead setValue:selectedAction forKey:@"bMailed"];	
		
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
									  // Handle the error...
	}
								  
	 UIAlertView *saveLeadAlert = [[UIAlertView alloc] initWithTitle:@"Saved to Leads" message:nil delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[saveLeadAlert show];
 
}

- (void)segmentAction:(id)sender
{
//    [del trackEvent:[NSString stringWithFormat:@"Share via %ld",(long)[sender selectedSegmentIndex]]:[_aJob valueForKey:@"title"]:[_aJob valueForKey:@"sectionNum"]:1];

    NSLog(@"share option %ld",(long)[sender selectedSegmentIndex]);

	if ([sender selectedSegmentIndex] == 0) {
		[self saveToLeads:[NSNumber numberWithInt:0]];
	} else if ([sender selectedSegmentIndex] == 2){
		WebVC *webVC = [[WebVC alloc]
						initWithNibName:nil bundle:nil];
		webVC.requestedURL = [_aJob valueForKey:@"link"];
		webVC.title = @"Job Listing";
		[self.navigationController pushViewController:webVC animated:YES];
	} else {
		[self shareJob];
	}
	
	jobActions.selectedSegmentIndex =  UISegmentedControlNoSegment;
	
}	


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}



@end
