//
//  EventDetail.m
//  jobagent
//
//  Created by mac on 3/25/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "EventDetail.h"
#import "Event.h"
#import "AppDelegate.h"

@implementation EventDetail

@synthesize del, scrollView, dateFormatter, action, person, company, jobtitle, jobid, btnDate, btnCurrent, btnCompanies, btnActions, btnPeople, btnJobs, description, datePickerView, myPickerView;
@synthesize pickerViewArray, aCompanies, aJobs, aEvents, aPeople;

@synthesize selectedEvent = _selectedEvent;

- (IBAction)switchView:(id)sender 
{ }

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
	
	if (btnCurrent == btnDate) {
		if ([btnCurrent.currentTitle length] > 0) {
			self.datePickerView.date = [self.dateFormatter dateFromString:btnCurrent.currentTitle];
		}
		datePickerView.hidden = NO;
	} else {
		myPickerView.hidden = NO;
		if (btnCurrent == btnCompanies) {			
			[self.pickerViewArray setArray:self.aCompanies];
		}
		else if (btnCurrent == btnActions) {
			[self.pickerViewArray setArray:self.aEvents];
		}
		else if (btnCurrent == btnPeople) {
			[self.pickerViewArray setArray:self.aPeople];
		}
		else if (btnCurrent == btnJobs) {
			[self.pickerViewArray setArray:self.aJobs];
		}
		[myPickerView reloadAllComponents];
	}
	
}


// return the picker frame based on its size, positioned at the bottom of the page
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
								   screenRect.size.height - 84.0 - size.height,
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
	//
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

#pragma Helper methods

- (void) backgroundTouched {
    
	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}

// Call this method somewhere in your view controller setup code.
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
    
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Homebrewed
    _scrollUp = (activeField.frame.origin.y + activeField.frame.size.height) - (self.view.frame.size.height-kbSize.height+scrollView.contentOffset.y);
    if (_scrollUp > 0) {
        
        CGPoint scrollPoint = CGPointMake(0.0, _scrollUp);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
    
}


// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (_scrollUp > 0) {
        
        CGPoint scrollPoint = CGPointMake(0.0, _scrollDown);
        [scrollView setContentOffset:scrollPoint animated:YES];
        _scrollUp = 0;
    }
}

// end Helper methods
//*******


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Activity";

    // allow user to dismiss keyboard by tapping background screen
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched)];
    
    // make sure gesture recognizer doesn't cancel button touches
    singleTap.cancelsTouchesInView = NO;
    
    [scrollView addGestureRecognizer: singleTap];
    scrollView.contentSize = self.view.frame.size;
    scrollView.delegate = self;
    
    [self registerForKeyboardNotifications];

	self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
	
	self.pickerViewArray = [[NSMutableArray alloc] init];
	[self createPicker];	
	[self createDatePicker];	
	
	del = (AppDelegate *)[UIApplication sharedApplication].delegate;
	description.delegate = self;

	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	action.text = _selectedEvent.action;	
	company.text = _selectedEvent.company;
	person.text = _selectedEvent.person;
	jobtitle.text = _selectedEvent.jobtitle;	
	jobid.text = _selectedEvent.jobid;	

	description.text =  (_selectedEvent.notes != nil) ? _selectedEvent.notes : @"";

	// set value for date button 
	NSString *tmpTitle = [del getShortDate:[NSString stringWithFormat:@"%@",_selectedEvent.date]];    
	[btnDate setTitle:tmpTitle forState:UIControlStateNormal];
	
	aEvents = [NSMutableArray arrayWithObjects:@"Phone screen", @"Application", @"Interview", @"E-mail", @"Job fair", @"Other", nil];
	
	[aEvents addObjectsFromArray:[[del getEvents:nil] valueForKey:@"title"]];

	aJobs = [NSMutableArray arrayWithArray:[[del getJobs:nil] valueForKey:@"title"]];
	if ([aJobs count] > 0) {
		btnJobs.hidden = NO;
	}
    
    // Populate picker view for people
	NSArray *tmp = [del getPeople:nil];
	aPeople = [[NSMutableArray alloc] init];
	for (int i=0;i< [tmp count] ; i++) {
		[aPeople addObject:[NSString stringWithFormat:@"%@ %@",[[tmp objectAtIndex:i] valueForKey:@"firstName"],[[tmp objectAtIndex:i] valueForKey:@"lastName"]]];
	}

	if ([aPeople count] > 0) {
		btnPeople.hidden = NO;
	}
	aCompanies = [NSMutableArray arrayWithArray:[[del getCompanies:nil] valueForKey:@"coName"]];
	if ([aCompanies count] > 0) {
		btnCompanies.hidden = NO;
	}

	description.layer.cornerRadius = 8;
	description.layer.borderWidth = 1;
	description.layer.borderColor = [[UIColor grayColor] CGColor];
	
    [del trackPV:@"Diary Activity"];

}

#pragma mark textField methods

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
	
}



#pragma mark textView methods


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text { if([text isEqualToString:@"\n"]) [textView resignFirstResponder]; return YES; }

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    activeField = textView;
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	self.selectedEvent.notes = description.text;
	[textView resignFirstResponder];
}

- (void)textViewShouldReturn:(UITextView *)textView {
	[textView resignFirstResponder];
}

#pragma mark -
#pragma mark UIPickerViewDelegate

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if (pickerView == myPickerView)	// don't show selection for the custom picker
	{
		if (btnCurrent == btnCompanies) { 
			company.text = [self.aCompanies objectAtIndex:[pickerView selectedRowInComponent:0]];
		}
		else if (btnCurrent == btnActions) {
			action.text = [self.aEvents objectAtIndex:[pickerView selectedRowInComponent:0]];
		}
		else if (btnCurrent == btnPeople) {
			person.text = [self.aPeople objectAtIndex:[pickerView selectedRowInComponent:0]];
		}
		else if (btnCurrent == btnJobs) {
			jobtitle.text = [self.aJobs objectAtIndex:[pickerView selectedRowInComponent:0]];
		}
		// report the selection to the UI label
		pickerView.hidden = YES;
		[self textFieldDidEndEditing:action];

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

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    if (action.text.length > 0) {
        self.selectedEvent.action = action.text;
        self.selectedEvent.company = company.text;
        if ([company.text length] > 0) {
            [del setCompany:company.text];
        }

        self.selectedEvent.person = person.text;
        if ([person.text length] > 0) {
            [del setPerson:person.text withCo:company.text];
        }

        self.selectedEvent.jobtitle = jobtitle.text;
        self.selectedEvent.jobid = jobid.text;
        self.selectedEvent.date = [del dateFromString:btnDate.currentTitle];
        
        NSError *error = nil;
        if (![self.selectedEvent.managedObjectContext save:&error]) {
            // Handle the error...
            NSLog(@"Error saving %@, %@", error, [error userInfo]);
        }
    } else {
        // delete empty job lead record
        [self.selectedEvent.managedObjectContext deleteObject:self.selectedEvent];
    }
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// release all the other objects
	self.myPickerView = nil;
	self.pickerViewArray = nil;
}




@end
