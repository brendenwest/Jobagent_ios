//
//  CompanyDetail.m
//  jobagent
//
//  Created by mac on 3/29/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "CompanyDetail.h"
#import "Company.h"
#import "SearchJobs.h"
#import "Leads.h"
#import "People.h"
#import "Common.h"
#import "AppDelegate.h"

@implementation CompanyDetail

@synthesize btnExternalLinks;


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

	for (UIView* view in self.view.subviews) {
		if ([view isKindOfClass:[UITextField class]] || [view isKindOfClass:[UITextView class]])
			[view resignFirstResponder];
	}
}


- (void) loadExternalLink:(id)sender {
    NSInteger tmpSegment = [sender selectedSegmentIndex];
    NSString *url;
    NSString *curZip = [[NSUserDefaults standardUserDefaults]  stringForKey:@"postalcode"];

    if ([_selectedCompany.name length] > 0) {

        if (tmpSegment == 0 ) { // link to map
                url = [NSString stringWithFormat:@"http://maps.apple.com/?q=%@&near=%@", [_selectedCompany.name stringByReplacingOccurrencesOfString:@" " withString:@"+"], curZip];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];

        } else if (tmpSegment == 1 ) { // link to LinkedIn
            url = [NSString stringWithFormat:@"https://www.linkedin.com/company/%@", [_selectedCompany.name stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        } else if (tmpSegment == 2) {
            if(_leadsVC == nil)
                _leadsVC = [[Leads alloc] initWithNibName:nil bundle:nil];
            
            _leadsVC.selectedCompany = _selectedCompany.name;
            [self.navigationController pushViewController:_leadsVC animated:YES];
        } else if (tmpSegment == 3) {
            if(_contactsVC == nil)
                _contactsVC = [[People alloc] initWithNibName:nil bundle:nil];
            
            _contactsVC.selectedCompany = _selectedCompany.name;
            [self.navigationController pushViewController:_contactsVC animated:YES];

        } else if (tmpSegment == 4) {
            if (![Common connectedToNetwork]) {
                UIAlertView *noNetworkAlert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"STR_NO_NETWORK", nil) delegate:NULL cancelButtonTitle:@"Ok" otherButtonTitles:NULL];
                [noNetworkAlert show];
            } else {
                if(_searchVC == nil)
                    _searchVC = [[SearchJobs alloc] initWithNibName:@"SearchJobs" bundle:nil];
                
                _searchVC.keyword = _selectedCompany.name;
                _searchVC.curLocation = ([_selectedCompany.location length] > 0) ? _selectedCompany.location : curZip;
                _searchVC.curLocale = [[NSUserDefaults standardUserDefaults]  stringForKey:@"countryCode"];
                
                [self.navigationController pushViewController:_searchVC animated:YES];
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
    return coKeys.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *itemKey = [coKeys objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:itemKey];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:itemKey];
    }
    
    UILabel *label, *detailText;
    
    // if cell has rendered previously, re-use existing subviews
    if ([cell.contentView.subviews count] == 0) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 60.0, 25.0)];
        label.font = [UIFont systemFontOfSize:10.0];
        label.textAlignment = NSTextAlignmentLeft ;
        label.textColor = [UIColor grayColor];
        label.text = [coLabels objectAtIndex:indexPath.row];
        
        
        detailText = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 0.0, [[UIScreen mainScreen] bounds].size.width-80, 44.0)];
        detailText.font = [UIFont systemFontOfSize:14.0];
        detailText.textAlignment = NSTextAlignmentLeft;
        detailText.textColor = [UIColor blackColor];
    } else if ([cell.contentView.subviews count] > 1) {
        // don't modify datePicker cell
        label = cell.contentView.subviews[0];
        label.text = [coLabels objectAtIndex:indexPath.row];
        detailText = cell.contentView.subviews[1];
    }
    
    
    // Configure cell for different content types
    if ([itemKey isEqualToString:@"name"]) {
        // add text field for manual edit of Name field
        if ([cell.contentView.subviews count] == 0) {
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:[[UITextField alloc] initWithFrame:CGRectMake(65.0, 0.0, [[UIScreen mainScreen] bounds].size.width-80, 44.0)]];
        }
        UITextField *detailTextField = cell.contentView.subviews[1];
        detailTextField.delegate = self;
        detailTextField.returnKeyType = UIReturnKeyDone;
        detailTextField.text = [_selectedCompany valueForKey:itemKey];
    } else {
        detailText.text = [_selectedCompany valueForKey:itemKey];
        if ([cell.contentView.subviews count] == 0) {
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:detailText];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // store text ID of selected row for use when returning from child view
    editedItemId = [coKeys objectAtIndex:indexPath.row];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([cell.reuseIdentifier isEqualToString:@"type"]) {
        
        PickList *pickList = [[PickList alloc] init];
        pickList.header = NSLocalizedString(@"STR_SEL_TYPE", nil);
        pickList.options = coTypes;
        UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
        UILabel *tmpDetail = selectedCell.contentView.subviews[1];
        pickList.selectedItem = tmpDetail.text;
        pickList.delegate = self;
        
        [self.navigationController pushViewController:pickList animated:YES];
        
    } else {
        
        [self performSegueWithIdentifier: @"showItem" sender: cell];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showItem"]) {
        UITableViewCell *selectedCell = sender;
        UILabel *tmpLabel = selectedCell.contentView.subviews[0];
        UILabel *tmpDetail = selectedCell.contentView.subviews[1];
        
        EditItemVC *vc = segue.destinationViewController;
        vc.delegate = self;
        
        [[segue destinationViewController] setLabelText:tmpLabel.text];
        [[segue destinationViewController] setItemText:tmpDetail.text];
        
    }
}

