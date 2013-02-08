//
//  MPSubMoviePlayerController.m
//  SubPlayerTest
//
//  Created by Jack on 1/8/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

// Post when seeking position change: by user moving player head, or by command
NSString *const MPMoviePlayerSeekingPositionDidChange = @"MPMoviePlayerSeekingPositionDidChange";

#import "MPSubMoviePlayerController.h"
#import <QuartzCore/QuartzCore.h>

//==============================================================================
@interface MPSubMoviePlayerController () 
{
    UIView* _overlayView;
    SFSubtitleController* _subtitleController;
    MPPlaybackControlsViewController* _playControls;
    UIView* playControlView;
    
}
@end

//==============================================================================
@implementation MPSubMoviePlayerController

- (id) initWithContentURL:(NSURL *)url
{
    self = [super initWithContentURL:url];
    if (self) {
        [self setControlStyle:(MPMovieControlStyleFullscreen)];
        
        // TODO: Need more specific initialization for overlay view ivar
        _overlayView = [[UIView alloc] init];
        [_overlayView setFrame: CGRectMake(0,0, 1, 1) ];
        
        // Always make it cover full player screen
        [_overlayView setAutoresizingMask:
            UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];

        [_overlayView setUserInteractionEnabled:NO];
        
        [self.view addSubview:_overlayView];
    }
    return self;
}


//------------------------------------------------------------------------------
- (void) playVideo:(id)sender
{
    [self play];
    //[label setText:@"textToggled \nmultiline and i know it"];
    //[self setCurrentPlaybackTime:([self currentPlaybackTime] + 5.0f)];
}


//------------------------------------------------------------------------------
- (void) pauseVideo:(id)sender
{
    [self pause];
     //[label setText:@"textToggled \nmultiline and i know it"];
    //[self setCurrentPlaybackTime:([self currentPlaybackTime] + 5.0f)];
}

//------------------------------------------------------------------------------
- (void) dealloc
{

    // Remove notification observer for this object
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackStateDidChangeNotification
     object:self];

    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerSeekingPositionDidChange
     object:self];
}

@end

//==============================================================================
#pragma mark - Subtitle Category
@implementation MPSubMoviePlayerController(Subtitle)
//------------------------------------------------------------------------------
@dynamic subtitleController;
- (SFSubtitleController*) subtitleController{
    return _subtitleController;
}

//------------------------------------------------------------------------------
@dynamic showSubtitle;
- (BOOL) isShowSubtitle {
    if(_subtitleController){
        return [_subtitleController showSubtitle];
    }else{
        return NO;
    }
}

//------------------------------------------------------------------------------
- (void) setShowSubtitle:(BOOL)showSubtitle{
    if (_subtitleController) {
        [_subtitleController setShowSubtitle:showSubtitle];
    }
}

//------------------------------------------------------------------------------
- (void) loadSubtitleFromFile: (NSString*)subPath
                  forLanguage: (NSString*)languageCode;
{
    NSURL* subURL = [NSURL fileURLWithPath:subPath];
    // Init subtitle controller
    if (!_subtitleController)
    {
        _subtitleController =
            [[SFSubtitleController alloc] initWithContentURL:subURL
                                                  asLanguage:languageCode];
    }
    
    // set overlayview as view container for subtitle's output
    if (_subtitleController && _overlayView) {
        [_subtitleController setOutputViewContainer:_overlayView];
        // Set this mediaplayer as clock source for subtitle controller
        [_subtitleController setClock:self];
    }
    
    // Add notification handler
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(moviePlaybackDidChangeState:)
     name:MPMoviePlayerPlaybackStateDidChangeNotification
     object:self];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(seekPositionDidChange:)
     name:MPMoviePlayerSeekingPositionDidChange
     object:self];
}

//------------------------------------------------------------------------------
#pragma mark SFSubtitleClock Protocol
- (NSTimeInterval) currentPlayTime
{
    return [self currentPlaybackTime];
}


#pragma mark Notification Handler
- (void) moviePlaybackDidChangeState:(NSNotification*)notification
{
    MPMoviePlaybackState playbackState = [self playbackState];
    switch (playbackState) {
        case MPMoviePlaybackStateStopped:
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateInterrupted:
            [_subtitleController stop];
            break;
        case MPMoviePlaybackStatePlaying:
            [_subtitleController start];
            break;
        case MPMoviePlaybackStateSeekingBackward:
        case MPMoviePlaybackStateSeekingForward:
            [_subtitleController stop];
            break;
        default:
            break;
    }
    
}

//------------------------------------------------------------------------------
- (void) seekPositionDidChange: (NSNotification*) notification
{
    // Check current seek position from notification object
    NSTimeInterval playTime = 0;
    // TODO: work out playTime for current seek position
    
    // Render instantly subtitle for that position
    [_subtitleController renderSubtitleAtPlayTime:playTime];
}
@end

//==============================================================================
#pragma mark - Playback controls Category
@implementation MPSubMoviePlayerController(PlaybackControls)
//------------------------------------------------------------------------------
@dynamic playControlsViewController;
- (MPPlaybackControlsViewController*) playControlsViewController
{
    return _playControls;
}
//------------------------------------------------------------------------------
@dynamic showControls;
- (BOOL) isShowControls{
    if (_playControls) {
        return [_playControls showControls];
    }else{
        return NO;
    }

}
- (void) setShowControls:(BOOL)showControls
{
    if (_playControls) {
        [_playControls setShowControls:showControls];
    }
}

//------------------------------------------------------------------------------
// TODO: Implement protocol
#pragma mark MPPlaybackControlsDelegate
//- (void) start{}
//- (void) stop{}
//- (void) pause{}
//- (void) resume{}
//- (void) seekDelta: (double) movement{}
//- (void) seekTo: (double) position{}



@end