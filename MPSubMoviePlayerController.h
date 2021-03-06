//
//  MPSubMoviePlayerController.h
//  SubPlayerTest
//
//  Created by Jack on 1/8/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "SFSubtitleController.h"
#import "MPPlaybackControlsViewController.h"

@protocol MPMediaPlayback;

//------------------------------------------------------------------------------
@interface MPSubMoviePlayerController : MPMoviePlayerController

@end

//------------------------------------------------------------------------------
#pragma mark Subtitle Category
@interface MPSubMoviePlayerController(Subtitle) <SFSubtitleClock>
@property (nonatomic, readonly) SFSubtitleController* subtitleController;
@property (nonatomic) BOOL showSubtitle;
- (void) loadSubtitleFromFile: (NSString*) subPath
                   forLanguage: (NSString*) languageCode;
@end
//------------------------------------------------------------------------------
#pragma mark Playback Controls
@interface MPSubMoviePlayerController(PlaybackControls) <MPPlaybackControlsDelegate>
@property (nonatomic, readonly) MPPlaybackControlsViewController* playControlsViewController;
@property (nonatomic) BOOL showControls;
@end
