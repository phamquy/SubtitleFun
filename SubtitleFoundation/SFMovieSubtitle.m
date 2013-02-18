//
//  SFMovieSubtitle.m
//  SubPlayerTest
//
//  Created by Jack on 1/2/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "SFMovieSubtitle.h"
#import "SFSubtitleParseService.h"
#import "SFSubtitleTrack.h"
@interface SFMovieSubtitle ()
{
    NSMutableArray* _subtitleTracks;
    __weak SFSubtitleTrack* _activeTrack;
}
@end

//------------------------------------------------------------------------------
@implementation SFMovieSubtitle
@synthesize subtitleTracks=_subtitleTracks;
@synthesize activeTrack=_activeTrack;

- (id) initWithTracks:(NSArray *)tracks
{
    self = [super init];
    if (self) {
        _subtitleTracks = [NSMutableArray arrayWithArray:tracks];
    }
    return self;
}
//------------------------------------------------------------------------------
- (id) initWithContentURL: (NSURL*) url
             languageHint: (NSString*) langCode
{
    self = [super init];
    if (self) {
        _subtitleTracks =
            [NSMutableArray arrayWithArray:[SFSubtitleParserService
                                            subtitleTracksFromContentURL:url
                                            languageHint:langCode]];
        if (!_subtitleTracks) {
            return nil;
        }
    }
    return self;
}

//------------------------------------------------------------------------------
- (NSString*) description
{
    NSMutableString* description = [[NSMutableString alloc] init];
    [description appendFormat:@"SFMovieSubtitle: { number of track: %d,\n",
                                                    [_subtitleTracks count]];
    for (SFSubtitleTrack* track in _subtitleTracks)
    {
        [description appendString: [track description]];
    }
    [description appendString:@"}"];
    
    return description;
}

//------------------------------------------------------------------------------
- (NSArray*) subtitleTracks
{
    return _subtitleTracks;
}

//------------------------------------------------------------------------------

#pragma mark Render Data Creation
- (SFFrameData*) renderDataOfFrameAtTime: (NSTimeInterval) timeStamp
{
    SFSubtitleFrame* subFrame = nil;
    if (_activeTrack) {
        subFrame = [_activeTrack subtitleFrameForTimestamp: timeStamp];
    }
    
    if (subFrame) {
        return  subFrame.data;
    }
    return nil;
}


//------------------------------------------------------------------------------
#pragma mark Subtitle Tracks manipulation

- (void) setActiveTrackAtIndex: (NSInteger) index
{
    if (index < [_subtitleTracks count]) {
        _activeTrack = [_subtitleTracks objectAtIndex:index];        
    }
}

//------------------------------------------------------------------------------
- (NSInteger) trackCount
{
    return [_subtitleTracks count];
}

//------------------------------------------------------------------------------
- (void) addTracksFromContentURL: (NSURL*) url
                          asLang: (NSString*) languageCode
{
    
}

//------------------------------------------------------------------------------
- (NSArray*) trackForLanguage:(NSString *)ISOLanguageCode
{
    // TODO: implementation
    return nil;
}
//------------------------------------------------------------------------------
- (void) addTrack: (SFSubtitleTrack*) tracks
{
    // TODO: implementation
}
//------------------------------------------------------------------------------
- (void) addTracksFromContentURL: (NSURL*) url
{
    // TODO: implementation
}
//------------------------------------------------------------------------------
- (void) removeTrack: (SFSubtitleTrack*) tracks
{
    // TODO: implementation
}
//------------------------------------------------------------------------------
- (void) removeTracksOfLanguage: (NSString*) ISOLanguageCode
{
    // TODO: implementation
}
//------------------------------------------------------------------------------
- (void) appendTracksFromSubtitle: (SFMovieSubtitle*) subtitle
{
    // TODO: implementation
}
//------------------------------------------------------------------------------
@end
