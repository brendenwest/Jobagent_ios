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

@synthesize managedObjectContext, fetchedResultsController;


- (void)viewDidLoad {
    [super viewDidLoad];
    
	appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
	if (managedObjectContext == nil)
	{ 
		managedObjectContext = [appDelegate managedObjectContext];
	}
	
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // handle the error...
    }

    // create array of button properties for use by toolbar button constructor
    NSArray* buttons = @[
                         @[@4,@"insertItem",self],
                         @[@2,@"",self]
                         ];
    
    // and put the toolbar in the nav bar
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[Common customBarButtons:buttons]];
    
}

// Insert new item
- (void)insertItem {
	self.firstInsert = [self.fetchedResultsController.sections count] == 0;
	[self performSegueWithIdentifier: @"showJobDetail" sender: fetchedResultsController];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:(BOOL)animated];
    [self.tableView reloadData];
    
    [appDelegate trackPV:self.title];

}



- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];

    // Release any retained subviews of the main view.
	self.fetchedResultsController = nil;
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
    
    [self performSegueWithIdentifier: @"showJobDetail" sender:tableView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showJobDetail"]) {
        Job *lead;
        if (sender == self.tableView) {
            NSIndexPath *indexPath = [sender indexPathForSelectedRow];
            lead = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        } else {
            NSManagedObjectContext *context =
            [self.fetchedResultsController managedObjectContext];
            NSEntityDescription *entity =
            [self.fetchedResultsController.fetchRequest entity];
            lead = [NSEntityDescription insertNewObjectForEntityForName:[entity name]
                                                   inManagedObjectContext:context];
        }
        
        [[segue destinationViewController] setSelectedLead:lead];
        
    }
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

