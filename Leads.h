//
//  Leads.h
//  jobagent
//
//  Created by mac on 3/21/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class AppDelegate, JobDetail;

@interface Leads : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
				
	JobDetail *_jobDetailVC; // for linking to job details
	BOOL _firstInsert;
	AppDelegate *appDelegate;
    NSString *_selectedCompany; // for links from Company details

}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet JobDetail *jobDetailVC;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSString *selectedCompany;

- (void)configureCell:(UITableViewCell *)cell 
			withLead:(NSManagedObject *)model;
- (void)customBarButtons;

@end
