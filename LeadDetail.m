//
//  LeadDetail.m
//  jobagent
//
//  Created by mac on 3/21/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "WebVC.h"
#import "LeadDetail.h"
#import "Job.h"
#import "CompanyDetail.h"
#import "PersonDetail.h"
#import "AppDelegate.h"
#import "Common.h"

@implementation LeadDetail

@synthesize del, scrollView, dateFormatter, jobTitle, company, city, person, link, jobType, pay, btnDate, btnCurrent, description, datePickerView, myPickerView, pickerViewArray, btnJobTypes,btnCompanies,btnPeople,aCompanies,aPeople,aJobs, activeField;
@synthesize btnCompany, btnPerson, btnLink;
@synthesize selectedLead = _selectedLead;
@synthesize companyVC = _companyVC;
@synthesize personVC = _personVC;
@synthesize webVC = _webVC;
@synthesize managedObjectContext;


#pragma Helper methods

- (void) backgroundTouched {
    
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]]) 
			[view resignFirstResponder];
	}
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}


// Call this method in the view controller setup code to register for notifications
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    // get kb height
    // get textfield bottom Y coord
    // if textfield bottom Y coord < KB height (coordinates start from lower left of screen), then move scrollview

    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _scrollDown = scrollView.contentOffset.y;
/*
    NSLog(@"keyboardWasShown");
    NSLog(@"scrollView position = %f",scrollView.contentOffset.y);
    NSLog(@"keyboard height = %f",kbSize.height);
    NSLog(@"old frame height = %f",self.view.frame.size.height);
    NSLog(@"text field name = %@",activeField);
    NSLog(@"old text field origin Y = %f",activeField.frame.origin.y);
    NSLog(@"scrollView contentOffset = %f",scrollView.contentOffset.y); // due to nav bar?
    NSLog(@"Est. keyboard top %f", self.view.frame.size.height-kbSize.height+scrollView.contentOffset.y);
    NSLog(@"is covered? %d",activeField.frame.origin.y > self.view.frame.size.height-kbSize.height+scrollView.contentOffset.y);
    NSLog(@"Est. scroll amount %f",activeField.frame.origin.y - (self.view.frame.size.height-kbSize.height+scrollView.contentOffset.y));

 */
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Homebrewed
    _scrollUp = (activeField.frame.origin.y + activeField.frame.size.height) - (self.view.frame.size.height-kbSize.height+scrollView.contentOffset.y);
    if (_scrollUp > 0) {
//        NSLog(@"scrolling up by %f",_scrollUp);

        CGPoint scrollPoint = CGPointMake(0.0, _scrollUp);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }

}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    NSLog(@"keyboardWashidden");
    if (_scrollUp > 0) {
        NSLog(@"scrolling down by %f",_scrollDown);
        
        CGPoint scrollPoint = CGPointMake(0.0, _scrollDown);
        [scrollView setContentOffset:scrollPoint animated:YES];
        _scrollUp = 0;
    }
}


// end Helper methods
//*******

- (IBAction)doneKey:(id)sender { }
- (IBAction)doneAction:(id)sender 
{
	
	// remove the "Done" button in the nav bar
	self.navigationItem.rightBarButtonItem = nil;
	
	if (btnCurrent == btnDate) {
		[btnCurrent setTitle:[self.dateFormatter stringFromDate:self.datePickerView.date] forState:(UIControlState)UIControlStateNormal];
		datePickerView.hidden = YES;
	} else {
		myPickerView.hidden = YES;
	}

	
}

- (IBAction)showPicker:(id)sender {
	
	// add the "Done" button to the nav bar
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone  target:self action:@selector(doneAction:)];	
	self.navigationItem.rightBarButtonItem = doneButton;
	
	btnCurrent = (UIButton *)sender;
	
	if ([btnCurrent.currentTitle length] > 0) {
		self.datePickerView.date = [self.dateFormatter dateFromString:btnCurrent.currentTitle];
	}
	if (btnCurrent == btnDate) {
		datePickerView.hidden = NO;
	} else {
		myPickerView.hidden = NO;
		if (btnCurrent == btnCompanies) {			
			[self.pickerViewArray setArray:self.aCompanies];
			activeField = company;
		}
		else if (btnCurrent == btnPeople) {
			[self.pickerViewArray setArray:self.aPeople];
			activeField = person;
		}
		else if (btnCurrent == btnJobTypes) {
			[self.pickerViewArray setArray:self.aJobs];
			activeField = jobType;
		}
		[activeField resignFirstResponder];
		[myPickerView reloadAllComponents];
	}

	
}


