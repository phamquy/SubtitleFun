//
//  SFPlaybackControlView.m
//  SubPlayerTest
//
//  Created by Jack on 3/4/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "SFPlaybackControlView.h"
#import "NSString+SFSubtitle.h"
#import "FPPopoverController.h"


// TEST
#import "DemoTableController.h"
#import "FPDemoTableViewController.h"

#define SFControlNibFullscreen @"SFPlayControlsViewFullscreen"

@interface SFPlaybackControlView ()
{
    NSTimeInterval _presentDuration;
    IBOutlet UISlider* _progressSlider;
    IBOutlet UISlider* _volumeSlider;
    IBOutlet UILabel* _currentPlayTime;
    IBOutlet UILabel* _currentLeftTime;
    IBOutlet UIActivityIndicatorView* _loadingIndicator;
    IBOutlet UIToolbar* _topBar;
    IBOutlet UIToolbar* _bottomBar;
    IBOutlet UIBarButtonItem* _subtitleBarButton;
    BOOL _isScrubing;
    BOOL _showControls;
    FPPopoverController* _subtitlePopover;
}
- (IBAction)donePressed:(id)sender;
- (IBAction)scalePressed:(id)sender;
- (IBAction)backward30Pressed:(id)sender;
- (IBAction)forward30Pressed:(id)sender;
- (IBAction)playPressed:(id)sender;
- (IBAction)pausePressed:(id)sender;
- (IBAction)finishScrubing:(id)sender;
- (IBAction)srubberMoved:(id)sender;
- (IBAction)startSrubing:(id)sender;
- (IBAction)volumeValueChanged:(id)sender;
- (IBAction)subtitleClick:(id)sender;
@end

//==============================================================================
#pragma mark -
@implementation SFPlaybackControlView
@synthesize player=_player;
@synthesize showControls=_showControls;
@synthesize topBar=_topBar;
@synthesize bottomBar=_bottomBar;

//------------------------------------------------------------------------------
+ (id) creatPlayControlViewWithStyle: (SFPlayControlStyle) style
                            player:(id<SFControlledPlayer>) player
{
    SFPlaybackControlView* controlView = nil;
    NSArray *nibContents = [[NSBundle mainBundle]
                            loadNibNamed:SFControlNibFullscreen
                            owner:nil
                            options:nil];
    
    
    NSEnumerator *nibEnumerator = [nibContents objectEnumerator];
    NSObject* nibItem = nil;
    while ((nibItem = [nibEnumerator nextObject]) != nil) {
        if ([nibItem isKindOfClass:[SFPlaybackControlView class]]) {
            controlView = (SFPlaybackControlView *)nibItem;
            controlView.player = player;
            break; // we have a winner
        }
    }
    
    return controlView;
}
//------------------------------------------------------------------------------
- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        
    }
    return self;
}
//------------------------------------------------------------------------------
-(void)dealloc{
    NSLog(@"Dealloc SFPlaybackControlView");
}

//------------------------------------------------------------------------------
#pragma mark Utilities
- (void) showIndicator: (BOOL) show
{
    if (show) {
        [_loadingIndicator setHidden:NO];
        [_loadingIndicator startAnimating];
    }else{
        [_loadingIndicator setHidden:YES];
        [_loadingIndicator stopAnimating];
    }
}

//------------------------------------------------------------------------------
- (void) showControls: (BOOL) show animated: (BOOL) animated
{
    if (!show) {
//        [[UIApplication sharedApplication]
//         setStatusBarHidden:YES
//         withAnimation:UIStatusBarAnimationFade];
//        
        [UIView animateWithDuration:0.4 animations:^{
            _topBar.alpha = 0;
            _bottomBar.alpha = 0;
        } completion:^(BOOL finished) {
            _showControls = NO;
            [_topBar setHidden:YES];
            [_bottomBar setHidden:YES];
            
        }];
    }else{
//        [[UIApplication sharedApplication]
//         setStatusBarHidden:NO
//         withAnimation:UIStatusBarAnimationFade];
        [_topBar setHidden:NO];
        [_bottomBar setHidden:NO];
        [UIView animateWithDuration:0.4 animations:^{
            _topBar.alpha = 0.7f;
            _bottomBar.alpha = 0.7f;
        } completion:^(BOOL finished) {
        
            _showControls = YES;
        }];
    }

}

//------------------------------------------------------------------------------
#pragma mark View-Player UI sync
- (void) showSubtitleButton: (BOOL) show
{
    NSMutableArray *items = [[_bottomBar items] mutableCopy];
    if (show) {
        if (![items containsObject:_subtitleBarButton]) {
            [items addObject:_subtitleBarButton];
        }
    }else{
        if ([items containsObject:_subtitleBarButton]) {
            [items removeObject:_subtitleBarButton];
        }
    }
    [_bottomBar setItems:items animated:NO];
    [_bottomBar layoutSubviews];
}
//------------------------------------------------------------------------------
- (void) syncToDuration: (NSTimeInterval) duration
{
    NSMutableArray *items = [[_topBar items] mutableCopy];
    
    UIBarButtonItem *playTimeBtn = [[UIBarButtonItem alloc] initWithCustomView:_currentPlayTime];
    [items insertObject:playTimeBtn atIndex:1];
    
    
    UIBarButtonItem *playLeftBtn = [[UIBarButtonItem alloc] initWithCustomView:_currentLeftTime];
    [items insertObject:playLeftBtn atIndex:5];

    [_topBar setItems:items animated:NO];
    
    
    
    
    _presentDuration = duration;

    // Setup progress slider for duration
    [_progressSlider setMinimumValue:0.0f];
    [_progressSlider setMaximumValue:(float) duration];
    [_progressSlider setValue:0.0f];
    
    // Update labels
    [_currentPlayTime setText:[NSString stringForPlaytime:0.0f]];
    [_currentLeftTime setText:[NSString stringForPlaytime:duration]];
}
//------------------------------------------------------------------------------
- (void) syncToLoadState: (MPMovieLoadState) loadState
{
    switch (loadState) {
        case MPMovieLoadStateUnknown:
            break;
        case MPMovieLoadStatePlayable:
        case MPMovieLoadStatePlaythroughOK:
            //[self showIndicator:NO];
            break;
        case MPMovieLoadStateStalled:
            //[self showIndicator:YES];
            break;
        default:
            break;
    }
}
//------------------------------------------------------------------------------
/*
 enum {
 MPMoviePlaybackStateStopped,
 MPMoviePlaybackStatePlaying,
 MPMoviePlaybackStatePaused,
 MPMoviePlaybackStateInterrupted,
 MPMoviePlaybackStateSeekingForward,
 MPMoviePlaybackStateSeekingBackward
 };
 */
