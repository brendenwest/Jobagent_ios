//
//  CompanyDetail.m
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "CompanyDetail.h"
#import "SearchJobs.h"
#import "Leads.h"
#import "People.h"
#import "Company.h"
#import "Common.h"
#import "AppDelegate.h"

NSInteger currentType = 0;
NSString *textViewPlaceholder = @"notes";

@implementation CompanyDetail

@synthesize coName, tableCoType, notes, userSettings, btnExternalLinks, coTypes;
@synthesize selectedCompany = _selectedCompany;
@synthesize searchVC = searchVC;
@synthesize leadsVC = leadsVC;
@synthesize contactsVC = contactsVC;
@synthesize managedObjectContext;


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}


- (void) loadExternalLink:(id)sender {
    NSInteger tmpSegment = [sender selectedSegmentIndex];
    NSString *url;
    NSLog(@"loading # %i", tmpSegment);
    
    if ([coName.text length] > 0) {

        if (tmpSegment == 0 ) { // link to map
                url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@&near=%@", [coName.text stringByReplacingOccurrencesOfString:@" " withString:@"+"], [userSettings valueForKey:@"postalcode"]];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

        } else if (tmpSegment == 1 ) { // link to LinkedIn
            url = [NSString stringWithFormat:@"https://www.linkedin.com/company/%@", [coName.text stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else if (tmpSegment == 2) {
            if(self.leadsVC == nil)
                self.leadsVC = [[Leads alloc] initWithNibName:nil bundle:nil];
            
            self.leadsVC.selectedCompany = coName.text;
            [self.navigationController pushViewController:self.leadsVC animated:YES];
        } else if (tmpSegment == 3) {
            if(_contactsVC == nil)
                _contactsVC = [[People alloc] initWithNibName:nil bundle:nil];
            
            _contactsVC.selectedCompany = coName.text;
            [self.navigationController pushViewController:_contactsVC animated:YES];

        } else if (tmpSegment == 4) {
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
    } else {
        // show alert about company name
    }
    btnExternalLinks.selectedSegmentIndex = nil;

}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [coTypes count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"Cell";    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	cell.textLabel.text = [coTypes objectAtIndex:indexPath.row];
	cell.textLabel.font = [UIFont systemFontOfSize:14];
    if (indexPath.row == currentType) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:currentType inSection:0];
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    if (newCell.accessoryType == UITableViewCellAccessoryNone) {
        newCell.accessoryType = UITableViewCellAccessoryCheckmark;
        currentType = indexPath.row;
    }
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = @"Company";

    if (IS_OS_7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }

	if (managedObjectContext == nil)
	{ 
		managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext]; 
	}
	if (userSettings == nil) 
	{ 
		self.userSettings = [(AppDelegate *)[[UIApplication sharedApplication] delegate] userSettings]; 
	}

    coTypes = [NSArray arrayWithObjects:@"Default",@"Agency",@"Govt",@"Training", nil];
    
    tableCoType.dataSource = self;
    
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = @"Back";
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    
    // configure link controls
    [btnExternalLinks addTarget:self action:@selector(loadExternalLink:) forControlEvents:UIControlEventValueChanged];

}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    [Common formatTextView:notes:textViewPlaceholder];
    NSLog(@"company name - %@",self.selectedCompany.coName);
    
    coName.text = _selectedCompany.coName;
    if (_selectedCompany.coType != NULL) {
        currentType = [coTypes indexOfObject:_selectedCompany.coType];
    }
    if (_selectedCompany.notes != NULL) {
        notes.text = _selectedCompany.notes;
    }

    // populate table of company types
    [self.tableCoType reloadData];
//    [tableCoType selectRowAtIndexPath:[NSIndexPath indexPathForRow:currentType inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];


    // Log pageview w/ Google Analytics
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] trackPVFull:@"Company" :@"Co name" :@"detail" :_selectedCompany.coName];

}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField*)textField
{
    
}

#pragma mark textView methods

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text { if([text isEqualToString:@"\n"]) [textView resignFirstResponder]; return YES; }

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:textViewPlaceholder]) {
        textView.text = @"";
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = textViewPlaceholder;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}


- (void)viewWillDisappear:(BOOL)animated {
    // save entries only if name is entered
	if ([coName.text length] > 0) {

        // save any user edits
        self.selectedCompany.coName = coName.text;
        self.selectedCompany.coType = [coTypes objectAtIndex:currentType];
        self.selectedCompany.notes = notes.text;
        currentType = 0;

        NSError *error = nil;
        if (![self.selectedCompany.managedObjectContext save:&error]) {
            // Handle the error...
            NSLog(@"Error saving %@, %@", error, [error userInfo]);
        }
        
    } else if (managedObjectContext) {
        // delete record with no company name
        [self.selectedCompany.managedObjectContext deleteObject:self.selectedCompany];
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
