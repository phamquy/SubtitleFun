//
//  SFMovieSubtitle.h
//  SubPlayerTest
//
//  Created by Jack on 1/2/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFSubtitleTrack;
@class SFFrameData;
//------------------------------------------------------------------------------
/**
 Protocol an object need to comform to display 'SFMoviesSubtitle'.
 */
@protocol SFSubtitleDisplayProtocol <NSObject>

@end

//------------------------------------------------------------------------------
@interface SFMovieSubtitle : NSObject
@property(nonatomic, readonly) NSArray* subtitleTracks;
@property(nonatomic, readonly) SFSubtitleTrack* activeTrack;

- (id) initWithTracks: (NSArray*) tracks;
- (id) initWithContentURL: (NSURL*) url languageHint: (NSString*) langCode;


- (void) setActiveTrackAtIndex: (NSInteger) index;
- (NSInteger) trackCount;
- (SFFrameData*) renderDataOfFrameAtTime: (NSTimeInterval) timeStamp;


/**
 @description return an array of `SFSubtitleTrack` contain subtitle of language
 indicated by language code
 
 @param ISOLanguageCode languageCode
 @return array of `SFSubtitleTrack`
 */

- (NSArray*) trackForLanguage: (NSString*) ISOLanguageCode;
- (void) addTrack: (SFSubtitleTrack*) tracks;
- (void) addTracksFromContentURL: (NSURL*) url;
- (void) addTracksFromContentURL: (NSURL*) url asLang: (NSString*) languageCode;
- (void) removeTrack: (SFSubtitleTrack*) tracks;
- (void) removeTracksOfLanguage: (NSString*) ISOLanguageCode;
- (void) appendTracksFromSubtitle: (SFMovieSubtitle*) subtitle;



@end
//------------------------------------------------------------------------------