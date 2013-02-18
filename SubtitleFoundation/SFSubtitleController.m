//
//  SFSubtitleController.m
//  SubPlayerTest
//
//  Created by Jack on 1/14/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "SFSubtitleController.h"
#import "MPSubMoviePlayerController.h"
#import "SFSubtitleView.h"
#import "SFMovieSubtitle.h"
#import "SFFrameData.h"

#define kSFSubtitleDefaultLanguage @"en"
#define kSFSubtitleDefaultRefreshRate 0.5f
//==============================================================================
@interface SFSubtitleController ()
{
    __weak id<SFSubtitleClock> _clock;
    SFMovieSubtitle* _subtitle;
    SFSubtitleView* _outputView;
    __weak UIView* _outputViewContainer;
    //__weak MPMoviePlayerController* _mediaPlayer;
    BOOL _showSubtitle;
    NSTimer* _refreshTimer;
    NSTimeInterval _outputRefreshInterval;
    
    BOOL _isActivated;
}
@end

//==============================================================================
#pragma mark - SFSubtitleController
@implementation SFSubtitleController
@synthesize clock=_clock;
@synthesize subtitle=_subtitle;
@synthesize outputView=_outputView;
@synthesize outputRefreshInterval=_outputRefreshInterval;

//------------------------------------------------------------------------------
- (id) initWithContentURL: (NSURL*) url
{
    self = [self initWithContentURL:url
                         asLanguage:kSFSubtitleDefaultLanguage
                              clock:nil];
    if (self){
        
    }
    return self;
}

//------------------------------------------------------------------------------
- (id) initWithContentURL: (NSURL*) url
               asLanguage: (NSString*) languageCode
{
    self = [self initWithContentURL:url
                         asLanguage:languageCode
                              clock:nil];
    if (self){

    }
    return self;
}

//------------------------------------------------------------------------------
- (id) initWithContentURL: (NSURL*) url
               asLanguage: (NSString*) languageCode
                    clock: (id<SFSubtitleClock>) clock
{
    self = [super init];
    if (self) {
        [self addSubtitleFromContentURL:url asLanguage:languageCode];
        _clock = clock;
        [self initOutputView];
        _outputRefreshInterval = kSFSubtitleDefaultRefreshRate;
        
        _refreshTimer =[NSTimer
                        timerWithTimeInterval:_outputRefreshInterval
                        target:self
                        selector:@selector(refreshOutputByTimer:)
                        userInfo:nil
                        repeats:YES];
        
        NSRunLoop* runloop = [NSRunLoop currentRunLoop];
        [runloop addTimer:_refreshTimer
                  forMode:NSDefaultRunLoopMode];

    }
    return self;
}

//------------------------------------------------------------------------------
- (void) dealloc
{
    // remove subtitle layer from container
    [_outputView removeFromSuperview];
    [_refreshTimer invalidate];
}

//==============================================================================
#pragma mark - Refresh subtitle output
- (void) activateRefreshTimer
{
    _isActivated = YES;
}

//------------------------------------------------------------------------------
- (void) deactivateRefreshTimer
{
    
    _isActivated = NO;
}

//------------------------------------------------------------------------------
- (void) refreshOutputByTimer: (NSTimer* ) timer
{
    if ((timer == _refreshTimer) && _isActivated) {
        
        NSTimeInterval playTimeStamp = [_clock currentPlayTime];        
        [self renderSubtitleAtPlayTime:playTimeStamp];

    }
}

//==============================================================================
#pragma mark - SFSubtitleController (SubtitleData)


- (void) addSubtitleFromContentURL: (NSURL*) url
                        asLanguage: (NSString*) languageCode
{
    if (!_subtitle) { // If there first time, create subtitle obj
        _subtitle = [[SFMovieSubtitle alloc] initWithContentURL:url
                                                   languageHint:languageCode];
        
        // Set first track as active track.
        if ([_subtitle trackCount]) {
            [_subtitle setActiveTrackAtIndex:0];
        }
        
    }else{ // else, add subtitle tracks from url to current subtitle
        [_subtitle addTracksFromContentURL:url
                                    asLang:languageCode];
    }
}


//==============================================================================
#pragma mark - SFSubtitleController (SubtitleDisplay)
//@synthesize outputViewContainer=_outputViewContainer;

//------------------------------------------------------------------------------
// NOTE: atm, we make subtitle view take entire space of it container
- (void) setOutputViewContainer:(UIView *)outputViewContainer
{
    _outputViewContainer = outputViewContainer;
    if (_outputView) {
        [_outputView setFrame:[_outputViewContainer bounds]];
        [_outputViewContainer addSubview:_outputView];
    }
}

//------------------------------------------------------------------------------
- (UIView*) outputViewContainer
{
    return _outputViewContainer;
}

//------------------------------------------------------------------------------
- (void) initOutputView
{
    _outputView = [[SFSubtitleView alloc] init];
    [_outputView setFrame:CGRectMake(0, 0, 1, 1)];
    [_outputView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|
     UIViewAutoresizingFlexibleHeight];
    
    // Set _outputView appearance setting to make it transparent
    //[_outputView setBackgroundColor:[UIColor grayColor]];
    //[_outputView setAlpha:0.5f];
    [_outputView setUserInteractionEnabled:NO];
    [self setShowSubtitle:NO];
}


//==============================================================================
#pragma mark - SFSubtitleController (Subtitle Control)
- (void) stop
{
    [self deactivateRefreshTimer];
}

//------------------------------------------------------------------------------
- (void) start
{
    [self activateRefreshTimer];
}

//------------------------------------------------------------------------------
- (BOOL) isShowSubtitle
{
    return _showSubtitle;
}


//------------------------------------------------------------------------------
- (void) setShowSubtitle:(BOOL)showSubtitle
{
    _showSubtitle = showSubtitle;
    if (_showSubtitle) {
        [_outputView setHidden:NO];
    }else{
        [_outputView setHidden:YES];
    }
}

//------------------------------------------------------------------------------
- (void) renderSubtitleAtPlayTime: (NSTimeInterval) playTime
{
    if (_showSubtitle) {
        SFFrameData* renderData = [_subtitle
                                   renderDataOfFrameAtTime: playTime];
        
        [_outputView renderSubtitle:renderData];
    }
}

@end



