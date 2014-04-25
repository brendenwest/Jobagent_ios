//
//  Task.h
//  jobagent
//
//  Created by mac on 3/22/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Task :  NSManagedObject  
{
}

@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSDate * start;
@property (nonatomic, strong) NSDate * end;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSNumber * status;
@property (nonatomic, strong) NSNumber * priority;


@end