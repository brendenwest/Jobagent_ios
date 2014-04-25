//
//  CompanyDetail.m
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "CompanyDetail.h"
#import "LeadDetail.h"
#import "SearchJobs.h"
#import "Company.h"
#import "Job.h"
#import "Person.h"
#import "PersonDetail.h"
#import "AppDelegate.h"

@implementation CompanyDetail

@synthesize coName, coType, notes, people, jobs, tblJobsPeople, userSettings, myPickerView, pickerViewArray, btnMap, btnType, btnJobsPeople;
@synthesize selectedCompany = _selectedCompany;
@synthesize leadVC = leadVC;
@synthesize personVC = personVC;
@synthesize searchVC = searchVC;
@synthesize managedObjectContext;

- (IBAction) showPicker:(id)sender { 
	myPickerView.hidden = NO;
	// add the "Done" button to the nav bar
	UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone  target:self action:@selector(doneAction:)];	
	self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)doneAction:(id)sender 
{
	
	// remove the "Done" button in the nav bar
	self.navigationItem.rightBarButtonItem = nil;
	myPickerView.hidden = YES;
	
}

- (IBAction) switchView:(id)sender {

	NSInteger tmpSegment = [sender selectedSegmentIndex];
    
    if (tmpSegment == 0 || tmpSegment == 1) { // jobs or people
        [self.tblJobsPeople reloadData]; 
    } else if (tmpSegment == 2 && coName.text.length > 0) {
        if (![(AppDelegate *)[[UIApplication sharedApplication] delegate] connectedToNetwork]) {
            UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Network connection \nappears to be offline" delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
            [noNetworkAlert show];        
        } else {

            if(self.searchVC == nil)
                self.searchVC = [[SearchJobs alloc] initWithNibName:@"SearchJobs" bundle:nil];
            
            self.searchVC.txtSearch = coName.text;
            self.searchVC.txtZip = [self.userSettings valueForKey:@"postalcode"];
            self.searchVC.txtLat = [self.userSettings valueForKey:@"lat"];
            self.searchVC.txtLng = [self.userSettings valueForKey:@"lng"];
            
            [self.navigationController pushViewController:self.searchVC animated:YES];
        }
    }
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}


- (IBAction) searchMap:(id)sender { 
	if ([coName.text length] > 0) {
		NSString *url = [NSString stringWithFormat:@"http://maps.google.com/maps?mrt=yp&q=%@&near=%@", [coName.text stringByReplacingOccurrencesOfString:@" " withString:@"+"], [userSettings valueForKey:@"postalcode"]];

		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
	}
}

- (void)checkTextFields {
    btnMap.hidden = ([coName.text length] > 0) ? NO : YES;
}


// return the picker frame based on its size, positioned at the bottom of the page
- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	CGRect pickerRect = CGRectMake(	0.0,
								   screenRect.size.height - 54.0 - size.height,
								   size.width,
								   size.height);
	return pickerRect;
}