- (IBAction)switchView:(id)sender {
	if (sender == btnCompany && [company.text length] > 0) {
        
        // save company to DB
		[del setCompany:company.text];
		CompanyDetail *companyVC = [[CompanyDetail alloc]
								  initWithNibName:@"CompanyDetail" bundle:nil];

        // get list of companies, w/ full properties, from DB
		NSArray *companies = [del getCompanies:company.text];
		if ([companies count] > 0) {
            // set company property in CompanyDetail vc
			companyVC.selectedCompany = [companies objectAtIndex:0];
		}

		[self.navigationController pushViewController:companyVC animated:YES];

	}
	else if (sender == btnPerson && [person.text length] > 0) {
		[del setPerson:person.text withCo:company.text];
		PersonDetail *personVC = [[PersonDetail alloc]
								initWithNibName:@"PersonDetail" bundle:nil];
		NSArray *people = [del getPeople:person.text];
		if ([people count] > 0) {
			personVC.selectedPerson = [people objectAtIndex:0];
		}
		[self.navigationController pushViewController:personVC animated:YES];
	}
	else if (sender == btnLink && [link.text length] > 0) {
		WebVC *webVC = [[WebVC alloc]
								  initWithNibName:nil bundle:nil];
		webVC.requestedURL = link.text;
		webVC.title = @"Job Listing";
		[self.navigationController pushViewController:webVC animated:YES];
	}
    
}


// return the picker frame based on its size, positioned at the bottom of the page
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
								   screenRect.size.height - 44.0 - size.height,
								   size.width,
								   size.height);
	return pickerRect;
}

#pragma mark -
#pragma mark UIPickerView
- (void)createPicker
{
	// note we are using CGRectZero for the dimensions of our picker view,
	// this is because picker views have a built in optimum size,
	// you just need to set the correct origin in your view.

	// position the picker at the bottom
	myPickerView = [[UIPickerView alloc] initWithFrame:CGRectZero];
	CGSize pickerSize = [myPickerView sizeThatFits:CGSizeZero];
	myPickerView.frame = [self pickerFrameWithSize:pickerSize];
	
	myPickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	myPickerView.showsSelectionIndicator = YES;	// note this is default to NO
	
	// this view controller is the data source and delegate
	myPickerView.delegate = self;
	myPickerView.dataSource = self;
	
	// add this picker to our view controller, initially hidden
	myPickerView.hidden = YES;
	[self.view addSubview:myPickerView];
}

