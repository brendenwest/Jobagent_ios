//
//  Person2.h
//  jobagent
//
//  Created by mac on 3/22/10.
//  Copyright 2014 Brisk Software LLC. All rights reserved.
//

#import <CoreData/CoreData.h>


@interface Person :  NSManagedObject  
{
}

@property (nonatomic, strong) NSString * firstName;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * company;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSNumber * distance;
@property (nonatomic, strong) NSString * link;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * email;

@end



