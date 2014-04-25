//
//  More.m
//  jobagent
//
//  Created by mac on 4/18/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "More.h"
#import "Companies.h"
#import "Tasks.h"
#import "AppDelegate.h"

static NSString *kCellIdentifier = @"MyIdentifier";
static NSString *kTitleKey = @"title";
static NSString *kViewControllerKey = @"viewController";


@implementation More

@synthesize menuList, del;


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"More";

	// construct the array of views to list
	//
	self.menuList = [NSMutableArray array];
	del = (AppDelegate *)[UIApplication sharedApplication].delegate;
	
	// for showing various UIButtons:
	Companies *companiesViewController = [[Companies alloc]
									initWithNibName:nil bundle:nil];	
	Tasks *tasksViewController = [[Tasks alloc]
								  initWithNibName:nil bundle:nil];
	[self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							  @"Companies", kTitleKey, companiesViewController, kViewControllerKey,
							  nil]];
	[self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							  @"Checklist", kTitleKey, tasksViewController, kViewControllerKey,
							  nil]];
	[self.menuList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
							  @"Backup", kTitleKey, 
							  nil]];
	
	
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [del trackPV:self.title];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [menuList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cell.textLabel.text = [[self.menuList objectAtIndex:indexPath.row] objectForKey:kTitleKey];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
		if ([[[self.menuList objectAtIndex: indexPath.row] objectForKey:kTitleKey] isEqualToString:@"Backup"]) {
			[del archiveData]; // write data to text file
			
			// compose mail
			MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
			NSArray *recipients = [[NSArray alloc] initWithObjects:@"brendenw@hotmail.com", nil]; 
			NSString *subject = [NSString stringWithFormat:@"Job Agent backup - %@", [del shortDate:[NSDate date]]];
			
			mailController.mailComposeDelegate = self;
			[mailController setToRecipients:recipients];
			[mailController setSubject:subject];
			
			// Attach file to the email
			NSString *dataFile = [del.applicationDocumentsDirectory stringByAppendingPathComponent:@"archive.txt"];	
			NSData *myData = [NSData dataWithContentsOfFile:dataFile];
			[mailController addAttachmentData:myData mimeType:nil fileName:@"archive.txt"];
            [self presentViewController:mailController animated:YES completion:NULL];
			
		}
		else {
			UIViewController *targetViewController = [[self.menuList objectAtIndex: indexPath.row] objectForKey:kViewControllerKey];
			[[self navigationController] pushViewController:targetViewController animated:YES];
		}
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error 
{
	if (error) {
		UIAlertView *cantMailAlert = [[UIAlertView alloc] initWithTitle:@"Mail error" message:[error localizedDescription] delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
		[cantMailAlert show];
	}
    [controller dismissViewControllerAnimated:YES completion:nil];
}




@end

