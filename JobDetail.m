//
//  JobDetail.m
//  jobagent
//
//  Created by mac on 3/9/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import "JobDetail.h"
#import "Job.h"
#import "Company.h"
#import "AppDelegate.h"
#import "Common.h"


#define kPickerAnimationDuration    0.40   // duration for the animation to slide the date picker into view
#define kDatePickerTag              99     // view tag identifiying the date picker view

#define kDateKey        @"date"    // key for obtaining the data source item's date value

static NSString *kDateCellID = @"date";     // the cells with the start or end date
static NSString *kDatePickerID = @"datePicker"; // the cell containing the date picker


@implementation JobDetail

@synthesize  jobLabels, jobKeys, jobTypes, jobActions, appDelegate, tableView, aJob, editedItemId;
@synthesize datePickerIndexPath, pickerCellRowHeight, doneButton;
@synthesize managedObjectContext;
@synthesize webVC = _webVC;
@synthesize selectedLead = _selectedLead;

BOOL isSavedJob;
#define EMBEDDED_DATE_PICKER (IS_OS_7_OR_LATER)


// Implement viewDidLoad to do additional setup after loading the view.
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
	
	tableView.dataSource = self;
    [self adjustUILayout];
    
    // Use this dictionary to display field labels and map data to Job object keys

    jobLabels = [NSArray arrayWithObjects:
                 NSLocalizedString(@"STR_TITLE", nil),
                 NSLocalizedString(@"STR_COMPANY", nil),
                 NSLocalizedString(@"STR_LOCATION", nil),
                 NSLocalizedString(@"STR_DATE", nil),
                 NSLocalizedString(@"STR_TYPE", nil),
                 NSLocalizedString(@"STR_CONTACT", nil),
                 NSLocalizedString(@"STR_NOTES", nil),
                 NSLocalizedString(@"STR_PAY", nil),
                 NSLocalizedString(@"STR_LINK", nil), nil];

    jobKeys = [NSArray arrayWithObjects:
               @"title",
               @"company",
               @"location",
               @"date",
               @"type",
               @"contact",
               @"notes",
               @"pay",
               @"link", nil];
    
    jobTypes = [NSArray arrayWithObjects:
                NSLocalizedString(@"STR_JOB_TYPE_FT", nil),
                NSLocalizedString(@"STR_JOB_TYPE_PT", nil),
                NSLocalizedString(@"STR_JOB_TYPE_CON", nil),
                NSLocalizedString(@"STR_JOB_TYPE_C2C", nil),
                NSLocalizedString(@"STR_JOB_TYPE_INTERN", nil),
                NSLocalizedString(@"STR_JOB_TYPE_VOL", nil),
                NSLocalizedString(@"STR_OTHER", nil), nil];
	
    // Date picker setup

    
    self.pickerCellRowHeight = 210; // TODO - check if needs to be variable
    
    // listen for locale changes while in the background, so we can update the date
    // format in the table view cells    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(localeChanged:)
                                                 name:NSCurrentLocaleDidChangeNotification
                                               object:nil];
    
	// create a custom navigation bar button and set it to always say "Back"
	UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
	temporaryBarButtonItem.title = NSLocalizedString(@"STR_BTN_BACK", nil);
	self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
	
    [jobActions addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
		
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
    if (aJob == nil) { //
        aJob = [[NSMutableDictionary alloc] init];
        [aJob setValue:_selectedLead.jobid forKey:@"jobid"];
        [aJob setValue:_selectedLead.title forKey:@"title"];
        [aJob setValue:_selectedLead.company forKey:@"company"];
        [aJob setValue:_selectedLead.city forKey:@"location"];
        [aJob setValue:_selectedLead.person forKey:@"contact"];
        [aJob setValue:_selectedLead.link forKey:@"link"];
        [aJob setValue:_selectedLead.notes forKey:@"notes"];
        [aJob setValue:_selectedLead.date forKey:@"date"];
        [aJob setValue:_selectedLead.type forKey:@"type"];
        isSavedJob = YES;
    }
    
    self.pickerView = [[UIDatePicker alloc] init];
    //set the action method that will listen for changes to picker value
    [self.pickerView addTarget:self
                        action:@selector(dateAction:)
              forControlEvents:UIControlEventValueChanged];
    self.pickerView.tag = 99;
    self.pickerView.datePickerMode = UIDatePickerModeDate;

    [self.tableView reloadData];
    
    // Log pageview w/ Google Analytics
    [appDelegate trackPV:@"Job Details"];
    
}


