//
//  FlipDigitView.m
//  TheCount
//
//  Created by Ryan Maxwell on 28/05/11.
//  Copyright 2011 Cactuslab. All rights reserved.
//

#import "FlipDigitView.h"

#define kFlipDigitFirstAndLastFlipAnimationDuration 0.25
#define kFlipDigitContinuousFlipAnimationDuration   0.1

@interface FlipDigitView () {
    UIViewAnimationOptions flipAnimationOptions;
    NSUInteger _flipsLeft;
    NSUInteger _flipsDone;
    NSInteger _flipDirection;
    BOOL _directionChanged;
    __strong NSArray *_availableCharacterStrings;
    __strong NSNotification *_willFlipNotification;
    __strong NSNotification *_didFlipNotification;
}
- (NSString *)previousCharacterString:(NSString *)characterString;
- (NSString *)nextCharacterString:(NSString *)characterString;
@end

@implementation FlipDigitView
@synthesize delegate = _delegate;
@synthesize view = _view, containerView = _containerView;
@synthesize frontTopValueLabel = _frontTopValueLabel, frontBottomValueLabel = _frontBottomValueLabel;
@synthesize backTopValueLabel = _backTopValueLabel, backBottomValueLabel = _backBottomValueLabel;
@synthesize frontTopDigitView = _frontTopDigitView, frontBottomDigitView = _frontBottomDigitView;

- (id)init {
    self = [super init];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"FlipDigitView" owner:self options:nil];
        [self addSubview:self.view];
        _availableCharacterStrings = [NSArray arrayWithObjects:@"-", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil];
        
        _willFlipNotification = [NSNotification notificationWithName:@"FlipDigitViewWillFlip" object:self];
        _didFlipNotification = [NSNotification notificationWithName:@"FlipDigitViewDidFlip" object:self];
    }
    return self;
}

- (NSString *)previousCharacterString:(NSString *)characterString {
    NSUInteger indexOfString = [_availableCharacterStrings indexOfObject:characterString];
    NSUInteger numberOfStrings = [_availableCharacterStrings count];
    
    if (indexOfString == 0) {
        return [_availableCharacterStrings objectAtIndex:numberOfStrings-1];
    } else {
        return [_availableCharacterStrings objectAtIndex:indexOfString-1];
    }
}

- (NSString *)nextCharacterString:(NSString *)characterString {
    NSUInteger indexOfString = [_availableCharacterStrings indexOfObject:characterString];
    NSUInteger numberOfStrings = [_availableCharacterStrings count];
    
    if (indexOfString == numberOfStrings-1) {
        return [_availableCharacterStrings objectAtIndex:0];
    } else {
        return [_availableCharacterStrings objectAtIndex:indexOfString+1];
    }
}


- (void)updateValuesBeforeAnimation {
    NSString *previousString = [self previousCharacterString:self.frontTopValueLabel.text];
    NSString *nextString = [self nextCharacterString:self.frontTopValueLabel.text];
    
    if (_flipDirection == 1) {
        self.backTopValueLabel.text = nextString;
        self.frontTopValueLabel.text = nextString;
        self.frontBottomValueLabel.text = nextString;
    } else {
        self.backBottomValueLabel.text = previousString;
        self.frontTopValueLabel.text = previousString;
        self.frontBottomValueLabel.text = previousString;
    }
}

- (void)updateValuesAfterAnimation {
    if (_flipDirection == 1) {
        self.backBottomValueLabel.text = self.backTopValueLabel.text;
    } else {
        self.backTopValueLabel.text = self.backBottomValueLabel.text;
    }
}

