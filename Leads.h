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
    
    AppDelegate *appDelegate;
	BOOL _firstInsert;

}

@property (nonatomic, strong) NSString *selectedCompany;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell
			withLead:(NSManagedObject *)model;

@end