- (NSArray *)activityViewController:(NSArray *)activityViewController itemsForActivityType:(NSString *)activityType {
    if (![activityType isEqualToString:UIActivityTypePostToTwitter]) {
        // link to Job Agent in app store
        NSString *tinyUrl2 = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",NSLocalizedString(@"URL_JOBAGENT_IOS", nil)];
        
        NSString *shortURLforJobAgent = [NSString stringWithContentsOfURL:[NSURL URLWithString:tinyUrl2]
                                                       encoding:NSASCIIStringEncoding
                                                          error:nil];
        
        return @[
                 [NSString stringWithFormat:@"<a href='%@'>%@</a> - via Job Agent app %@", [aJob valueForKey:@"link"], [aJob valueForKey:@"title"], shortURLforJobAgent ]
                 ];
    } else {
        return @[@"Default message"];
    }
}

- (void)shareJob {

    NSString *tinyUrl1 = [NSString stringWithFormat:@"http://tinyurl.com/api-create.php?url=%@",[aJob valueForKey:@"link"]];
    NSString *shortURLforJob = [NSString stringWithContentsOfURL:[NSURL URLWithString:tinyUrl1]
                                                        encoding:NSASCIIStringEncoding
                                                           error:nil];

    NSString *postText = [NSString stringWithFormat:@"%@ - %@", [aJob valueForKey:@"title"], shortURLforJob];
    NSURL *recipients = [NSURL URLWithString:@""];
    
    NSArray *activityItems;
    activityItems = @[postText, recipients];
    
    UIActivityViewController *activityController =
    [[UIActivityViewController alloc]
     initWithActivityItems:activityItems applicationActivities:nil];

    
    [activityController setValue:[NSString stringWithFormat:@"Job lead - %@",[aJob valueForKey:@"title"] ] forKey:@"subject"];

    /* use shortURL */
    
    // Removed un-needed activities
    activityController.excludedActivityTypes = [[NSArray alloc] initWithObjects:
                                        UIActivityTypeCopyToPasteboard,
                                        UIActivityTypePostToWeibo,
                                        UIActivityTypeSaveToCameraRoll,
                                        UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeMessage,
                                        UIActivityTypeAssignToContact,
                                        nil];

    [self presentViewController:activityController
                       animated:YES completion:nil];
    
    
}


- (void)saveJob:(BOOL)clickedSaveBtn {

    Job *lead = _selectedLead;
    if (clickedSaveBtn) {
        _selectedLead = [NSEntityDescription insertNewObjectForEntityForName: @"Job" inManagedObjectContext: managedObjectContext];
    }

	[_selectedLead setValue:[aJob valueForKey:@"jobid"] forKey:@"jobid"];
	[_selectedLead setValue:[aJob valueForKey:@"title"] forKey:@"title"];
	[_selectedLead setValue:[aJob valueForKey:@"company"] forKey:@"company"];
	[_selectedLead setValue:[aJob valueForKey:@"location"] forKey:@"city"];
	[_selectedLead setValue:[aJob valueForKey:@"contact"] forKey:@"person"];
	[_selectedLead setValue:[aJob valueForKey:@"link"] forKey:@"link"];
	[_selectedLead setValue:[aJob valueForKey:@"type"] forKey:@"type"];
	[_selectedLead setValue:[aJob valueForKey:@"notes"] forKey:@"notes"];
	[_selectedLead setValue:[aJob valueForKey:@"date"] forKey:@"date"];
	[_selectedLead setValue:[aJob valueForKey:@"pay"] forKey:@"pay"];

    // save Company and Contact records if user has entered values
    if ([_selectedLead.company length] > 0) {
        [appDelegate setCompany:_selectedLead.company]; // save company
    }

    if ([_selectedLead.person length] > 0) {
        [appDelegate setPerson:_selectedLead.person withCo:_selectedLead.company];	// save person to SQL
    }

    
//    @property (nonatomic, strong) NSString * state;
//    @property (nonatomic, strong) NSString * country;

    
	NSError *error = nil;
	if (![lead.managedObjectContext save:&error]) {
									  // Handle the error...
	}

    if (clickedSaveBtn) {
        UIAlertView *saveLeadAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"STR_SAVED", nil) message:nil delegate:NULL cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [saveLeadAlert show];
    }
 
}

