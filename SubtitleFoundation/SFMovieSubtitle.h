//
//  SFMovieSubtitle.h
//  SubPlayerTest
//
//  Created by Jack on 1/2/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFSubtitleTrack.h"

//------------------------------------------------------------------------------
/**
 Protocol an object need to comform to display 'SFMoviesSubtitle'.
 */
@protocol SFSubtitleDisplayProtocol <NSObject>

@end


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
@interface SFMovieSubtitle : NSObject
@property(nonatomic, readonly) NSArray* subtitleTracks;

- (id) initWithTracks: (NSArray*) tracks;
- (id) initWithContentURL: (NSURL*) url languageHint: (NSString*) langCode;
/**
 @description return an array of `SFSubtitleTrack` contain subtitle of language
 indicated by language code
 
 @param ISOLanguageCode languageCode
 @return array of `SFSubtitleTrack`
 */
- (NSArray*) trackForLanguage: (NSString*) ISOLanguageCode;
- (void) addTrack: (SFSubtitleTrack*) tracks;
- (void) addTracksFromContentURL: (NSURL*) url;
- (void) removeTrack: (SFSubtitleTrack*) tracks;
- (void) removeTracksOfLanguage: (NSString*) ISOLanguageCode;
- (void) appendTracksFromSubtitle: (SFMovieSubtitle*) subtitle;
@end
//------------------------------------------------------------------------------