#pragma mark UIPickerView - Date/Time
- (void)createDatePicker
{
	datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
	datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	datePickerView.datePickerMode = UIDatePickerModeDate;

	//
	// position the picker at the bottom
	CGSize pickerSize = [myPickerView sizeThatFits:CGSizeZero];
	datePickerView.frame = [self pickerFrameWithSize:pickerSize];
	
	// add this picker to our view controller, initially hidden
	datePickerView.hidden = YES;
	[self.view addSubview:datePickerView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Job Details";

    [self registerForKeyboardNotifications];


	del = (AppDelegate *)[UIApplication sharedApplication].delegate;

    // allow user to dismiss keyboard by tapping background screen
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched)];
    
    // make sure gesture recognizer doesn't cancel button touches
    singleTap.cancelsTouchesInView = NO;
    
    [scrollView addGestureRecognizer: singleTap];
    scrollView.contentSize = self.view.frame.size;
    scrollView.delegate = self;

    
	self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];

	pickerViewArray = [[NSMutableArray alloc] init];
	
	[self createPicker];	
	[self createDatePicker];	
	
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;

}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	jobTitle.text = _selectedLead.title;
	company.text = _selectedLead.company;
	city.text = _selectedLead.city;
	person.text = _selectedLead.person;
	link.text = _selectedLead.link;
	jobType.text = _selectedLead.type;
	pay.text = _selectedLead.pay;
	
	description.text =  (_selectedLead.notes != nil) ? _selectedLead.notes : @"";

    [self checkTextFields];

	[btnDate setTitle:[Common shortDate:_selectedLead.date] forState:UIControlStateNormal];

	NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"SELF != NULL"];
	NSArray *aTmp = [NSArray arrayWithObjects:
			  @"FT", @"PT", @"W2 Temp",
			  @"1099", @"Intern", @"Volunteer", @"Other",
			  nil];
	aJobs = [NSMutableArray arrayWithArray:[[del getJobs:nil] valueForKey:@"type"]];

	[aJobs filterUsingPredicate:sPredicate];
	
    // add job type user entered manually
	for (int i=0; i<[aTmp count]; i++) {
		if (![aJobs containsObject:[aTmp objectAtIndex:i]]) {
			[aJobs addObject:[aTmp objectAtIndex:i]];
		}
	}
	if ([aJobs count] > 0) {
		btnJobTypes.hidden = NO;
	}
	
	NSArray *tmp = [del getPeople:nil];
	aPeople = [[NSMutableArray alloc] init];
	for (int i=0;i< [tmp count] ; i++) {
		[aPeople addObject:[NSString stringWithFormat:@"%@ %@",[[tmp objectAtIndex:i] valueForKey:@"firstName"],[[tmp objectAtIndex:i] valueForKey:@"lastName"]]];
	}
	
	if ([aPeople count] > 0) {
		btnPeople.hidden = NO;
	}
	
	aCompanies = [NSMutableArray arrayWithArray:[[del getCompanies:nil] valueForKey:@"name"]];
	[aCompanies filterUsingPredicate:sPredicate];
	if ([aCompanies count] > 0) {
		btnCompanies.hidden = NO;
	}
	
	description.layer.cornerRadius = 8;
	description.layer.borderWidth = 1;
	description.layer.borderColor = [[UIColor grayColor] CGColor];	

    [del trackPV:@"Lead Details"];

}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == myPickerView)	// don't show selection for the custom picker
	{
		if (btnCurrent == btnCompanies) { 
			company.text = [self.aCompanies objectAtIndex:[pickerView selectedRowInComponent:0]];
			[company setEnabled:TRUE];
		}
		else if (btnCurrent == btnPeople) {
			person.text = [self.aPeople objectAtIndex:[pickerView selectedRowInComponent:0]];
			[person setEnabled:TRUE];
		}
		else if (btnCurrent == btnJobTypes) {
			jobType.text = [self.aJobs objectAtIndex:[pickerView selectedRowInComponent:0]];
			[jobType setEnabled:TRUE];
		}

		pickerView.hidden = YES;
        
        // remove the "Done" button in the nav bar
        self.navigationItem.rightBarButtonItem = nil;
	}
}


#pragma mark -
#pragma mark UIPickerViewDataSource

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	NSString *returnStr = @"";
	
	// note: custom picker doesn't care about titles, it uses custom views
	if (pickerView == myPickerView)
	{
		if (component == 0)
		{
			returnStr = [pickerViewArray objectAtIndex:row];
		}
		else
		{
			returnStr = [[NSNumber numberWithInteger:row] stringValue];
		}
	}
	
	return returnStr;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
	CGFloat componentWidth = 0.0;
	
	if (component == 0)
		componentWidth = 240.0;	// first column size is wider to hold names
	else
		componentWidth = 40.0;	// second column is narrower to show numbers
	
	return componentWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40.0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [pickerViewArray count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}


#pragma mark textView methods

- (void)checkTextFields {
    btnCompany.hidden = ([company.text length] > 0) ? NO : YES;
    btnPerson.hidden = ([person.text length] > 0) ? NO : YES;
    btnLink.hidden = ([link.text length] > 0) ? NO : YES;
}


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text { if([text isEqualToString:@"\n"]) [textView resignFirstResponder]; return YES; }

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    activeField = textView;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
    [self checkTextFields];
	
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	self.selectedLead.notes = description.text;
}

- (void)done {
//	[self.jobType resignFirstResponder];
}



- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    if (jobTitle.text.length > 0) {
        
        self.selectedLead.title = jobTitle.text;
        self.selectedLead.company = company.text;
        if ([company.text length] > 0) {
            [del setCompany:company.text]; // save to SQL
        }
        self.selectedLead.city = city.text;

        self.selectedLead.person = person.text;
        if ([person.text length] > 0) {
            [del setPerson:person.text withCo:company.text];	// save person to SQL
        }

        self.selectedLead.link = link.text;
        self.selectedLead.type = jobType.text;
        self.selectedLead.pay = pay.text;
        self.selectedLead.date = [Common dateFromString:btnDate.currentTitle];

        NSError *error = nil;
        if (![self.selectedLead.managedObjectContext save:&error]) {
            // Handle the error...
            NSLog(@"Error saving %@, %@", error, [error userInfo]);
        }
    } else {
        // delete empty job lead record
        [self.selectedLead.managedObjectContext deleteObject:self.selectedLead];
    }
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.selectedLead = nil;
    myPickerView = nil;
    datePickerView = nil;
}


- (void)dealloc {
	[description setDelegate:nil];

}


@end
