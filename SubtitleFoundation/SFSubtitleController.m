//
//  SFSubtitleController.m
//  SubPlayerTest
//
//  Created by Jack on 1/14/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "SFSubtitleController.h"

#define kSFSubtitleDefaultLanguage @"en"
//==============================================================================
@interface SFSubtitleController ()
{
    __weak id<SFSubtitleClock> _clock;
    SFMovieSubtitle* _subtitle;
    UIView* _outputView;
    __weak UIView* _outputViewContainer;
    __weak MPMoviePlayerController* _mediaPlayer;
    BOOL _showSubtitle;
    NSTimer* _refreshTimer;
}
@end

//==============================================================================
#pragma mark - SFSubtitleController
@implementation SFSubtitleController
@synthesize clock=_clock;
@synthesize subtitle=_subtitle;
@synthesize outputView=_outputView;
@synthesize outputViewContainer=_outputViewContainer;
@synthesize showSubtitle=_showSubtitle;

//------------------------------------------------------------------------------
-(MPMoviePlayerController*) mediaPlayer
{
    return _mediaPlayer;
}
//------------------------------------------------------------------------------
-(void) setMediaPlayer:(MPMoviePlayerController *)mediaPlayer
{
    _mediaPlayer = mediaPlayer;
    // TODO: add it self as a observer of media notification.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlaybackDidChangeState:)
                                                 name:MPMoviePlayerPlaybackStateDidChangeNotification
                                               object:mediaPlayer];
}

//------------------------------------------------------------------------------
- (id) initWithContentURL: (NSURL*) url
{
    self = [self initWithContentURL:url
                         asLanguage:kSFSubtitleDefaultLanguage
                              clock:nil];
    if (self)
    {
        
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
    if (self)
    {

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
    }
    return self;
}

//------------------------------------------------------------------------------
- (void) dealloc
{
    // ???: will __week ivar cause any problem here?
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackStateDidChangeNotification
     object:_mediaPlayer];
}

//------------------------------------------------------------------------------
- (void) moviePlaybackDidChangeState:(NSNotification*)notification
{
    MPMoviePlaybackState playbackState = [_mediaPlayer playbackState];
    switch (playbackState) {
        case MPMoviePlaybackStateStopped:
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateInterrupted:
        
            // TODO: deactive refresh timer
            [self deactivateRefreshTimer];
            break;
        case MPMoviePlaybackStatePlaying:
            // TODO: reactive timer if it is not
            [self activateRefreshTimer];
            break;
        case MPMoviePlaybackStateSeekingBackward:
        case MPMoviePlaybackStateSeekingForward:
            // ???: Probably subtitle need to make appear instantly
            // during seeking
            // TODO: Need to check real meaning of this state
            break;
        default:
            break;
    }
}

//------------------------------------------------------------------------------
- (void) activateRefreshTimer
{
    
}

//------------------------------------------------------------------------------
- (void) deactivateRefreshTimer
{
    
}
@end

//==============================================================================
#pragma mark - SFSubtitleController (SubtitleData)
@implementation SFSubtitleController (SubtitleData)


//------------------------------------------------------------------------------
- (void) addSubtitleFromContentURL: (NSURL*) url
                        asLanguage: (NSString*) languageCode
{
    if (!_subtitle) { // If there first time, create subtitle obj
        _subtitle = [[SFMovieSubtitle alloc] initWithContentURL:url
                                                   languageHint:languageCode];
    }else{ // else, add subtitle tracks from url to current subtitle
        [_subtitle addTracksFromContentURL:url
                                    asLang:languageCode];
    }
}

@end

//==============================================================================
#pragma mark - SFSubtitleController (SubtitleDisplay)
@implementation SFSubtitleController (SubtitleDisplay)



@end
