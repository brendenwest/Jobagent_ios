//
//  EventDetail.h
//  jobagent
//
//  Created by mac on 3/25/10.
//  Copyright 2010 __MyComeventpanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@class Event, AppDelegate;

@interface EventDetail : UIViewController <UIScrollViewDelegate, UITextFieldDelegate, UITextViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource> {
	
	AppDelegate *del;
    IBOutlet UIScrollView *scrollView;

	UITextField	*action;
	UITextField	*company;
	UITextField	*person;
	UITextField	*jobtitle;
	UITextField	*jobid;
    UIView *activeField;

	UIButton *btnDate;
	UIButton *btnCurrent;
	UIButton *btnCompanies;
	UIButton *btnActions;
	UIButton *btnPeople;
	UIButton *btnJobs;
	UIButton *btnCompany;
	UIButton *btnPerson;
	UIButton *btnJob;
	
	UITextView *description;
	Event *_selectedEvent;

	UIDatePicker *datePickerView;
	UIPickerView	*myPickerView;
	NSMutableArray	*pickerViewArray;

	NSMutableArray *aCompanies;
	NSMutableArray *aJobs;
	NSMutableArray *aPeople;
	NSMutableArray *aEvents;

	NSDateFormatter *dateFormatter; 	

}

@property (nonatomic, strong) AppDelegate *del;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UITextField *action;
@property (nonatomic, strong) IBOutlet UITextField *person;
@property (nonatomic, strong) IBOutlet UITextField *jobtitle;
@property (nonatomic, strong) IBOutlet UITextField *jobid;
@property (nonatomic, strong) IBOutlet UITextField *company;

@property (nonatomic, strong) IBOutlet UIButton *btnDate;
@property (nonatomic, strong) UIButton *btnCurrent;
@property (nonatomic, strong) IBOutlet UIButton *btnCompanies;
@property (nonatomic, strong) IBOutlet UIButton *btnActions;
@property (nonatomic, strong) IBOutlet UIButton *btnPeople;
@property (nonatomic, strong) IBOutlet UIButton *btnJobs;

@property (nonatomic, strong) IBOutlet UITextView *description;

@property (nonatomic, strong) Event *selectedEvent;

@property (nonatomic, strong) UIDatePicker *datePickerView;
@property (nonatomic, strong) UIPickerView *myPickerView;
@property (nonatomic, strong) NSMutableArray *pickerViewArray;
@property (nonatomic, strong) NSMutableArray *aEvents;
@property (nonatomic, strong) NSMutableArray *aCompanies;
@property (nonatomic, strong) NSMutableArray *aPeople;
@property (nonatomic, strong) NSMutableArray *aJobs;

@property double scrollUp;
@property double scrollDown;

@property (nonatomic, strong) NSDateFormatter *dateFormatter; 

- (IBAction)showPicker:(id)sender;		// for showing action selector
- (IBAction)switchView:(id)sender;		// for showing action selector

@end
