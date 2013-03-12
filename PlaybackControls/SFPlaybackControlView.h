//
//  SFPlaybackControlView.h
//  SubPlayerTest
//
//  Created by Jack on 3/4/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

enum {
    SFPlayControlStyleNone,
    SFPlayControlStyleEmbbeded,
    SFPlayControlStyleFullscreen,
    SFPlayControlStyleDefault = SFPlayControlStyleFullscreen
};
typedef NSInteger SFPlayControlStyle;

@class SFPlaybackControlView;
//==============================================================================
@protocol SFControlledPlayer <NSObject>

- (void) playedBySender:(SFPlaybackControlView*) sender;
- (void) stoppedBySender: (SFPlaybackControlView*) sender;
- (void) pausedBySender: (SFPlaybackControlView*) sender;
- (void) scaledBySender: (SFPlaybackControlView*) sender;
- (void) seekTo: (double) timePos
       bySender: (SFPlaybackControlView*) sender;

@optional
- (void) playNext: (SFPlaybackControlView*) sender;
- (void) setVolume: (float) level //0.0 --> 1.0
          bySender: (SFPlaybackControlView*) sender;

@end

//==============================================================================
#pragma mark -
@interface SFPlaybackControlView : UIView
+ (id) creatPlayControlViewWithStyle: (SFPlayControlStyle) style
                              player: (id<SFControlledPlayer>) player;

@property (nonatomic, weak) id<SFControlledPlayer> player;
@property (nonatomic, getter = isShowControls) BOOL showControls;
@property (nonatomic) UIToolbar* topBar;
@property (nonatomic) UIToolbar* bottomBar;

- (void) showControls: (BOOL) show animated: (BOOL) animated;
- (void) showSubtitleButton: (BOOL) show;

- (void) syncToDuration: (NSTimeInterval) duration;
- (void) syncToLoadState: (MPMovieLoadState) loadState;
- (void) syncToPlaybackState: (MPMoviePlaybackState) playbackState;
- (void) syncToDisplayReady: (BOOL) displayReady;
- (void) syncToCurrentPlaytime:(NSTimeInterval) playTime;
- (void) syncToVolume:(float) volume;
@end
