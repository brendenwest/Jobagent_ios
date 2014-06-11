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
@synthesize selectedLead = _selectedLead;

BOOL isSavedJob;


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
    
    // Use this array to display field labels and map data to Job object keys
    jobFields = [NSArray arrayWithObjects:@"Title", @"Company", @"Location", @"Date", @"Type", @"Link", @"Contact", @"Pay", @"Notes", nil];
    
	
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	
    [jobActions addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if (aJob == nil) { //
        aJob = [[NSMutableDictionary alloc] init];
        [aJob setValue:_selectedLead.jobid forKey:@"jobid"];
        NSLog(@"view will appear for job %@",[aJob valueForKey:@"title"]);

        [aJob setValue:_selectedLead.title forKey:@"title"];
        [aJob setValue:_selectedLead.company forKey:@"company"];
        [aJob setValue:_selectedLead.city forKey:@"location"];
        [aJob setValue:_selectedLead.person forKey:@"contact"];
        [aJob setValue:_selectedLead.link forKey:@"link"];
        [aJob setValue:_selectedLead.notes forKey:@"notes"];
        [aJob setValue:_selectedLead.date forKey:@"pubdate"];
        [aJob setValue:_selectedLead.type forKey:@"type"];
        [aJob setValue:_selectedLead.jobid forKey:@"jobid"];
        isSavedJob = YES;
    }
    [self.tableView reloadData];
    
    // Log pageview w/ Google Analytics
    [appDelegate trackPV:@"Job Details"];
    
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


- (void)saveJob:(BOOL)clickedSaveBtn {

    Job *lead = _selectedLead;
    if (clickedSaveBtn) {
        _selectedLead = [NSEntityDescription insertNewObjectForEntityForName: @"Job" inManagedObjectContext: managedObjectContext];
    }

	[_selectedLead setValue:[aJob valueForKey:@"jobid"] forKey:@"jobid"];
	[_selectedLead setValue:[aJob valueForKey:@"title"] forKey:@"title"];
	[_selectedLead setValue:[aJob valueForKey:@"company"] forKey:@"company"];
	[_selectedLead setValue:[aJob valueForKey:@"location"] forKey:@"city"];
	[_selectedLead setValue:[aJob valueForKey:@"contact"] forKey:@"person"];
	[_selectedLead setValue:[aJob valueForKey:@"link"] forKey:@"link"];
	[_selectedLead setValue:[aJob valueForKey:@"type"] forKey:@"type"];
	[_selectedLead setValue:[aJob valueForKey:@"notes"] forKey:@"notes"];
	[_selectedLead setValue:[Common dateFromString:[aJob valueForKey:@"pubdate"]] forKey:@"date"];
	[_selectedLead setValue:[aJob valueForKey:@"pay"] forKey:@"pay"];

    // save Company and Contact records if user has entered values
    if ([_selectedLead.company length] > 0) {
        [appDelegate setCompany:_selectedLead.company]; // save company
    }

    if ([_selectedLead.person length] > 0) {
        [appDelegate setPerson:_selectedLead.person withCo:_selectedLead.company];	// save person to SQL
    }

    
//    @property (nonatomic, strong) NSString * state;
//    @property (nonatomic, strong) NSString * country;

    
	NSError *error = nil;
	if (![lead.managedObjectContext save:&error]) {
									  // Handle the error...
	}

    if (clickedSaveBtn) {
        UIAlertView *saveLeadAlert = [[UIAlertView alloc] initWithTitle:@"Saved to Leads" message:nil delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [saveLeadAlert show];
    }
 
}

- (void)segmentAction:(id)sender
{
    [appDelegate trackPVFull:@"Listing" :@"Action" :[NSString stringWithFormat:@"%ld",(long)[sender selectedSegmentIndex]] :@""];

    
	if ([sender selectedSegmentIndex] == 0) {
		[self saveJob:1];
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

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        // Navigating to item editor
        NSLog(@"navigating to EditItem");
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack
        if (self.selectedLead.title.length > 0) {
            NSLog(@"save existing job");
            [self saveJob:0];
        } else {
            // delete empty job lead record
            NSLog(@"delete empty record");
            [self.selectedLead.managedObjectContext deleteObject:self.selectedLead];
        }
    }

    
/*
        self.selectedLead.title = jobTitle.text;
        self.selectedLead.company = company.text;
        if ([company.text length] > 0) {
            [del setCompany:company.text]; // save to SQL
        }
        self.selectedLead.city = city.text;
        
        self.selectedLead.person = person.text;
        if ([person.text length] > 0) {
            [del setPerson:person.text withCo:company.text];	// save person to SQL
        }
        
        self.selectedLead.link = link.text;
        self.selectedLead.type = jobType.text;
        self.selectedLead.pay = pay.text;
        self.selectedLead.date = [Common dateFromString:btnDate.currentTitle];
        
        NSError *error = nil;
        if (![self.selectedLead.managedObjectContext save:&error]) {
            // Handle the error...
            NSLog(@"Error saving %@, %@", error, [error userInfo]);
        }
*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}



@end
