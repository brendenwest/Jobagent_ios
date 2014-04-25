//
//  Leads.h
//  jobagent
//
//  Created by mac on 3/21/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class AppDelegate, LeadDetail;

@interface Leads : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
				
	LeadDetail *_leadDetailVC; // for linking to job details
	BOOL _firstInsert;
	AppDelegate *del;

}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet LeadDetail *leadDetailVC;
@property (nonatomic, strong) AppDelegate *del;

- (void)configureCell:(UITableViewCell *)cell 
			withLead:(NSManagedObject *)model;
- (void)customBarButtons;

@end
