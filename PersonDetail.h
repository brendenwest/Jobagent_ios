//
//  PersonDetail.h
//  jobagent
//
//  Created by mac on 4/1/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "EditItemVC.h"
#import "PickList.h"

@class AppDelegate, Person;

@interface PersonDetail : UIViewController <UITableViewDelegate, UITableViewDataSource,  UITextFieldDelegate,  MFMailComposeViewControllerDelegate, EditItemDelegate, PickListDelegate > {

	AppDelegate *appDelegate;
    
    NSManagedObjectContext *managedObjectContext;

    UISegmentedControl *btnContactActions;

    NSArray *contactTypes;
    NSArray *contactLabels;
    NSArray *contactKeys;
    NSString *editedItemId;
    
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnContactActions;

@property (nonatomic, strong) Person *selectedPerson;


@end
