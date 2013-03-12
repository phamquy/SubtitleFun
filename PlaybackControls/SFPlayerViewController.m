//
//  SFPlayerViewController.m
//  MT2P
//
//  Created by Jack on 2/20/13.
//  Copyright (c) 2013 Jack. All rights reserved.
//

#import "SFPlayerViewController.h"
#import "MPSubMoviePlayerController.h"
#import "SFPlaybackControlView.h"
#import "SFSubtitleController.h"
#import "NSString+SFSubtitle.h"

//==============================================================================
@interface SFPlayerViewController ()
<SFControlledPlayer, UIGestureRecognizerDelegate>
{
    SFSubtitleController* _subtitleController;
    MPSubMoviePlayerController* _player;
    SFPlaybackControlView* _playControls;
    NSTimer* _updateControlTimer;
    UIView* _overlayView;
    NSURL* _movieURL;
    MPMovieScalingMode _scaleMode;
    
    NSTimeInterval _offsetBySeek;
    NSTimeInterval _lastStart;
    BOOL _needNewStart;
}
@end


//==============================================================================
#pragma mark - SFPlayerViewController

@implementation SFPlayerViewController
@synthesize player=_player;
//@synthesize subController=_subtitleController;
@synthesize playControls=_playControls;
@synthesize showControls=_showControls;
@synthesize movieURL=_movieURL;
@synthesize targetDuration=_targetDuration;

#pragma mark Initialize
//------------------------------------------------------------------------------
- (id) initWithContentURL: (NSURL*) movieUrl
{
    self = [super init];
    if (self) {
        _movieURL = movieUrl;
         _targetDuration = 10.0f;
    }
    return self;
}

- (id) initWithContentURL: (NSURL*) movieUrl
           targetDuration: (NSInteger) targetDur
{
    self = [super init];
    if (self) {
        _movieURL = movieUrl;
        _targetDuration = targetDur;
        NSLog(@"Target DurationL: %d", _targetDuration);
    }
    return self;
}
//------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//------------------------------------------------------------------------------
- (void) dealloc{
    NSLog(@"Dealloc SFPlayerViewController");
    if (_player) {
        [_player.view removeFromSuperview];
        // Remove observers
        
        _player = nil;
    }
    
    if (_playControls) {
        [_playControls removeFromSuperview];
        _playControls = nil;
    }
    
    
    if (_overlayView) {
        [_overlayView removeFromSuperview];
        _overlayView = nil;
    }
    
    if ([_subtitleController isActive]) {
        [_subtitleController stop];
    }
    _subtitleController = nil;
}
//------------------------------------------------------------------------------
#pragma mark Private Utilities
- (void) _createPlayer
{
    if (_movieURL) {
        _player = [[MPSubMoviePlayerController alloc]  initWithContentURL:_movieURL];
        
        [_player.view setFrame:[[self view] bounds]];
        [_player.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                           UIViewAutoresizingFlexibleHeight)];
        _player.shouldAutoplay = NO;
        [_player setControlStyle:(MPMovieControlStyleNone)];
        //[_player setFullscreen:YES];
        _scaleMode = MPMovieScalingModeAspectFit;
        
        [self.view addSubview:_player.view];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(durationAvailable:)
         name:MPMovieDurationAvailableNotification
         object:_player];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(loadStateDidChange:)
         name:MPMoviePlayerLoadStateDidChangeNotification
         object:_player];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(playbackDidFinish:)
         name:MPMoviePlayerPlaybackDidFinishNotification
         object:_player];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(playbackStateDidChange:)
         name:MPMoviePlayerPlaybackStateDidChangeNotification
         object:_player];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(sourceTypeAvailable:)
         name:MPMovieSourceTypeAvailableNotification
         object:_player];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(readyForDisplay:)
         name:MPMoviePlayerReadyForDisplayDidChangeNotification
         object:_player];
        
    }
}


