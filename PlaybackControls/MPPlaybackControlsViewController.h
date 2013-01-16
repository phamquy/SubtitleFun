//
//  MPPlaybackControlsViewController.h
//  SubPlayerTest
//
//  Created by Jack on 1/14/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import <UIKit/UIKit.h>

//------------------------------------------------------------------------------
/**
 Define methods that controlled object may receive from controller
 */
@protocol MPPlaybackControlsDelegate <NSObject>
- (void) start;
- (void) stop;
- (void) pause;
- (void) resume;
- (void) seekDelta: (double) movement;
- (void) seekTo: (double) position;
@end


//------------------------------------------------------------------------------
@interface MPPlaybackControlsViewController : UIViewController
@property (nonatomic) BOOL showControls;
@property(nonatomic, weak) id<MPPlaybackControlsDelegate> controlledObject;
@property(nonatomic, weak) UIView* viewContainer;


@end
