//
//  CompanyDetail.h
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>
#import "EditItemVC.h"
#import "PickList.h"

@class AppDelegate, Company, LeadDetail, PersonDetail, SearchJobs, Leads, People;

@interface CompanyDetail : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, EditItemDelegate, PickListDelegate> {
	
	AppDelegate *appDelegate;
    
	NSManagedObjectContext *managedObjectContext;
	Company *_selectedCompany;
    
	SearchJobs *_searchVC;
	Leads *_leadsVC;
	People *_contactsVC;

    NSArray *coTypes;
    NSArray *coLabels;
    NSArray *coKeys;
    NSString *editedItemId;

	IBOutlet UISegmentedControl *btnInternalLinks;
	
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UISegmentedControl *btnExternalLinks;

@property (nonatomic, strong) Company *selectedCompany;

@end