//------------------------------------------------------------------------------
- (void) _createOverlayView
{
    // Create an overlay view ontop of player
    _overlayView = [[UIView alloc] initWithFrame:[self.view bounds]];
    [_overlayView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleHeight)];
    [_overlayView setUserInteractionEnabled:NO];
    [self.view addSubview:_overlayView];
    
}

//------------------------------------------------------------------------------
- (void) _createPlaybackControlView
{
    _playControls = [SFPlaybackControlView
                     creatPlayControlViewWithStyle: SFPlayControlStyleDefault
                     player:self];
    [_playControls setFrame:[self.view bounds]];
    [_playControls setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                       UIViewAutoresizingFlexibleHeight)];
    [self.view addSubview:_playControls];
}

//------------------------------------------------------------------------------
- (void) _showPlayControl: (BOOL) show animated: (BOOL) animated
{
    [_playControls showControls: show animated: animated];
    
}

//------------------------------------------------------------------------------
- (void) _updateSubtitleUI
{
    // TODO:
    // (1) create array of data of subtitle menu
//    NSArray* subMenuData = [[_subtitleController subtitle] ];
    // (2) set data for subtitle menu
}

//------------------------------------------------------------------------------
#pragma mark Player Notification Handler

- (void) syncControlViewProgress: (NSTimer*) timer
{
    //NSLog(@"Sync control for time: %.3f", [self currentPlayTime]);
//    if (_player.playbackState == MPMoviePlaybackStatePlaying) {
//        [_playControls
//         syncToCurrentPlaytime:[self currentPlayTime]];
//    }
    if (_player.loadState & MPMovieLoadStatePlaythroughOK) {
        [_playControls
         syncToCurrentPlaytime:[self currentPlayTime]];
    }

}

//------------------------------------------------------------------------------
- (void) durationAvailable: (NSNotification*) notification
{
    // Set duration to controlsView
    [_playControls syncToDuration:[_player duration]];
    
}
//------------------------------------------------------------------------------
- (void) loadStateDidChange: (NSNotification*) notification
{
    NSLog(@"Movie loadstate: %d", _player.loadState);
    // TODO:
    // (1) syncs controlView UI
        
    if (_player.loadState & MPMovieLoadStatePlaythroughOK) {

        if (_needNewStart) {
            [_playControls syncToLoadState:[_player loadState]];
            NSLog(@"Update need new start");
            _lastStart = [_player currentPlaybackTime];
            
            NSLog(@"New start: %.3f know as: %@", _lastStart, [NSString stringForPlaytime:_lastStart]);
            NSLog(@"Offset: %@", [NSString stringForPlaytime:_offsetBySeek]);
            NSLog(@"Currentplayback: %@", [NSString stringForPlaytime:[_player currentPlaybackTime]]);
            NSLog(@"Stream time: %@", [NSString stringForPlaytime:[self currentStreamPlaybackTime]]);
            [_playControls syncToCurrentPlaytime:_lastStart];

            _needNewStart = NO;
            [_player pause];
        }
    }
}

//------------------------------------------------------------------------------
- (void) playbackStateDidChange: (NSNotification*) notification
{
    NSLog(@"Playback state: %d", _player.playbackState);
    [_playControls syncToPlaybackState:[_player playbackState]];

    switch (_player.playbackState) {
        case MPMoviePlaybackStateSeekingForward:
        case MPMoviePlaybackStateSeekingBackward:
            NSLog(@"Need new start");
            _needNewStart = YES;
            break;
            
        case MPMoviePlaybackStatePaused:
        case MPMoviePlaybackStateStopped:
        case MPMoviePlaybackStateInterrupted:
        case MPMoviePlaybackStatePlaying:
//            NSLog(@"Update need new start");
//            if (_needNewStart) {
//                
//                _lastStart = [_player currentPlaybackTime];
//                NSLog(@"New start: %.3f", _lastStart);
//                _needNewStart = NO;
//            }
//            break;
        default:
            break;
    }
}

