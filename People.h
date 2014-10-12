//
//  People.h
//  jobagent
//
//  Created by mac on 4/1/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class PersonDetail;

@interface People : UITableViewController <NSFetchedResultsControllerDelegate> {
    
	BOOL _firstInsert;

}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSString *selectedCompany;

- (void)configureCell:(UITableViewCell *)cell 
		  withPerson:(NSManagedObject *)model;

@end
