//
//  CountRecord.h
//  TheCount
//
//  Created by Ryan Maxwell on 8/05/11.
//  Copyright (c) 2011 Cactuslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Counter;

@interface CountRecord : NSManagedObject
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong, readonly) NSDate *creationDay;
@property (nonatomic, strong) NSNumber *value;
@property (nonatomic, strong) NSNumber *cumulativeTotal;
@property (nonatomic, strong) Counter *counter;

@end