//------------------------------------------------------------------------------
- (void) sourceTypeAvailable: (NSNotification*) notification
{
    // TODO: config the playtime calculation for corresponding source type
}

//------------------------------------------------------------------------------
- (void) readyForDisplay: (NSNotification*) notification
{
    [_playControls syncToDisplayReady:[_player readyForDisplay]];
    

    // Create timer to update progress
    if (![_updateControlTimer isValid]) {
        _updateControlTimer = [NSTimer
                               timerWithTimeInterval:1.0f
                               target:self
                               selector:@selector(syncControlViewProgress:)
                               userInfo:nil
                               repeats:YES];
        
        NSRunLoop* runloop = [NSRunLoop currentRunLoop];
        [runloop addTimer:_updateControlTimer
                  forMode:NSDefaultRunLoopMode];
    }
    
    if (_subtitleController) {
        [_subtitleController start];
    }
}

//------------------------------------------------------------------------------
- (void) playbackDidFinish: (NSNotification*) notification
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMovieDurationAvailableNotification
     object:_player];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerLoadStateDidChangeNotification
     object:_player];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:_player];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackStateDidChangeNotification
     object:_player];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMovieSourceTypeAvailableNotification
     object:_player];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerReadyForDisplayDidChangeNotification
     object:_player];
    
    // Stop timers
    if ([_updateControlTimer isValid]) {
        [_updateControlTimer invalidate];
        _updateControlTimer = nil;
    }
    
    if (_subtitleController) {
        [_subtitleController stop];
    }
}
//------------------------------------------------------------------------------
#pragma mark Playtime tracking methods for stream
- (NSTimeInterval) currentStreamPlaybackTime
{
    //NSLog(@"Offset: %.2f, currentTime: %.2f, lastStart: %2.f", _offsetBySeek, _player.currentPlaybackTime,  _lastStart);
//    NSLog(@"Current stream playtime: %@",
//          [NSString stringForPlaytime:(_offsetBySeek + (_player.currentPlaybackTime - _lastStart))]);
    return _offsetBySeek + (_player.currentPlaybackTime - _lastStart);
}

//------------------------------------------------------------------------------
- (void) seekToStreamPosition:(NSTimeInterval) seekPos
{
    long long nSeekPos = (long long) seekPos;
    nSeekPos = (nSeekPos / _targetDuration) * _targetDuration;
    _offsetBySeek = nSeekPos;
    NSLog(@"Scrub to: %@ but will seek to pos: %@",
          [NSString stringForPlaytime:seekPos],
          [NSString stringForPlaytime:_offsetBySeek]);
    [_player setCurrentPlaybackTime:_offsetBySeek + 0.1f];
}
//------------------------------------------------------------------------------
#pragma mark UIView delegate

//- (void) loadView
//{
//    // Should not call super's method
//}

//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self _createPlayer];
    [self _createOverlayView];
    [self _createPlaybackControlView];
    
#warning Temporary Code
    _offsetBySeek = 0.0f;
    _lastStart = 0.0f;
    
    
    // Wire up gesture recoginition
    UITapGestureRecognizer* playerTouchedGesture =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(videoTapHandler)];
    playerTouchedGesture.delegate = self;
    [_playControls addGestureRecognizer:playerTouchedGesture];
}

//------------------------------------------------------------------------------
- (void) viewDidUnload
{
    // Release all ui references
    [_player.view removeFromSuperview];
    _player = nil;
    
    [_playControls removeFromSuperview];
    _playControls = nil;
    
    [_overlayView removeFromSuperview];
    _overlayView = nil;
    
    _subtitleController = nil;
}


//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//------------------------------------------------------------------------------
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if (UIInterfaceOrientationIsLandscape([self interfaceOrientation])) {
        [_playControls showSubtitleButton: YES];
    }else{
        [_playControls showSubtitleButton: NO];
    }
}