- (void) syncToPlaybackState: (MPMoviePlaybackState) playbackState
{
    switch (playbackState) {
        case MPMoviePlaybackStatePlaying:
            //[self showIndicator:NO];
            break;
        case MPMoviePlaybackStatePaused:
            break;
        case MPMoviePlaybackStateStopped:
            break;
        case MPMoviePlaybackStateInterrupted:
            //[self showIndicator:YES];
            break;
        case MPMoviePlaybackStateSeekingForward:
        case MPMoviePlaybackStateSeekingBackward:
            
        default:
            break;
    }
}
//------------------------------------------------------------------------------
- (void) syncToDisplayReady: (BOOL) displayReady
{
    [self showIndicator:NO];
}
//------------------------------------------------------------------------------
- (void) syncToCurrentPlaytime:(NSTimeInterval) playTime
{
    if (!_isScrubing) {
        [_currentPlayTime setText:[NSString stringForPlaytime:playTime]];
        
        [_currentLeftTime setText:[NSString
                                   stringForPlaytime:(_presentDuration-playTime)]];
        
        [_progressSlider setValue:playTime];
    }
}

//------------------------------------------------------------------------------
- (void) syncToVolume:(float) volume
{
#warning Need Implementation
}

//------------------------------------------------------------------------------
#pragma mark UI Controls' event handler
- (IBAction)donePressed:(id)sender
{
    if ([_player respondsToSelector:@selector(stoppedBySender:)]) {
        [_player stoppedBySender:self];
    }
}
//------------------------------------------------------------------------------
- (IBAction)scalePressed:(id)sender
{
    if ([_player respondsToSelector:@selector(scaledBySender:)]) {
        [_player scaledBySender:self];
    }
}
//------------------------------------------------------------------------------
- (IBAction)backward30Pressed:(id)sender
{
    float currentPos = [_progressSlider value];
    if ([_player respondsToSelector:@selector(seekTo:bySender:)]) {
        [_player seekTo:MAX(0, (currentPos - 10))
               bySender:self];
    }
    
}
//------------------------------------------------------------------------------
- (IBAction)forward30Pressed:(id)sender
{
    float currentPos = [_progressSlider value];
    if ([_player respondsToSelector:@selector(seekTo:bySender:)]) {
        [_player seekTo:MIN(_presentDuration, (currentPos + 10))
               bySender:self];
    }
}
//------------------------------------------------------------------------------
- (IBAction)playPressed:(id)sender
{
    if ([_player respondsToSelector:@selector(playedBySender:)]) {
        [_player playedBySender:self];
    }
}
//------------------------------------------------------------------------------
- (IBAction)pausePressed:(id)sender
{
    if ([_player respondsToSelector:@selector(pausedBySender:)]) {
        [_player pausedBySender:self];
    }
}
//------------------------------------------------------------------------------
- (IBAction)srubberMoved:(id)sender
{
    [_currentPlayTime setText:[NSString
                               stringForPlaytime:[_progressSlider value]]];    
}

- (IBAction)startSrubing:(id)sender
{
    _isScrubing = YES;
}

//------------------------------------------------------------------------------
- (IBAction)finishScrubing:(id)sender
{
    NSLog(@"Value changed");
//    return;
    // Should not send seek right away
    float currentPos = [_progressSlider value];
    if ([_player respondsToSelector:@selector(seekTo:bySender:)]) {
        [_player seekTo:currentPos
               bySender:self];
        _isScrubing = NO;
    }
}
//------------------------------------------------------------------------------
- (IBAction)volumeValueChanged:(id)sender
{
    
}
//------------------------------------------------------------------------------
- (IBAction)subtitleClick:(id)sender
{
    
    SAFE_ARC_RELEASE(_subtitlePopover);
    _subtitlePopover=nil;
    
    //the controller we want to present as a popover
    DemoTableController *controller = [[DemoTableController alloc] initWithStyle:UITableViewStylePlain];
    controller.delegate = self;
    _subtitlePopover = [[FPPopoverController alloc] initWithViewController:controller];
    _subtitlePopover.tint = FPPopoverDefaultTint;
    _subtitlePopover.contentSize = CGSizeMake(300, 300);
    _subtitlePopover.arrowDirection = FPPopoverArrowDirectionAny;
    [_subtitlePopover presentPopoverFromView:[sender valueForKey:@"view"]];

}
@end
