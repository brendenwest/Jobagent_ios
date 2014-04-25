//
//  PersonDetail.m
//  jobagent
//
//  Created by mac on 4/1/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "PersonDetail.h"
#import "Person.h"
#import "AppDelegate.h"
#import "CompanyDetail.h"


@implementation PersonDetail
@synthesize companyVC = _companyVC;

@synthesize del, scrollView, name, pTitle, phone, email, company, activeField, description;
@synthesize btnCompany, btnMail, btnPhone, userSettings;
@synthesize selectedPerson = _selectedPerson;

- (void)sendMail {
    // add check for can't send mail
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    NSArray *recipients = [[NSArray alloc] initWithObjects:email.text, nil]; 
    
    NSString *firstName = [NSString stringWithFormat:@"%@",[name.text substringToIndex:[name.text rangeOfString:@" "].location]];
    NSString *body = [NSString stringWithFormat:@"Hi %@,\n ", firstName];
    
    mailController.mailComposeDelegate = self;
    [mailController setToRecipients:recipients];
    [mailController setMessageBody:body isHTML:YES];
    [self presentViewController:mailController animated:YES completion:NULL];
        
}


- (IBAction)btnPushed:(id)sender {
	if (sender == btnCompany && [company.text length] > 0) {
		[del setCompany:company.text];
		CompanyDetail *companyVC = [[CompanyDetail alloc]
                                    initWithNibName:@"CompanyDetail" bundle:nil];
        
		NSArray *companies = [del getCompanies:company.text];
		if ([companies count] > 0) {
			companyVC.selectedCompany = [companies objectAtIndex:0];
        }
        [self.navigationController pushViewController:companyVC animated:YES];
	}
	else if (sender == btnPhone && [phone.text length] > 0) {
		NSString *tmpString = [NSString stringWithFormat:@"tel://%@", phone.text];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:tmpString]];        
	}
    else if (sender == btnMail && [email.text length] > 0) {
        [self sendMail];
    }
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


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error 
{
	if (error) {
		UIAlertView *cantMailAlert = [[UIAlertView alloc] initWithTitle:@"Mail error" message:[error localizedDescription] delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
		[cantMailAlert show];
	}
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)checkTextFields {
    btnCompany.hidden = ([company.text length] > 0) ? NO : YES;
    btnMail.hidden = ([email.text length] > 0) ? NO : YES;
    btnPhone.hidden = ([phone.text length] > 0) ? NO : YES;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Person";

    // allow user to dismiss keyboard by tapping background screen
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched)];

    // make sure gesture recognizer doesn't cancel button touches
    singleTap.cancelsTouchesInView = NO;
    
    [scrollView addGestureRecognizer: singleTap]; 
    scrollView.contentSize = self.view.frame.size;
    scrollView.delegate = self;
    
    [self registerForKeyboardNotifications];

	if (userSettings == nil)
	{ 
		self.userSettings = [(AppDelegate *)[[UIApplication sharedApplication] delegate] userSettings]; 
	}
	del = (AppDelegate *)[UIApplication sharedApplication].delegate;
	
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	
	// set border around notes field
	description.layer.cornerRadius = 8;
	description.layer.borderWidth = 1;
	description.layer.borderColor = [[UIColor grayColor] CGColor];	
        
}


-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
	NSString *firstName = (_selectedPerson.firstName) ? _selectedPerson.firstName : @"";
	NSString *lastName = (_selectedPerson.lastName) ? _selectedPerson.lastName : @"";
	NSString *sep = ([firstName length] > 0 && [lastName length] > 0) ? @" " : @"";
    
	name.text = [NSString stringWithFormat:@"%@%@%@",firstName, sep, lastName];
	company.text = _selectedPerson.company;
	pTitle.text = _selectedPerson.title;
	phone.text = _selectedPerson.phone;
	email.text = _selectedPerson.email;

    [self checkTextFields];

    [del trackPV:self.title];

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


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    // save entries only if name is entered
	if ([name.text length] > 0) {
    
        if ([name.text rangeOfString:@" "].location != NSNotFound) {
            self.selectedPerson.firstName = [name.text substringToIndex:[name.text rangeOfString:@" "].location];
            self.selectedPerson.lastName = [name.text substringFromIndex:[name.text rangeOfString:@" "].location+1];
            
        } else {
            self.selectedPerson.lastName = name.text;            
            self.selectedPerson.firstName = @"";            
        }
        
        if ([pTitle.text length] > 0) {	
            self.selectedPerson.title = pTitle.text;
        }
        if ([company.text length] > 0) {
            self.selectedPerson.company = company.text;
            [del setCompany:company.text];
        }
        if ([phone.text length] > 0) {
            self.selectedPerson.phone = phone.text;
        }
        if ([email.text length] > 0) {
            self.selectedPerson.email = email.text;
        }
        
        NSError *error = nil;
        if (![self.selectedPerson.managedObjectContext save:&error]) {
            // Handle the error...
            NSLog(@"Error saving %@, %@", error, [error userInfo]);
        }
	} else {
        // delete empty person record
        [self.selectedPerson.managedObjectContext deleteObject:self.selectedPerson];
    
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
}




@end
