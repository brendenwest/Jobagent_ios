//
//  Event.h
//  jobagent
//
//  Created by mac on 3/25/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Company;
@class Job;
@class Person;

@interface Event :  NSManagedObject  
{
}

@property (nonatomic, strong) NSString * person;
@property (nonatomic, strong) NSString * jobtitle;
@property (nonatomic, strong) NSString * jobid;
@property (nonatomic, strong) NSDate * date;
@property (nonatomic, strong) NSString * action;
@property (nonatomic, strong) NSString * company;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) Person * toPerson;
@property (nonatomic, strong) Job * toJob;
@property (nonatomic, strong) Company * toCompany;

@end



