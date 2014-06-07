//
//  CompanyDetail.h
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <QuartzCore/QuartzCore.h>

@class Company, LeadDetail, PersonDetail, SearchJobs, Leads, People;

@interface CompanyDetail : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate> {
	
	UITextField	*coName;
	UITableView *tableCoType;
	UITextView	*notes;
    
	NSManagedObjectContext *managedObjectContext;
	Company *_selectedCompany;
	SearchJobs *_searchVC;
	Leads *_leadsVC;
	People *_contactsVC;
	
	IBOutlet UISegmentedControl *btnInternalLinks;
	IBOutlet UISegmentedControl *btnExternalLinks;
	
}

@property (nonatomic, strong) IBOutlet UITextField *coName;
@property (nonatomic, strong) IBOutlet UITableView *tableCoType;
@property (nonatomic, strong) IBOutlet UITextView *notes;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) Company *selectedCompany;

@property (nonatomic, strong) NSArray *coTypes;

@property (nonatomic, strong) SearchJobs *searchVC; // for linking to job search
@property (nonatomic, strong) Leads *leadsVC; // for linking to job search
@property (nonatomic, strong) People *contactsVC; // for linking to job search

@property (nonatomic, strong) IBOutlet UISegmentedControl *btnExternalLinks;


@end

