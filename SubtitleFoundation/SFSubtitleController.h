//
//  SFSubtitleController.h
//  SubPlayerTest
//
//  Created by Jack on 1/14/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class SFMovieSubtitle;
@class SFSubtitleView;
@protocol SFSubtitleClock <NSObject>
@required
/**
 return current play time
 */
- (NSTimeInterval) currentPlayTime;
@end

#pragma mark -
//------------------------------------------------------------------------------
@interface SFSubtitleController : NSObject
@property(nonatomic, weak) id<SFSubtitleClock> clock;
@property(nonatomic, strong) SFMovieSubtitle* subtitle;
@property(nonatomic, readonly) SFSubtitleView* outputView;
@property(nonatomic, weak) UIView* outputViewContainer;
@property(nonatomic) BOOL showSubtitle;
@property(nonatomic) NSTimeInterval outputRefreshInterval;

#pragma mark Subtitle Init Methods
- (id) initWithContentURL: (NSURL*) url
               asLanguage: (NSString*) languageCode
                    clock: (id<SFSubtitleClock>) clock;

- (id) initWithContentURL: (NSURL*) url
               asLanguage: (NSString*) languageCode;


- (id) initWithContentURL: (NSURL*) url;

#pragma mark Subtitle Data Methods
- (void) addSubtitleFromContentURL: (NSURL*) url
                        asLanguage: (NSString*) languageCode;



#pragma mark Subtitle Control
- (BOOL) isActive;
- (void) stop;
- (void) start;
- (void) renderSubtitleAtPlayTime: (NSTimeInterval) playTime;

@end