- (void)segmentAction:(id)sender
{
    [appDelegate trackPVFull:@"Listing" :@"Action" :[NSString stringWithFormat:@"%ld",(long)[sender selectedSegmentIndex]] :@""];

    
	if ([sender selectedSegmentIndex] == 0) {
		[self saveJob:1];
	} else if ([sender selectedSegmentIndex] == 2){
		WebVC *webVC = [[WebVC alloc]
						initWithNibName:nil bundle:nil];
		webVC.requestedURL = [aJob valueForKey:@"link"];
		webVC.title = @"Job Listing";
		[self.navigationController pushViewController:webVC animated:YES];
	} else {
		[self shareJob];
	}
	
	jobActions.selectedSegmentIndex =  UISegmentedControlNoSegment;
	
}	


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self hasInlineDatePicker])
    {
        // we have a date picker, so allow for it in the number of rows in this section
        NSInteger numRows = self.jobKeys.count;
        return ++numRows;
    }
    
    return self.jobKeys.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSString *itemKey = [jobKeys objectAtIndex:indexPath.row];
    
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
        
        
        detailText = [[UILabel alloc] initWithFrame:CGRectMake(65.0, 0.0, [[UIScreen mainScreen] bounds].size.width-80, 44.0)];
        detailText.font = [UIFont systemFontOfSize:14.0];
        detailText.textAlignment = NSTextAlignmentLeft;
        detailText.textColor = [UIColor blackColor];
    } else if ([cell.contentView.subviews count] > 1) {
        // don't modify datePicker cell
        label = cell.contentView.subviews[0];
        detailText = cell.contentView.subviews[1];
    }
    
        
        // Configure cell for different content types
        if ([itemKey isEqualToString:@"date"]) {
            label.text = [jobLabels objectAtIndex:indexPath.row];
            detailText.text = ([aJob objectForKey:kDateKey] != nil) ? [Common stringFromDate:[aJob objectForKey:kDateKey]] : @"";
            if ([cell.contentView.subviews count] == 0) {
                [cell.contentView addSubview:label];
                [cell.contentView addSubview:detailText];
            }
        } else if (indexPath.row == self.datePickerIndexPath.row && [self hasInlineDatePicker]) {
            // Configure datePicker Cell
            [cell.contentView addSubview:_pickerView];
        } else {
            label.text = [jobLabels objectAtIndex:indexPath.row];
            detailText.text = [aJob objectForKey:itemKey];
            if ([cell.contentView.subviews count] == 0) {
                [cell.contentView addSubview:label];
                [cell.contentView addSubview:detailText];
            }
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

    return cell;
}



- (void)tableView:(UITableView *)tblView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    // store text ID of selected row for use when returning from child view
    editedItemId = [jobKeys objectAtIndex:indexPath.row];
    
    if ([cell.reuseIdentifier isEqualToString:kDateCellID])
    {
        if (EMBEDDED_DATE_PICKER)
            [self displayInlineDatePickerForRowAtIndexPath:indexPath];
        else
            [self displayExternalDatePickerForRowAtIndexPath:indexPath];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([cell.reuseIdentifier isEqualToString:@"type"]) {
            
            PickList *pickList = [[PickList alloc] init];
            pickList.header = NSLocalizedString(@"STR_SEL_TYPE", nil);
            pickList.options = jobTypes;
            UITableViewCell *selectedCell = [tblView cellForRowAtIndexPath:indexPath];
            UILabel *tmpDetail = selectedCell.contentView.subviews[1];
            pickList.selectedItem = tmpDetail.text;
            pickList.delegate = self;
            
            [self.navigationController pushViewController:pickList animated:YES];
            
        } else {

            EditItemVC *editItemVC = [[EditItemVC alloc] init];
            UITableViewCell *selectedCell = [tblView cellForRowAtIndexPath:indexPath];
            UILabel *tmpLabel = selectedCell.contentView.subviews[0];
            editItemVC.labelText = tmpLabel.text;
            UILabel *tmpDetail = selectedCell.contentView.subviews[1];
            editItemVC.itemText = tmpDetail.text;
            editItemVC.delegate = self;
            
            [self.navigationController pushViewController:editItemVC animated:YES];
        }
    }
	
}

