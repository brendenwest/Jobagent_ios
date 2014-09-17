//
//  Leads.m
//  jobagent
//
//  Created by mac on 3/21/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Leads.h"
#import "Job.h"
#import "JobDetail.h"
#import "Common.h"

@interface Leads()
    @property(nonatomic, assign) BOOL firstInsert;
@end

@implementation Leads

@synthesize fetchedResultsController;
@synthesize managedObjectContext;
@synthesize jobDetailVC = _jobDetailVC;
@synthesize firstInsert = _firstInsert;
@synthesize appDelegate;
@synthesize selectedCompany = _selectedCompany;


- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = NSLocalizedString(@"STR_TITLE_FAVORITES", nil);
    
	appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	if (managedObjectContext == nil)
	{ 
		managedObjectContext = [appDelegate managedObjectContext];
	}

	
	[self customBarButtons];
}

// Insert new item
- (void)insertItem {
	self.firstInsert = [self.fetchedResultsController.sections count] == 0;
	
	NSManagedObjectContext *context = 
	[self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = 
	[self.fetchedResultsController.fetchRequest entity];
	Job *lead = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
												 inManagedObjectContext:context];
	
	if(self.jobDetailVC == nil)
		self.jobDetailVC = [[JobDetail alloc] initWithNibName:@"JobDetail" bundle:nil];
	
	self.jobDetailVC.selectedLead = lead;
	[self.navigationController pushViewController:self.jobDetailVC animated:YES];
}


- (void)customBarButtons {
	// create a toolbar to have two buttons in the right
	UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 44.01)];
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
	
	// create a standard "add" button
	UIBarButtonItem* bi = [[UIBarButtonItem alloc]
						   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertItem)];
	bi.style = UIBarButtonItemStyleBordered;
	[buttons addObject:bi];
	
	// create a spacer
	bi = [[UIBarButtonItem alloc]
		  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
	[buttons addObject:bi];
	
	// create a standard "edit" button
	bi = self.editButtonItem;
	bi.style = UIBarButtonItemStyleBordered;
	[buttons addObject:bi];
	
	// stick the buttons in the toolbar
	[tools setItems:buttons animated:NO];
	
	
	// and put the toolbar in the nav bar
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		// handle the error...
	}

    [self.tableView reloadData];
    
    [appDelegate trackPV:self.title];

}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidLoad];
	// Release any retained subviews of the main view.
	self.fetchedResultsController = nil;
    [super viewDidUnload];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    if (_selectedCompany != NULL) {
        sectionName = [NSString stringWithFormat:@"Leads for %@",_selectedCompany];
    } else {
        sectionName = @"";
    }
    return sectionName;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[fetchedResultsController sections] objectAtIndex:section]
			numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell withLead:(Job *)lead {

	NSString *tmpTitle = (lead.date != nil) ? [Common stringFromDate:lead.date] : @"";
	if ([lead.company length] > 0) { tmpTitle = [tmpTitle stringByAppendingFormat:@" ~ %@",lead.company]; }
	if ([lead.type length] > 0) { tmpTitle = [tmpTitle stringByAppendingFormat:@" ~ %@",lead.type]; }

	cell.textLabel.text = lead.title;
	cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
	
	cell.detailTextLabel.text = tmpTitle;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";

	Job *lead = [fetchedResultsController objectAtIndexPath:indexPath];
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}
   	
	[self configureCell:cell withLead:lead];

	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Job *lead = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	if(self.jobDetailVC == nil)
		self.jobDetailVC = [[JobDetail alloc] initWithNibName:@"JobDetail" bundle:nil];

	self.jobDetailVC.selectedLead = lead;
	[self.navigationController pushViewController:self.jobDetailVC animated:YES];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
			NSManagedObjectContext *context = 
            [fetchedResultsController managedObjectContext];
			Job *lead = [fetchedResultsController objectAtIndexPath:indexPath];
			[context deleteObject:lead];
			
			// Save the context.
			NSError *error;
			if (![context save:&error]) {
				// Handle the error...
			}
		
    }   
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}


// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return NO;
}

// fetchedResultsController - get data from SQL
- (NSFetchedResultsController *)fetchedResultsController {
	if (fetchedResultsController != nil && _selectedCompany == nil) {
		return fetchedResultsController;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = nil;

    // find leads for specific company if linked from Company detail view
    if (_selectedCompany != NULL) {
        NSLog(@"setting fetch predicate for %@",_selectedCompany);
        predicate = [NSPredicate predicateWithFormat:@"company LIKE[cd] %@", _selectedCompany];
        [fetchRequest setPredicate:predicate];
    }

	NSEntityDescription *entity =
	[NSEntityDescription entityForName:@"Job"
				inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] 
										initWithKey:@"date" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSFetchedResultsController *aFetchedResultsController = 
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
										managedObjectContext:managedObjectContext
										  sectionNameKeyPath:nil
												   cacheName:nil];
	aFetchedResultsController.delegate = self; // <label id="code.RVC.FRC.delegate"/>
	self.fetchedResultsController = aFetchedResultsController;
	
	
	return fetchedResultsController;
}    
//END fetchedResultsController

#pragma mark FRC delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

//START:code.RVC.didChangeObject
- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject 
       atIndexPath:(NSIndexPath *)indexPath 
     forChangeType:(NSFetchedResultsChangeType)type 
      newIndexPath:(NSIndexPath *)newIndexPath {
	
	if(NSFetchedResultsChangeUpdate == type) {
		[self configureCell:[self.tableView cellForRowAtIndexPath:indexPath]
				  withLead:anObject];
	} else if(NSFetchedResultsChangeMove == type) {
		[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0]
					  withRowAnimation:UITableViewRowAnimationFade];
	} else if(NSFetchedResultsChangeInsert == type) {
		if(!self.firstInsert) {
			[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
								  withRowAnimation:UITableViewRowAnimationRight];
		} else {
//			[self.tableView insertSections:[[NSIndexSet alloc] initWithIndex:0] 
//						  withRowAnimation:UITableViewRowAnimationRight];
		}
	} else if(NSFetchedResultsChangeDelete == type) {
		NSInteger sectionCount = [[fetchedResultsController sections] count];
		if(0 == sectionCount) {
			NSIndexSet *indexes = [NSIndexSet indexSetWithIndex:indexPath.section];
			[self.tableView deleteSections:indexes
						  withRowAnimation:UITableViewRowAnimationFade];
		} else {
			[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
								  withRowAnimation:UITableViewRowAnimationFade];
		}
	}
}
//END:code.RVC.didChangeObject

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];
}




@end

