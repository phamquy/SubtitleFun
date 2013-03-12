//
//  SFPlayerViewController.h
//  MT2P
//
//  Created by Jack on 2/20/13.
//  Copyright (c) 2013 Jack. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
@class MPSubMoviePlayerController;
@class SFSubtitleController;
@class SFPlaybackControlView;
@protocol SFSubtitleClock;

@interface SFPlayerViewController : UIViewController
- (id) initWithContentURL: (NSURL*) movieUrl;
- (id) initWithContentURL: (NSURL*) movieUrl targetDuration: (NSInteger) targetDur;

@property(nonatomic, readonly) MPSubMoviePlayerController* player;
//@property(nonatomic, readonly) SFSubtitleController* subController;
@property(nonatomic, readonly) SFPlaybackControlView* playControls;

@property(nonatomic, strong) NSURL* movieURL;

@property(nonatomic) BOOL showControls;
@property(nonatomic) NSInteger targetDuration;
@end

//==============================================================================
#pragma mark -
@interface SFPlayerViewController (Subtitle) <SFSubtitleClock>

@property(nonatomic) BOOL showSubtitle;


- (void) loadSubtitleFromURL: (NSURL*) subUrl
                  asLanguage: (NSString*) langCode;
@end