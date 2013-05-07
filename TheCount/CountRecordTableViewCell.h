//
//  CountRecordTableViewCell.h
//  TheCount
//
//  Created by Ryan Maxwell on 11/06/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CountRecordTableViewCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;
@property (nonatomic, weak) IBOutlet UILabel *totalLabel;

@end
