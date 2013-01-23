//
//  MPSubMoviePlayerController.m
//  SubPlayerTest
//
//  Created by Jack on 1/8/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "MPSubMoviePlayerController.h"
//==============================================================================
@interface MPSubMoviePlayerController () 
{
    UIView* _overlayView;
    SFSubtitleController* _subtitleController;
    MPPlaybackControlsViewController* _playControls;
    
    
    // TEST
    UIView* _playControlView;
    UILabel* label;
}
- (void) toggleText: (id)sender;
@end

//==============================================================================
@implementation MPSubMoviePlayerController

- (id) initWithContentURL:(NSURL *)url
{
    self = [super initWithContentURL:url];
    if (self) {
        [self setControlStyle:(MPMovieControlStyleNone)];
        
        // TODO: Need more specific initialization for overlay view ivar
        _overlayView = [[UIView alloc] init];
        [_overlayView setFrame: CGRectMake(0,0, 1, 1) ];
        
        // Always make it cover full player screen
        [_overlayView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        // Test
        label = [[UILabel alloc] init];
        [label setText:@"here is a subtitle text in \nmultiline and i know it"];
        [label setFrame:CGRectMake(100, 0, 200, 50)];
        [label setNumberOfLines:0];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setTextColor:[UIColor whiteColor]];
        [label setTextAlignment:(NSTextAlignmentCenter)];
        [label setLineBreakMode:(NSLineBreakByWordWrapping)];
        [_overlayView addSubview:label];
        
        [self.view addSubview:_overlayView];
        
        _playControlView = [[UIView alloc] init];
        [_playControlView setFrame:CGRectMake(0, 0, 1, 1)];
        [_playControlView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        
        UIButton* button = [UIButton buttonWithType:(UIButtonTypeRoundedRect)];
        [button setFrame: CGRectMake(100, 100, 100, 30)];
        [button setTitle:@"play control" forState:(UIControlStateNormal)];
        //[button actionsForTarget:self forControlEvent:(UIControlEventTouchUpInside)];
        [button addTarget:self action:@selector(toggleText:) forControlEvents:(UIControlEventTouchUpInside)];
        [_playControlView addSubview:button];
  
        [self.view addSubview:_playControlView];
    }
    return self;
}


- (void) toggleText:(id)sender
{
     [label setText:@"textToggled \nmultiline and i know it"];
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

//- (void) setSubtitle:(SFSubtitleController *)controller{
//    _subtitleController = controller;
//}

//------------------------------------------------------------------------------
@dynamic showSubtitle;
- (BOOL) isShowSubtitle {
    if(_subtitleController){
        return [_subtitleController showSubtitle];
    }else{
        return NO;
    }
}

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
    if (_overlayView) {
        [_subtitleController setOutputViewContainer:_overlayView];
    }
    
    // Set this mediaplayer as clock source for subtitle controller
    [_subtitleController setClock:self];
    [_subtitleController setMediaPlayer:self];
}

//------------------------------------------------------------------------------
#pragma mark SFSubtitleClock Protocol
- (NSTimeInterval) currentPlayTime
{
    return [self currentPlaybackTime];
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
- (void) start{}
- (void) stop{}
- (void) pause{}
- (void) resume{}
- (void) seekDelta: (double) movement{}
- (void) seekTo: (double) position{}
@end