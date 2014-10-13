//
//  PickListTableViewController.h
//  jobagent
//
//  Created by Brenden West on 6/10/14.
//
//

@class AppDelegate;

@protocol PickListDelegate <NSObject>

- (void)pickItem:(NSString*)item;

@end


@interface PickList : UITableViewController {

    AppDelegate *appDelegate;
    NSArray *options;
    NSString *header;
    NSString *selectedItem;

}

@property(retain) id <PickListDelegate> delegate;

@property (nonatomic, strong) NSArray *options;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) NSString *selectedItem;

@end
