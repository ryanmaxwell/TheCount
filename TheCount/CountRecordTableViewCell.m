//
//  CountRecordTableViewCell.m
//  TheCount
//
//  Created by Ryan Maxwell on 11/06/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import "CountRecordTableViewCell.h"

@implementation CountRecordTableViewCell
@synthesize dateLabel = _dateLabel, valueLabel = _valueLabel, totalLabel = _totalLabel;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
