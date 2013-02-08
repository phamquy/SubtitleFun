//
//  SFSubtitleTrack.h
//  SubPlayerTest
//
//  Created by Jack on 12/24/12.
//  Copyright (c) 2012 Clunet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFSubtitleFrame.h"

#define SFTrackInfoLanguage @"language"

@interface SFSubtitleTrack : NSObject

#pragma mark Properties
@property(nonatomic) NSString* languageCode;
@property(nonatomic, readonly) NSArray* subtitleFrames;
@property(nonatomic) NSTimeInterval startOffset;
@property(nonatomic) NSMutableDictionary* trackInfo;

#pragma mark Instance methods 
/**
 Init a subtitle track with full option
 @param subtitleFrames subtitle frames
 @param language subtitle language code
 @param offset offset add to start time of track, default 0
 
 @discussion 
 if the subtitle is nil, an empty track will be create
 if language is nil, language will be autodetect
 */
- (id) initWithFrames: (NSArray*) subtitleFrames
             language: (NSString*) language
            startTime: (NSTimeInterval) offset;

- (id) initWithFrames: (NSArray*) subtitleFrames
             language: (NSString*) language;

- (id) initWithFrames: (NSArray*) subtitleFrames;


/**
 Frames accessing methods
 */
- (SFSubtitleFrame*) subtitleFrameForTimestamp: (NSTimeInterval) timeStamp;

/**
 Frames manipulating methods
 */


/**
 Timming manipulation methods
 */


@end
