//
//  Counter.m
//  TheCount
//
//  Created by Ryan Maxwell on 8/05/11.
//  Copyright (c) 2011 Cactuslab. All rights reserved.
//

#import "Counter.h"

@implementation Counter
@dynamic name;
@dynamic creationDate;
@dynamic records;
@dynamic displayIndex;
@dynamic incrementValue;

- (NSNumber *)decrementValue {
    
    NSInteger decrementInteger = -[self.incrementValue integerValue];
    return [NSNumber numberWithInteger:decrementInteger];
}

- (NSArray *)allRecordsSortedByCreationDateAscending:(BOOL)ascending {
    
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" 
                                                                         ascending:ascending];
    return [self.records sortedArrayUsingDescriptors:[NSArray arrayWithObject:dateSortDescriptor]];
}

// returns an array of arrays - an inner array for each day, and inside all the records on that day sorted
- (NSArray *)recordsInSectionsSortedByCreationDateAscending:(BOOL)ascending {
    
    NSArray *allRecordsSorted = [self allRecordsSortedByCreationDateAscending:ascending];
    
    if ([allRecordsSorted count] == 0) {
        return nil;
    }
    
    NSMutableArray *outerArray = [NSMutableArray arrayWithObject:[NSMutableArray array]];

    CountRecord *firstRecord = (CountRecord *)[allRecordsSorted objectAtIndex:0];
    NSDate *lastDay = firstRecord.creationDay;
    
    NSUInteger dayNumber = 0;
    for (CountRecord *cr in allRecordsSorted) {
        if (![cr.creationDay isEqualToDate:lastDay]) {
            // new day
            [outerArray addObject:[NSMutableArray array]];
            
            lastDay = cr.creationDay;
            dayNumber++;
        }
       [[outerArray objectAtIndex:dayNumber] addObject:cr];
    }
    
    return outerArray;
}


- (NSInteger)totalIntegerValue {
    NSInteger total = 0;
    
    for (CountRecord *cr in self.records) {
        total += [cr.value intValue];
    }
    
    return total;
}

@end
