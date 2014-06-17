//
//  Events.m
//  jobagent
//
//  Created by mac on 3/25/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "Event.h"
#import "Events.h"
#import "EventDetail.h"
#import "Common.h"

@interface Events()
@property(nonatomic, assign) BOOL firstInsert;
@end


@implementation Events

@synthesize fetchedResultsController, del;
@synthesize managedObjectContext;
@synthesize eventDetailVC = _eventDetailVC;
@synthesize firstInsert = _firstInsert;

static NSString *kTitleNewItem = @"";

- (void)awakeFromNib
{
    // set title here so it applies to both view and tab bar item
    self.title = NSLocalizedString(@"STR_TITLE_DIARY", nil);
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (managedObjectContext == nil)
	{ 
		managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
	}
	
	del = (AppDelegate *)[UIApplication sharedApplication].delegate;

	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
		// handle the error...
	}
	[self customBarButtons];
	
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];

    [del trackPV:self.title];

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

// Insert new item
- (void)insertItem {
	self.firstInsert = [self.fetchedResultsController.sections count] == 0;
	
	NSManagedObjectContext *context = 
	[self.fetchedResultsController managedObjectContext];
	NSEntityDescription *entity = 
	[self.fetchedResultsController.fetchRequest entity];
	Event *event = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
											   inManagedObjectContext:context];
	[event setValue:kTitleNewItem forKey:@"title"];


	if(self.eventDetailVC == nil)
		self.eventDetailVC = [[EventDetail alloc] initWithNibName:@"EventDetail" bundle:nil];
	
	self.eventDetailVC.selectedEvent = event;
	[self.navigationController pushViewController:self.eventDetailVC animated:YES];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[fetchedResultsController sections] count];
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[fetchedResultsController sections] objectAtIndex:section]
			numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell withEvent:(Event *)event {
	NSString *subtitle = (event.date != nil) ? [Common getShortDate:[NSString stringWithFormat:@"%@",event.date]] : @"";
	if ([event.priority length] > 0) {
		subtitle = [NSString stringWithFormat:@"%@ ~ %@",subtitle, event.priority];
	}
	if ([event.company length] > 0) {
		subtitle = [NSString stringWithFormat:@"%@ ~ %@",subtitle, event.company];
	}
	cell.textLabel.text = event.title;
	cell.detailTextLabel.text = subtitle;
}


#pragma mark UITableViewDelegate

// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller
	
	Event *event = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	if(self.eventDetailVC == nil)
		self.eventDetailVC = [[EventDetail alloc] initWithNibName:@"EventDetail" bundle:nil];
	
	self.eventDetailVC.selectedEvent = event;
	[self.navigationController pushViewController:self.eventDetailVC animated:YES];
}


#pragma mark UITableViewDataSource

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-cell"];
		
	}
	
	Event *event = [fetchedResultsController objectAtIndexPath:indexPath];
	[self configureCell:cell withEvent:event];	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;	
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}



// Handle deletions
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSManagedObjectContext *context = 
		[fetchedResultsController managedObjectContext];
		Event *event = [fetchedResultsController objectAtIndexPath:indexPath];
		[context deleteObject:event];
		
		// Save the context.
		NSError *error;
		if (![context save:&error]) {
			// Handle the error...
		}
		
    }   
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

// fetchedResultsController - get data from SQL
- (NSFetchedResultsController *)fetchedResultsController {
	if (fetchedResultsController != nil) {
		return fetchedResultsController;
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = 
	[NSEntityDescription entityForName:@"Event"
				inManagedObjectContext:managedObjectContext];
	[fetchRequest setEntity:entity];
	
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] 
										initWithKey:@"date" ascending:NO];
	[fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	
	NSFetchedResultsController *aFetchedResultsController = 
	[[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
										managedObjectContext:managedObjectContext
										  sectionNameKeyPath:nil
												   cacheName:@"Root"];
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
				   withEvent:anObject];
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

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	self.fetchedResultsController = nil;
	self.eventDetailVC = nil;
}




@end
