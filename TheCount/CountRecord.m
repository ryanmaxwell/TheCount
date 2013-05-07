//
//  CountRecord.m
//  TheCount
//
//  Created by Ryan Maxwell on 8/05/11.
//  Copyright (c) 2011 Cactuslab. All rights reserved.
//

#import "CountRecord.h"
#import "Counter.h"


@implementation CountRecord
@dynamic creationDate;
@dynamic counter;
@dynamic value;
@dynamic cumulativeTotal;

// Just the day, set to 00:00
- (NSDate *)creationDay {
    NSUInteger flags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:flags fromDate:self.creationDate];
    return [calendar dateFromComponents:components];
}

@end
