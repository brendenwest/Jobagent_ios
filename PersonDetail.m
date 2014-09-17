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


@implementation PersonDetail

@synthesize appDelegate, tableView, btnContactActions, contactTypes, contactKeys, contactLabels, editedItemId;
@synthesize selectedPerson = _selectedPerson;
@synthesize managedObjectContext;

#pragma Mail methods

- (void)sendMail {
    // add check for can't send mail
    
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    NSArray *recipients = [[NSArray alloc] initWithObjects:_selectedPerson.email, nil];
    
    NSString *body = [NSString stringWithFormat:@"Hi %@,\n ", _selectedPerson.firstName];
    
    mailController.mailComposeDelegate = self;
    [mailController setToRecipients:recipients];
    [mailController setMessageBody:body isHTML:YES];
    [self presentViewController:mailController animated:YES completion:NULL];
        
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	if (error) {
		UIAlertView *cantMailAlert = [[UIAlertView alloc] initWithTitle:@"Mail error" message:[error localizedDescription] delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:NULL];
		[cantMailAlert show];
	}
    [controller dismissViewControllerAnimated:YES completion:nil];
}


- (void)segmentAction:(id)sender {
    NSInteger tmpSegment = [sender selectedSegmentIndex];

    if (tmpSegment == 0 && [_selectedPerson.phone length] > 0) {
        
		NSString *urlString = [NSString stringWithFormat:@"tel://%@", _selectedPerson.phone];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
        
	} else if (tmpSegment == 1 && [_selectedPerson.email length] > 0) {
        [self sendMail];
        
    } else if (tmpSegment == 2 && [_selectedPerson.firstName length] > 0) {
        NSString *urlString = [NSString stringWithFormat:@"https://www.linkedin.com/vsearch/p?keywords=%@+%@+%@",_selectedPerson.firstName,_selectedPerson.lastName,_selectedPerson.company];
        NSString *escaped = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:escaped]];
        
    }
    
}


#pragma View methods

- (void)viewDidLoad {
    [super viewDidLoad];
	self.title = NSLocalizedString(@"STR_TITLE_DETAILS", nil);
    if (IS_OS_7_OR_LATER) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
	appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
	if (managedObjectContext == nil)
	{
		managedObjectContext = [appDelegate managedObjectContext];
	}
    
    contactLabels = [NSArray arrayWithObjects:
                NSLocalizedString(@"STR_NAME", nil),
                NSLocalizedString(@"STR_TITLE", nil),
                NSLocalizedString(@"STR_COMPANY", nil),
                NSLocalizedString(@"STR_TYPE", nil),
                NSLocalizedString(@"STR_PHONE", nil),
                NSLocalizedString(@"STR_EMAIL", nil),
                NSLocalizedString(@"STR_NOTES", nil), nil];
    
    contactKeys = [NSArray arrayWithObjects:
              @"name",
              @"title",
              @"company",
              @"type",
              @"phone",
              @"email",
              @"notes", nil];
    
    contactTypes = [NSArray arrayWithObjects:
               NSLocalizedString(@"STR_CONTACT_TYPE_RECRUIT", nil),
               NSLocalizedString(@"STR_CONTACT_TYPE_REF", nil),
               NSLocalizedString(@"STR_OTHER", nil), nil];
    
    tableView.dataSource = self;
    [self adjustUILayout];
	
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = NSLocalizedString(@"STR_BTN_BACK", nil);
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	   
    [btnContactActions addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
}


- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    
    // populate table data
    [self.tableView reloadData];


    [appDelegate trackPV:self.title];

}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        // Navigating to item editor
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack (exiting to Leads)
        if (_selectedPerson.firstName.length > 0) {
            [self saveContact];
        } else {
            // delete empty record
            [self.selectedPerson.managedObjectContext deleteObject:self.selectedPerson];
        }
        
    }
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contactKeys.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *itemKey = [contactKeys objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tView dequeueReusableCellWithIdentifier:itemKey];
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
        label.text = [contactLabels objectAtIndex:indexPath.row];
        
        
        detailText = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 0.0, [[UIScreen mainScreen] bounds].size.width-80, 44.0)];
        detailText.font = [UIFont systemFontOfSize:14.0];
        detailText.textAlignment = NSTextAlignmentLeft;
        detailText.textColor = [UIColor blackColor];
    } else if ([cell.contentView.subviews count] > 1) {
        // don't modify datePicker cell
        label = cell.contentView.subviews[0];
        label.text = [contactLabels objectAtIndex:indexPath.row];
        detailText = cell.contentView.subviews[1];
    }
    
    NSArray *textFields = [NSArray arrayWithObjects:@"name",@"title",@"company",@"phone",@"email", nil];
    
    // Configure cell for different content types
    if ([textFields indexOfObject:itemKey] != NSNotFound) {
        // add text field for manual edit of Name field
        if ([cell.contentView.subviews count] == 0) {
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:[[UITextField alloc] initWithFrame:CGRectMake(65.0, 0.0, [[UIScreen mainScreen] bounds].size.width-80, 44.0)]];
        }
        UITextField *detailTextField = cell.contentView.subviews[1];
        detailTextField.delegate = self;
        detailTextField.tag = indexPath.row;
        detailTextField.returnKeyType = UIReturnKeyDone;
        if ([itemKey isEqualToString:@"phone"]) {
            detailTextField.keyboardType = UIKeyboardTypePhonePad;
        } else if ([itemKey isEqualToString:@"email"]) {
            detailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        }
        if ([itemKey isEqualToString:@"name"]) {
            detailTextField.text = [self getFullName:_selectedPerson.firstName :_selectedPerson.lastName];
        } else {
            detailTextField.text = [_selectedPerson valueForKey:itemKey];
        }
    } else {
        detailText.text = [_selectedPerson valueForKey:itemKey];
        if ([cell.contentView.subviews count] == 0) {
            [cell.contentView addSubview:label];
            [cell.contentView addSubview:detailText];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}


- (void)tableView:(UITableView *)tView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // store text ID of selected row for use when returning from child view
    editedItemId = [contactKeys objectAtIndex:indexPath.row];
    
    [tView deselectRowAtIndexPath:indexPath animated:YES];
    if ([cell.reuseIdentifier isEqualToString:@"type"]) {
        
        PickList *pickList = [[PickList alloc] init];
        pickList.header = NSLocalizedString(@"STR_SEL_TYPE", nil);
        pickList.options = contactTypes;
        UITableViewCell *selectedCell = [tView cellForRowAtIndexPath:indexPath];
        UILabel *tmpDetail = selectedCell.contentView.subviews[1];
        pickList.selectedItem = tmpDetail.text;
        pickList.delegate = self;
        
        [self.navigationController pushViewController:pickList animated:YES];
        
    } else {
        
        EditItemVC *editItemVC = [[EditItemVC alloc] init];
        UITableViewCell *selectedCell = [tView cellForRowAtIndexPath:indexPath];
        UILabel *tmpLabel = selectedCell.contentView.subviews[0];
        editItemVC.labelText = tmpLabel.text;
        UILabel *tmpDetail = selectedCell.contentView.subviews[1];
        editItemVC.itemText = tmpDetail.text;
        editItemVC.delegate = self;
        
        [self.navigationController pushViewController:editItemVC animated:YES];
    }
}