- (void)flipCharacter {
    UIView *fromView = (_flipDirection == 1) ? self.frontTopDigitView : self.frontBottomDigitView;
    UIView *toView = (_flipDirection == 1) ? self.frontBottomDigitView : self.frontTopDigitView;
    
    if (!_directionChanged) {
        [UIView transitionWithView:self.containerView
                          duration:0.00
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                            [toView removeFromSuperview]; [self.containerView addSubview:fromView];
                        } 
                        completion:^(BOOL finished){
                            _directionChanged = YES;
                            [self flipCharacter]; // recursively calls itself
                        }];
    } else {
        UIViewAnimationOptions thisAnimationsOptions = flipAnimationOptions;
        NSTimeInterval thisAnimationTimeInterval = kFlipDigitFirstAndLastFlipAnimationDuration;
        
        if (_flipsLeft == 1) {
            if (_flipsDone == 0) {
                // single flip
                thisAnimationsOptions |= UIViewAnimationOptionCurveEaseInOut;
            } else {
                // final flip
                thisAnimationsOptions |= UIViewAnimationOptionCurveEaseOut;
            }
        } else if (_flipsLeft > 1) {
            if (_flipsDone == 0) {
                // first flip
                thisAnimationsOptions |= UIViewAnimationOptionCurveEaseIn;
            } else {
                // continuing in recursion
                thisAnimationsOptions |= UIViewAnimationOptionCurveLinear;
                thisAnimationTimeInterval = kFlipDigitContinuousFlipAnimationDuration;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotification:_willFlipNotification];
        
        [self updateValuesBeforeAnimation];
        
        [UIView transitionWithView:self.containerView
                          duration:thisAnimationTimeInterval
                           options:thisAnimationsOptions
                        animations:^{
                            [fromView removeFromSuperview]; [self.containerView addSubview:toView];
                        } 
                        completion:^(BOOL finished){
                            _flipsLeft--;
                            _flipsDone++;
                            [[NSNotificationCenter defaultCenter] postNotification:_didFlipNotification];
                            [self updateValuesAfterAnimation];
                            
                            if (_flipsLeft > 0) {
                                _directionChanged = NO;
                                [self flipCharacter]; // recursively calls itself
                            } else {
                                [self.delegate flipDigitViewFinishedUpdating];
                            }
                        }];
    }
}


- (void)changeToCharacterString:(NSString *)newValueString {
    
    NSString *oldValueString = self.frontTopValueLabel.text;
    
    if ([oldValueString isEqualToString:newValueString]) {
        [self.delegate flipDigitViewFinishedUpdating];
    } else {
        NSUInteger numberOfStrings = [_availableCharacterStrings count];
        
        NSUInteger oldValueIndex = [_availableCharacterStrings indexOfObject:oldValueString];
        NSUInteger newValueIndex = [_availableCharacterStrings indexOfObject:newValueString];
        
        NSInteger lowerValue = oldValueIndex < newValueIndex ? oldValueIndex : newValueIndex;
        NSInteger upperValue = oldValueIndex > newValueIndex ? oldValueIndex : newValueIndex;
        
        NSUInteger innerDifference = upperValue - lowerValue;
        NSUInteger outerDifference = (numberOfStrings - upperValue) + lowerValue;
        
        BOOL isInnerSmaller = innerDifference < outerDifference ? YES : NO;
        
//        NSLog(@"Inner difference: %d, Outer: %d", innerDifference, outerDifference);
        
        NSInteger newFlipDirection;
        
        if (oldValueIndex < newValueIndex) {
            if (isInnerSmaller) {
                newFlipDirection = 1;
                _flipsLeft = innerDifference;
                flipAnimationOptions = UIViewAnimationOptionTransitionFlipFromBottom;
            } else {
                newFlipDirection = -1;
                _flipsLeft = outerDifference;
                flipAnimationOptions = UIViewAnimationOptionTransitionFlipFromTop;
            }
        } else {
            if (isInnerSmaller) {
                newFlipDirection = -1;
                _flipsLeft = innerDifference;
                flipAnimationOptions = UIViewAnimationOptionTransitionFlipFromTop;
            } else {
                newFlipDirection = 1;
                _flipsLeft = outerDifference;
                flipAnimationOptions = UIViewAnimationOptionTransitionFlipFromBottom;
            }
        }
        
        _directionChanged = (newFlipDirection == _flipDirection) ? NO : YES;
        _flipDirection = newFlipDirection;
        
        _flipsDone = 0;
        
        [self flipCharacter];
    }
}


@end
