//
//  Job.h
//  jobagent
//
//  Created by mac on 3/22/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Job :  NSManagedObject  
{
}

@property (nonatomic, strong) NSString * jobid;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * company;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * country;
@property (nonatomic, strong) NSString * person;
@property (nonatomic, strong) NSString * link;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * pay;

@end



