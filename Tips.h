//
//  Tips.h
//  jobagent
//
//  Created by mac on 2/24/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

@interface Tips : UIViewController < UITableViewDelegate, UITableViewDataSource> {
	
    AppDelegate *appDelegate;
    NSArray *allItems;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIButton *btnTips;
@property (nonatomic, weak) IBOutlet UILabel *lblAbout;


- (IBAction)shareJobAgent:(id)sender;

@end
