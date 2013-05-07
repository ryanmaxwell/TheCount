//
//  FlipDigitView.h
//  TheCount
//
//  Created by Ryan Maxwell on 28/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FlipDigitViewDelegate;

@interface FlipDigitView : UIView
@property (nonatomic, weak) id<FlipDigitViewDelegate> delegate;

@property (nonatomic, strong) IBOutlet UIView *view;
@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIView *frontTopDigitView;
@property (nonatomic, strong) IBOutlet UIView *frontBottomDigitView;
@property (nonatomic, strong) IBOutlet UILabel *frontTopValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *frontBottomValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *backTopValueLabel;
@property (nonatomic, strong) IBOutlet UILabel *backBottomValueLabel;

- (void)changeToCharacterString:(NSString *)string;
@end

@protocol FlipDigitViewDelegate <NSObject>
@required
- (void)flipDigitViewFinishedUpdating;
@end