#pragma mark - Protocol methods

-(void)setItemText:(NSString *)editedItemText {
    // on return from field-edit view...
    NSString *itemKey = [editedItemId lowercaseString];
    [_selectedPerson setValue:editedItemText forKey:itemKey];
    
}

-(void)pickItem:(NSString *)item {
    // on return from pickList view...
    NSString *itemKey = [editedItemId lowercaseString];
    [_selectedPerson setValue:item forKey:itemKey];
    
}

#pragma mark Helper methods

- (NSString*)getFullName:(NSString*)firstName :(NSString*)lastName {
    if (firstName == nil) { firstName = @""; }
    if (lastName == nil) { lastName = @""; }
    
	NSString *sep = ([firstName length] > 0 && [lastName length] > 0) ? @" " : @"";
    
	return [NSString stringWithFormat:@"%@%@%@",firstName, sep, lastName];
}

- (NSString*)getNamePart:(NSString*)fullName :(NSString*)part {
    NSString *namePart = @"";
    NSRange range = [fullName rangeOfString:@" "];
    if ([part isEqualToString:@"first"]) {
        namePart = (range.location == NSNotFound) ? fullName : [NSString stringWithFormat:@"%@",[fullName substringToIndex:range.location]];
    } else if ([part isEqualToString:@"last"] && range.location != NSNotFound) {
        namePart = [NSString stringWithFormat:@"%@",[fullName substringFromIndex:range.location+1]];
    } else {
    }
    return namePart;
    
}


- (void)adjustUILayout
{
    // Position segmented control at bottom of screen
    CGRect tableFrame = self.tableView.frame;
    
    if (IS_OS_7_OR_LATER) {
        tableFrame.size.height= [[UIScreen mainScreen] bounds].size.height - 105;
        if ([[UIScreen mainScreen] bounds].size.height == 480) {
            tableFrame.size.height += 30; // shim for 3.5" phones
        }
    } else {
        tableFrame.size.height= [[UIScreen mainScreen] bounds].size.height - 95;
    }
    [tableView setFrame:tableFrame];
    
    CGRect btnFrame = self.btnContactActions.frame;
    btnFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - 154;
    [btnContactActions setFrame:btnFrame];
    
}

- (void)saveContact {

	NSError *error = nil;
	if (![_selectedPerson.managedObjectContext save:&error]) {
        // Handle the error...
	}
    
}

-(void)scrollTable:(UITextField*)textField :(BOOL)keyboardIsShown {

    NSIndexPath *indexPath;
    CGRect tableFrame = self.tableView.frame;
    if (keyboardIsShown) {
        tableFrame.size.height -= 110;
        indexPath = [NSIndexPath indexPathForRow:textField.tag inSection:0];
    } else {
        tableFrame.size.height += 110;
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [tableView setFrame:tableFrame];
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];

}


#pragma mark textView methods


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // the user pressed the "Done" button, so dismiss the keyboard
    [textField resignFirstResponder];

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag > 3) {
        [self scrollTable:textField :YES]; // scroll up so textfield is visible
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (textField.tag > 3) {
        [self scrollTable:textField :NO]; // scroll down to original position
    }
    
    switch (textField.tag)
    
    {
        case 0:
            _selectedPerson.firstName = [self getNamePart:textField.text :@"first"];
            _selectedPerson.lastName = [self getNamePart:textField.text :@"last"];
            break;
            
        case 1:
            _selectedPerson.title = textField.text;
            
            break;
            
        case 2:
            _selectedPerson.company = textField.text;
            
            break;
            
        case 4:
            _selectedPerson.phone = textField.text;
            
            break;
            
        case 5:
            _selectedPerson.email = textField.text;
            
            break;
            
        default:
            
            break;
            
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
