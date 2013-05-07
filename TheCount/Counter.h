//
//  Counter.h
//  TheCount
//
//  Created by Ryan Maxwell on 8/05/11.
//  Copyright (c) 2011 Cactuslab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CountRecord.h"

@interface Counter : NSManagedObject 
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSSet *records;
@property (nonatomic, strong) NSNumber *displayIndex;
@property (nonatomic, strong) NSNumber *incrementValue;
@property (nonatomic, readonly) NSNumber *decrementValue;
@property (nonatomic, readonly) NSInteger totalIntegerValue;

- (NSArray *)allRecordsSortedByCreationDateAscending:(BOOL)ascending;
- (NSArray *)recordsInSectionsSortedByCreationDateAscending:(BOOL)ascending;
@end
