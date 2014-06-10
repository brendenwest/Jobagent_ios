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
#import "EditItemVC.h"
#import "Common.h"


@implementation JobDetail

@synthesize  jobFields, jobActions, appDelegate, tableView, aJob, editedItemId;
@synthesize managedObjectContext;
@synthesize webVC = _webVC;


// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Job Detail";

    if (IS_OS_7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

	appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	if (managedObjectContext == nil)
	{ 
		managedObjectContext = [appDelegate managedObjectContext];
	}
	
	tableView.dataSource = self;
    
    jobFields = [NSArray arrayWithObjects:@"Title", @"Company", @"Location", @"Date", @"Type", @"Link", @"Contact", @"Pay", @"Notes", nil];
    
	
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	
    [jobActions addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    [self.tableView reloadData];
    
    // Log pageview w/ Google Analytics
    [appDelegate trackPVFull:@"Listing" :@"job site" :@"listings" :[aJob valueForKey:@"sectionNum"]];
    
}


- (NSArray *)activityViewController:(NSArray *)activityViewController itemsForActivityType:(NSString *)activityType {
    if (![activityType isEqualToString:UIActivityTypePostToTwitter]) {
        // link to Job Agent in app store
        NSString *tinyUrl2 = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",NSLocalizedString(@"URL_JOBAGENT_IOS", nil)];
        
        NSString *shortURLforJobAgent = [NSString stringWithContentsOfURL:[NSURL URLWithString:tinyUrl2]
                                                       encoding:NSASCIIStringEncoding
                                                          error:nil];
        
        return @[
                 [NSString stringWithFormat:@"<a href='%@'>%@</a> - via Job Agent app %@", [aJob valueForKey:@"link"], [aJob valueForKey:@"title"], shortURLforJobAgent ]
                 ];
    } else {
        return @[@"Default message"];
    }
}

- (void)shareJob {

    NSString *tinyUrl1 = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",[aJob valueForKey:@"link"]];
    NSString *shortURLforJob = [NSString stringWithContentsOfURL:[NSURL URLWithString:tinyUrl1]
                                                        encoding:NSASCIIStringEncoding
                                                           error:nil];

    NSString *postText = [NSString stringWithFormat:@"%@ - %@", [aJob valueForKey:@"title"], shortURLforJob];
    NSURL *recipients = [NSURL URLWithString:@""];
    
    NSArray *activityItems;
    activityItems = @[postText, recipients];
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems applicationActivities:nil];

    
    [activityController setValue:[NSString stringWithFormat:@"Job lead - %@",[aJob valueForKey:@"title"] ] forKey:@"subject"];

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


- (void)saveToLeads:(NSNumber *)selectedAction {

	NSManagedObject *lead = [NSEntityDescription insertNewObjectForEntityForName: @"Job" inManagedObjectContext: managedObjectContext];

	[lead setValue:[aJob valueForKey:@"title"] forKey:@"title"];
	[lead setValue:[aJob valueForKey:@"company"] forKey:@"company"];
	[lead setValue:[aJob valueForKey:@"location"] forKey:@"city"];
	[lead setValue:[aJob valueForKey:@"contact"] forKey:@"person"];
	[lead setValue:[aJob valueForKey:@"link"] forKey:@"link"];
	[lead setValue:[aJob valueForKey:@"type"] forKey:@"type"];
	[lead setValue:[aJob valueForKey:@"notes"] forKey:@"notes"];
	[lead setValue:[Common dateFromString:[aJob valueForKey:@"pubdate"]] forKey:@"date"];
	[lead setValue:[aJob valueForKey:@"pay"] forKey:@"pay"];

//    @property (nonatomic, strong) NSString * state;
//    @property (nonatomic, strong) NSString * country;

    
    
	NSError *error = nil;
	if (![managedObjectContext save:&error]) {
									  // Handle the error...
	}

	 UIAlertView *saveLeadAlert = [[UIAlertView alloc] initWithTitle:@"Saved to Leads" message:nil delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[saveLeadAlert show];
 
}

- (void)segmentAction:(id)sender
{
    [appDelegate trackPVFull:@"Listing" :@"Action" :[NSString stringWithFormat:@"%ld",(long)[sender selectedSegmentIndex]] :@""];

    
	if ([sender selectedSegmentIndex] == 0) {
		[self saveToLeads:[NSNumber numberWithInt:0]];
	} else if ([sender selectedSegmentIndex] == 2){
		WebVC *webVC = [[WebVC alloc]
						initWithNibName:nil bundle:nil];
		webVC.requestedURL = [aJob valueForKey:@"link"];
		webVC.title = @"Job Listing";
		[self.navigationController pushViewController:webVC animated:YES];
	} else {
		[self shareJob];
	}
	
	jobActions.selectedSegmentIndex =  UISegmentedControlNoSegment;
	
}	


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //    return [[self.jobsAll objectAtIndex:btnJobSite.selectedSegmentIndex] count];
    return [jobFields count];
    
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    NSString *detailText;
    NSString *itemKey = (indexPath.row == 3) ? @"pubdate" : [[jobFields objectAtIndex:indexPath.row] lowercaseString];
    detailText = [aJob objectForKey:itemKey];

    // Configure the cell...

	cell.textLabel.text = [jobFields objectAtIndex:indexPath.row];
	cell.detailTextLabel.text = detailText;

	cell.textLabel.font = [UIFont systemFontOfSize:10];
    cell.textLabel.textColor = [UIColor grayColor];
	cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
    cell.detailTextLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}



- (void)tableView:(UITableView *)tblView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    
    EditItemVC *editItemVC = [[EditItemVC alloc] init];
    
    UITableViewCell *selectedCell = [tblView cellForRowAtIndexPath:indexPath];
    
    editedItemId = [jobFields objectAtIndex:indexPath.row];

	editItemVC.labelText = selectedCell.textLabel.text;
	editItemVC.itemText = selectedCell.detailTextLabel.text;
    editItemVC.delegate = self;
    
	[self.navigationController pushViewController:editItemVC animated:YES];
	
}

#pragma mark - Protocol methods

-(void)setItemText:(NSString *)editedItemText {
    
    NSString *itemKey = ([editedItemId isEqualToString:@"Date"]) ? @"pubdate" : [editedItemId lowercaseString];
    [aJob setValue:editedItemText forKey:itemKey];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}



@end