//------------------------------------------------------------------------------
#pragma mark SFControlledPlayer Protocol
- (void) playedBySender:(SFPlaybackControlView*) sender
{
    if (_player) {
        [_player play];
    }
}
//------------------------------------------------------------------------------
- (void) stoppedBySender: (SFPlaybackControlView*) sender
{
    if (_player) {
        [_player stop];
    }
}
//------------------------------------------------------------------------------
- (void) pausedBySender: (SFPlaybackControlView*) sender
{
    if (_player) {
        [_player pause];
    }
}
//------------------------------------------------------------------------------
- (void) scaledBySender: (SFPlaybackControlView*) sender
{
    if (_player) {
        _scaleMode++;
        if (_scaleMode > MPMovieScalingModeFill) {
            _scaleMode = MPMovieScalingModeNone;
        }
        [_player setScalingMode:_scaleMode];
    }
}
//------------------------------------------------------------------------------
- (void) seekTo: (double) timePos
       bySender: (SFPlaybackControlView*) sender
{
    if (_player) {        
        if (_player.movieSourceType == MPMovieSourceTypeStreaming) {
            [self seekToStreamPosition:timePos];

        }else {
            [_player setCurrentPlaybackTime:timePos];
        }        
    }
}


#pragma mark Gesture handler & delegate
//------------------------------------------------------------------------------
- (void)videoTapHandler
{
    BOOL isShown  = [_playControls isShowControls];
    if (!isShown) {
        [self _showPlayControl: YES animated: YES];
    }else{
        [self _showPlayControl: NO animated: YES];
    }
}


//------------------------------------------------------------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:_playControls.topBar] ||
        [touch.view isDescendantOfView:_playControls.bottomBar]) {
        return NO;
    }
    return YES;
}
@end

//==============================================================================
#pragma mark - SFPlayerViewController (Subtitle)
@implementation SFPlayerViewController (Subtitle) 

//------------------------------------------------------------------------------
@dynamic showSubtitle;
-(BOOL) isShowSubtitle
{
    if (_subtitleController) {
        return [_subtitleController showSubtitle];
    }
    return NO;
}

- (void) setShowSubtitle:(BOOL)showSubtitle
{
    if (_subtitleController) {
        [_subtitleController setShowSubtitle:showSubtitle];
//        if (showSubtitle) {
//            [_subtitleController start];
//        }else{
//            [_subtitleController stop];
//        }
    }
}

//------------------------------------------------------------------------------
- (void) loadSubtitleFromURL: (NSURL*) subUrl
                 asLanguage: (NSString*) langCode
{
    // Init subtitle controller
    if (!_subtitleController)
    {
        _subtitleController =
        [[SFSubtitleController alloc] initWithContentURL:subUrl
                                              asLanguage:langCode];
    }else{
        [_subtitleController addSubtitleFromContentURL:subUrl
                                       asLanguage:langCode];
    }
    
    // set overlayview as view container for subtitle's output
    if (_subtitleController && _overlayView) {
        [_subtitleController setOutputViewContainer:_overlayView];
        // Set this mediaplayer as clock source for subtitle controller
        [_subtitleController setClock:self];
    }
    
    [self _updateSubtitleUI];
}

//------------------------------------------------------------------------------
#pragma mark SFSubtitleClock protocol
- (NSTimeInterval) currentPlayTime
{
    switch (_player.movieSourceType) {

        case MPMovieSourceTypeStreaming:
            // FIXME: this is temporary code
            //NSLog(@" CUrrent stream play time: %@, player time: %@",
            //      [NSString stringForPlaytime:[self currentStreamPlaybackTime]],
            //      [NSString stringForPlaytime:[_player currentPlaybackTime]]);
            return [self currentStreamPlaybackTime];
            break;
        case MPMovieSourceTypeFile:
            return [_player currentPlaybackTime];
            break;
        case MPMovieSourceTypeUnknown:
        default:
            return 0.0f;
            break;
    }
}
@end


