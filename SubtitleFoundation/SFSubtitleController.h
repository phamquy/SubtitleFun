//
//  SFSubtitleController.h
//  SubPlayerTest
//
//  Created by Jack on 1/14/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "SFMovieSubtitle.h"
@protocol SFSubtitleClock <NSObject>
@required
/**
 return current play time
 */
- (NSTimeInterval) currentPlayTime;
@end


//------------------------------------------------------------------------------
@interface SFSubtitleController : NSObject
@property(nonatomic, weak) id<SFSubtitleClock> clock;
@property(nonatomic, strong) SFMovieSubtitle* subtitle;
@property(nonatomic, strong) UIView* outputView;
@property(nonatomic, weak) UIView* outputViewContainer;
@property(nonatomic, weak) MPMoviePlayerController* mediaPlayer;
@property(nonatomic) BOOL showSubtitle;

//- (id) initWithViewer: (UIView*) viewer;
- (id) initWithContentURL: (NSURL*) url
               asLanguage: (NSString*) languageCode
                    clock: (id<SFSubtitleClock>) clock;

- (id) initWithContentURL: (NSURL*) url
               asLanguage: (NSString*) languageCode;


- (id) initWithContentURL: (NSURL*) url;
@end

//------------------------------------------------------------------------------
/*!
 Methods to handle subtitle data such as add, remove tracks 
 */
@interface SFSubtitleController (SubtitleData)
- (void) addSubtitleFromContentURL: (NSURL*) url
                        asLanguage: (NSString*) languageCode;


@end
//------------------------------------------------------------------------------
@interface SFSubtitleController (SubtitleDisplay)

@end

//------------------------------------------------------------------------------
@interface SFSubtitleController (SubtitlePlayback)

@end