- (void)adjustUILayout
{
    // now set the frame accordingly
    CGRect tableFrame = self.tableView.frame;
    CGRect btnFrame = self.jobActions.frame;
    
    if (IS_OS_7_OR_LATER) {
        tableFrame.size.height= [[UIScreen mainScreen] bounds].size.height - 115;
        if ([[UIScreen mainScreen] bounds].size.height == 480) {
            tableFrame.size.height += 30; // shim for 3.5" phones
        }
    } else {
        tableFrame.size.height= [[UIScreen mainScreen] bounds].size.height - 105;
    }
    [tableView setFrame:tableFrame];
    
    btnFrame.origin.y = [[UIScreen mainScreen] bounds].size.height - 154;
    [jobActions setFrame:btnFrame];
    
}

#pragma mark - Protocol methods

-(void)setItemText:(NSString *)editedItemText {
    
    // job labels and keys are identical, with exception of 'pubdate' key
//    NSString *itemKey = ([editedItemId isEqualToString:@"Date"]) ? @"pubdate" : [editedItemId lowercaseString];
    NSString *itemKey = [editedItemId lowercaseString];
    [aJob setValue:editedItemText forKey:itemKey];
 
}

-(void)pickItem:(NSString *)item {
    
//    NSString *itemKey = ([editedItemId isEqualToString:@"Date"]) ? @"pubdate" : [editedItemId lowercaseString];
    NSString *itemKey = [editedItemId lowercaseString];
    [aJob setValue:item forKey:itemKey];
    
}

#pragma mark - Date picker methods

/*! Responds to region format or locale changes.
 */
- (void)localeChanged:(NSNotification *)notif
{
    // the user changed the locale (region format) in Settings, so we are notified here to
    // update the date format in the table view cells
    //
    [self.tableView reloadData];
}

/*! Determines if the given indexPath has a cell below it with a UIDatePicker.
 
 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:kDatePickerTag];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}

/*! Updates the UIDatePicker's value to match with the date of the cell above it.
 */
- (void)updateDatePicker
{
    if (self.datePickerIndexPath != nil)
    {
        UITableViewCell *associatedDatePickerCell = [self.tableView cellForRowAtIndexPath:self.datePickerIndexPath];

        UIDatePicker *targetedDatePicker = (UIDatePicker *)[associatedDatePickerCell viewWithTag:kDatePickerTag];

        if (targetedDatePicker != nil)
        {
            // we found a UIDatePicker in this cell, so update it's date value
            //
            NSDate *tmpDate = ([aJob valueForKey:kDateKey] != nil) ? [aJob objectForKey:kDateKey]: [NSDate date];
            [targetedDatePicker setDate:tmpDate animated:NO];
        }

    }
}

/*! Determines if the UITableViewController has a UIDatePicker in any of its cells.
 */
- (BOOL)hasInlineDatePicker
{
    return (self.datePickerIndexPath != nil);
}

/*! Determines if the given indexPath points to a cell that contains the UIDatePicker.
 
 @param indexPath The indexPath to check if it represents a cell with the UIDatePicker.
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath
{
    return ([self hasInlineDatePicker] && self.datePickerIndexPath.row == indexPath.row);
}

/*! Determines if the given indexPath points to a cell that contains the date values.
 
 @param indexPath The indexPath to check if it represents a date cell.
 */
- (BOOL)indexPathHasDate:(NSIndexPath *)indexPath
{
    BOOL hasDate = NO;
    if ([[jobKeys objectAtIndex:indexPath.row] isEqualToString:@"date"]) {
        hasDate = YES;
    }
    return hasDate;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self indexPathHasPicker:indexPath] ? self.pickerCellRowHeight : self.tableView.rowHeight);
}

/*! Adds or removes a UIDatePicker cell below the given indexPath.
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)toggleDatePickerForSelectedIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    
    // check if 'indexPath' has an attached date picker below it
    if ([self hasPickerForIndexPath:indexPath])
    {
        // found a picker below it, so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self.tableView endUpdates];
}

/*! Reveals the date picker inline for the given indexPath, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath to reveal the UIDatePicker.
 */
