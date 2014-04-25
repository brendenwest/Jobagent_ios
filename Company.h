//
//  Company.h
//  jobagent
//
//  Created by mac on 3/25/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Event;
@class Job;
@class Person;

@interface Company :  NSManagedObject  
{
}

@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSString * coType;
@property (nonatomic, strong) NSString * coName;
@property (nonatomic, strong) NSSet* toJobs;
@property (nonatomic, strong) NSSet* toPerson;
@property (nonatomic, strong) NSSet* toEvent;

@end


@interface Company (CoreDataGeneratedAccessors)

- (void)addToJobsObject:(Job *)value;
- (void)removeToJobsObject:(Job *)value;
- (void)addToJobs:(NSSet *)value;
- (void)removeToJobs:(NSSet *)value;

- (void)addToPersonObject:(Person *)value;
- (void)removeToPersonObject:(Person *)value;
- (void)addToPerson:(NSSet *)value;
- (void)removeToPerson:(NSSet *)value;

- (void)addToEventObject:(Event *)value;
- (void)removeToEventObject:(Event *)value;
- (void)addToEvent:(NSSet *)value;
- (void)removeToEvent:(NSSet *)value;

@end