#pragma mark -
#pragma mark UIPickerView
- (void)createPicker
{
	pickerViewArray = [NSArray arrayWithObjects:
						@"Primary", @"Temp Agency", @"Consulting", @"Recruiter", @"Other",
						nil];
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


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (btnJobsPeople.selectedSegmentIndex == 1) {
		return [people count];
	} else {
		return [jobs count];
     }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	if (btnJobsPeople.selectedSegmentIndex == 0 && [self.jobs count] > 0) {
		Job *lead = [self.jobs objectAtIndex:indexPath.row];
		NSString *tmpTitle = lead.title;
		if ([lead.type length] > 0) { tmpTitle = [tmpTitle stringByAppendingFormat:@"; %@",lead.type]; }
		if ([lead.pay length] > 0) { tmpTitle = [tmpTitle stringByAppendingFormat:@"; %@",lead.pay]; }
		cell.textLabel.text = tmpTitle;
	} else if (btnJobsPeople.selectedSegmentIndex == 1) {
		Person *person = [people objectAtIndex:indexPath.row];
		NSString *tmpTitle = (person.title.length > 0) ? person.title : @"";
        
		cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ - %@", person.firstName, person.lastName, tmpTitle];
	}

	cell.textLabel.font = [UIFont boldSystemFontOfSize:14];	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (btnJobsPeople.selectedSegmentIndex == 0) {
		Job *lead = [jobs objectAtIndex:indexPath.row];
		if(self.leadVC == nil)
			self.leadVC = [[LeadDetail alloc] initWithNibName:@"LeadDetail" bundle:nil];
		
		self.leadVC.selectedLead = lead;
		[self.navigationController pushViewController:self.leadVC animated:YES];
	} else {
		Person *person = [people objectAtIndex:indexPath.row];
		if(self.personVC == nil)
			self.personVC = [[PersonDetail alloc] initWithNibName:@"PersonDetail" bundle:nil];
		
		self.personVC.selectedPerson = person;
		[self.navigationController pushViewController:self.personVC animated:YES];
	}

}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Company";

	if (managedObjectContext == nil) 
	{ 
		managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
	}
	if (userSettings == nil) 
	{ 
		self.userSettings = [(AppDelegate *)[[UIApplication sharedApplication] delegate] userSettings]; 
	}

    jobs = [[NSMutableArray alloc] init];
	people = [[NSMutableArray alloc] init];

	tblJobsPeople.dataSource = self;

    [self checkTextFields];
    
	[self createPicker];

    notes.layer.cornerRadius = 8;
	notes.layer.borderWidth = 1;
	notes.layer.borderColor = [[UIColor grayColor] CGColor];	

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
    
    coName.text = _selectedCompany.coName;
	notes.text = _selectedCompany.notes;
	coType.text = _selectedCompany.coType;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
     
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"company LIKE[cd] %@", _selectedCompany.coName];
	[fetchRequest setPredicate:predicate];	
    
    // fetch jobs by company
	[fetchRequest setEntity: [NSEntityDescription entityForName:@"Job" inManagedObjectContext:managedObjectContext]];
    
    NSError *error = nil;
	NSArray *fetchResults = [managedObjectContext executeFetchRequest: fetchRequest error: &error];
    
	[self.jobs setArray:fetchResults];
	[tblJobsPeople reloadData];
    
    // fetch people by company
	[fetchRequest setEntity: [NSEntityDescription entityForName:@"Person" inManagedObjectContext:managedObjectContext]];
    
	fetchResults = [managedObjectContext executeFetchRequest: fetchRequest error: &error];
	[self.people setArray:fetchResults];

    // Log pageview w/ Google Analytics
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] trackPVFull:@"Company" :@"Co name" :@"detail" :_selectedCompany.coName];

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
	[textField resignFirstResponder];
    [self checkTextFields];
	
}

#pragma mark textView methods

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text { if([text isEqualToString:@"\n"]) [textView resignFirstResponder]; return YES; }

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
	return YES;
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
		// report the selection to the UI label
		coType.text = [NSString stringWithFormat:@"%@",
					   [pickerViewArray objectAtIndex:[pickerView selectedRowInComponent:0]]];
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
			returnStr = [[NSNumber numberWithInt:row] stringValue];
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
    // save entries only if name is entered
	if ([coName.text length] > 0) {

        NSError *error = nil;
        if (![self.selectedCompany.managedObjectContext save:&error]) {
            // Handle the error...
            NSLog(@"Error saving %@, %@", error, [error userInfo]);
        }

        self.selectedCompany.coName = coName.text;
        self.selectedCompany.coType = coType.text;
        self.selectedCompany.notes = notes.text;
    } else if (managedObjectContext) {
        // delete record with no company name
        [self.selectedCompany.managedObjectContext deleteObject:self.selectedCompany];
    }
	jobs = nil;
    people = nil;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// release all the other objects
}




@end