- (void)displayInlineDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // display the date picker inline with the table content
    [self.tableView beginUpdates];
    BOOL before = NO;   // indicates if the date picker is below "indexPath", help us determine which row to reveal
    if ([self hasInlineDatePicker])
    {
        before = self.datePickerIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (self.datePickerIndexPath.row - 1 == indexPath.row);
    
    // remove any date picker cell if it exists
    if ([self hasInlineDatePicker])
    {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.datePickerIndexPath.row inSection:0]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.datePickerIndexPath = nil;
        self.tableView.scrollEnabled = YES;

    }
    
    if (!sameCellClicked)
    {
        // hide the old date picker and display the new one
        NSInteger rowToReveal = (before ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        
        [self toggleDatePickerForSelectedIndexPath:indexPathToReveal];
        self.datePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
        // disable table scroll while picker is visible to avoid out-of-bounds error
        self.tableView.scrollEnabled = NO;

    }
    
    // always deselect the row containing date value
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.tableView endUpdates];
    
    // inform our date picker of the current date to match the current cell
    [self updateDatePicker];
}

/*! Reveals the UIDatePicker as an external slide-in view, iOS 6.1.x and earlier, called by "didSelectRowAtIndexPath".
 
 @param indexPath The indexPath used to display the UIDatePicker.
 */
- (void)displayExternalDatePickerForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // first update the date picker's date value according to our model
    NSDate *tmpDate = ([aJob valueForKey:kDateKey] != nil) ? [aJob objectForKey:kDateKey]: [NSDate date];
    [self.pickerView setDate:tmpDate animated:YES];
    
    // the date picker might already be showing, so don't add it to our view
    if (self.pickerView.superview == nil)
    {
        CGRect startFrame = self.pickerView.frame;
        CGRect endFrame = self.pickerView.frame;
        
        // the start position is below the bottom of the visible frame
        startFrame.origin.y = self.view.frame.size.height;
        
        // the end position is slid up by the height of the view
        endFrame.origin.y = startFrame.origin.y - endFrame.size.height;
        
        self.pickerView.frame = startFrame;
        
        [self.view addSubview:self.pickerView];
        
        // animate the date picker into view
        [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.pickerView.frame = endFrame; }
                         completion:^(BOOL finished) {
                             // add the "Done" button to the nav bar
                             self.navigationItem.rightBarButtonItem = self.doneButton;
                         }];
    }
}

/*! User chose to change the date by changing the values inside the UIDatePicker.
 
 @param sender The sender for this action: UIDatePicker.
 */
- (IBAction)dateAction:(id)sender
{

    NSIndexPath *targetedCellIndexPath = nil;
    
    if ([self hasInlineDatePicker])
    {
        // inline date picker: update the cell's date "above" the date picker cell
        //
        targetedCellIndexPath = [NSIndexPath indexPathForRow:self.datePickerIndexPath.row - 1 inSection:0];
    }
    else
    {
        // external date picker: update the current "selected" cell's date
        targetedCellIndexPath = [self.tableView indexPathForSelectedRow];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellIndexPath];
    UIDatePicker *targetedDatePicker = sender;
    
    // update our data model
    [aJob setValue:targetedDatePicker.date forKey:kDateKey];
    
    // update the cell's date string
    UILabel *detailText = [cell.contentView.subviews objectAtIndex:1];
    detailText.text = [Common stringFromDate:targetedDatePicker.date];
    
}

/*! User chose to finish using the UIDatePicker by pressing the "Done" button, (used only for non-inline date picker), iOS 6.1.x or earlier
 
 @param sender The sender for this action: The "Done" UIBarButtonItem
 */
- (IBAction)doneAction:(id)sender
{
    CGRect pickerFrame = self.pickerView.frame;
    pickerFrame.origin.y = self.view.frame.size.height;
    
    // animate the date picker out of view
    [UIView animateWithDuration:kPickerAnimationDuration animations: ^{ self.pickerView.frame = pickerFrame; }
                     completion:^(BOOL finished) {
                         [self.pickerView removeFromSuperview];
                     }];
    
    // remove the "Done" button in the navigation bar
	self.navigationItem.rightBarButtonItem = nil;
    
    // deselect the current table cell
	NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark End date picker methods

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers objectAtIndex:viewControllers.count-2] == self) {
        // View is disappearing because a new view controller was pushed onto the stack
        // Navigating to item editor
    } else if ([viewControllers indexOfObject:self] == NSNotFound) {
        // View is disappearing because it was popped from the stack (exiting to Leads)
        if (self.selectedLead.title.length > 0) {
            [self saveJob:0];
        } else {
            // delete empty job lead record
            [self.selectedLead.managedObjectContext deleteObject:self.selectedLead];
        }
        aJob = nil;

    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSCurrentLocaleDidChangeNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}



@end