#pragma mark - Protocol methods

-(void)setItemText:(NSString *)editedItemText {
    // on return from field-edit view...
    NSString *itemKey = [editedItemId lowercaseString];
    [_selectedCompany setValue:editedItemText forKey:itemKey];
    
}

-(void)pickItem:(NSString *)item {
    // on return from pickList view...
    NSString *itemKey = [editedItemId lowercaseString];
    [_selectedCompany setValue:item forKey:itemKey];
    
}

#pragma View methods

- (void)viewDidLoad {
    [super viewDidLoad];

    // ensure tableview will be flush to nav bar on return from edit view
    self.automaticallyAdjustsScrollViewInsets = NO;
 
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	if (managedObjectContext == nil)
	{ 
		managedObjectContext = [appDelegate managedObjectContext];
	}
    
    coLabels = [NSArray arrayWithObjects:
                NSLocalizedString(@"STR_COMPANY", nil),
                NSLocalizedString(@"STR_LOCATION", nil),
                NSLocalizedString(@"STR_TYPE", nil),
                NSLocalizedString(@"STR_NOTES", nil), nil];

    coKeys = [NSArray arrayWithObjects:
                 @"name",
                 @"location",
                 @"type",
                 @"notes", nil];

    coTypes = [NSArray arrayWithObjects:
               NSLocalizedString(@"STR_CO_TYPE_DEFAULT", nil),
               NSLocalizedString(@"STR_CO_TYPE_AGENCY", nil),
               NSLocalizedString(@"STR_CO_TYPE_GOVT", nil),
               NSLocalizedString(@"STR_CO_TYPE_EDUC", nil),
               NSLocalizedString(@"STR_OTHER", nil), nil];
    
    
    // configure link controls
    [btnExternalLinks addTarget:self action:@selector(loadExternalLink:) forControlEvents:UIControlEventValueChanged];

}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    // populate table of company data
    [self.tableView reloadData];

    // Log pageview w/ Google Analytics
    [appDelegate trackPVFull:@"Company" :@"Co name" :@"detail" :_selectedCompany.name];

}


#pragma mark textView methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    _selectedCompany.name = textField.text;
}

- (void)saveCompany {
    
	NSError *error = nil;
	if (![_selectedCompany.managedObjectContext save:&error]) {
        // Handle the error...
	}
    
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        // Navigating to item editor
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack (exiting to Leads)
        if (_selectedCompany.name.length > 0) {
            [self saveCompany];
        } else {
            // delete empty record
            [_selectedCompany.managedObjectContext deleteObject:_selectedCompany];
        }
        
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
    [super viewDidUnload];
}




@end
