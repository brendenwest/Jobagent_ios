//
//  Companies.h
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class CompanyDetail;

@interface Companies : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	CompanyDetail *_companyDetailVC; // for linking to details
	BOOL _firstInsert;
	
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet CompanyDetail *companyDetailVC;

- (void)configureCell:(UITableViewCell *)cell 
			withCompany:(NSManagedObject *)model;
- (void)customBarButtons;

@end
