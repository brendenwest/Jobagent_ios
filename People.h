//
//  People.h
//  jobagent
//
//  Created by mac on 4/1/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class PersonDetail;

@interface People : UITableViewController <NSFetchedResultsControllerDelegate> {
	NSFetchedResultsController *fetchedResultsController;
	NSManagedObjectContext *managedObjectContext;
	
	PersonDetail *_personDetailVC; // for linking to details
	BOOL _firstInsert;
	
}
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet PersonDetail *personDetailVC;

- (void)configureCell:(UITableViewCell *)cell 
		  withPerson:(NSManagedObject *)model;
- (void)customBarButtons;

@end
