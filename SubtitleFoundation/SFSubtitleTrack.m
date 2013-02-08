//
//  SFSubtitleTrack.m
//  SubPlayerTest
//
//  Created by Jack on 12/24/12.
//  Copyright (c) 2012 Clunet. All rights reserved.
//

#import "SFSubtitleTrack.h"

@interface SFSubtitleTrack ()
{
    NSMutableArray* _subtitleFrames;
    NSMutableDictionary* _trackInfo;
}
@end

@implementation SFSubtitleTrack
@synthesize subtitleFrames=_subtitleFrames;
@synthesize startOffset=_startOffset;
@synthesize trackInfo=_trackInfo;

//------------------------------------------------------------------------------
- (id) initWithFrames: (NSArray*) subtitleFrames
             language: (NSString*) language
            startTime: (NSTimeInterval) offset
{
    self = [super init];
    if (self) {
        _subtitleFrames = [NSMutableArray arrayWithArray:subtitleFrames];
        _trackInfo = [[NSMutableDictionary alloc] init];
        [self setLanguageCode:language];
        _startOffset = offset;
    }
    return self;
}

//------------------------------------------------------------------------------
- (id) initWithFrames: (NSArray*) subtitleFrames
             language: (NSString*) language
{
    return [self initWithFrames:subtitleFrames
                       language:language
                      startTime:0];
}

//------------------------------------------------------------------------------
- (id) initWithFrames: (NSArray*) subtitleFrames
{
    return [self initWithFrames:subtitleFrames
                       language:nil
                      startTime:0];
}


- (NSString*) description
{
    return [NSString stringWithFormat:@"SFSubtitleTrack:{trackInfo: %@}", _trackInfo];
}
//------------------------------------------------------------------------------
- (void) setLanguageCode:(NSString *)languageCode
{
    [_trackInfo setValue:languageCode forKey:SFTrackInfoLanguage];
}

//------------------------------------------------------------------------------
-(NSString*)languageCode
{
    return [_trackInfo valueForKey:SFTrackInfoLanguage];
}
//------------------------------------------------------------------------------
#pragma mark Frame Accessing methods
- (SFSubtitleFrame*) subtitleFrameForTimestamp: (NSTimeInterval) timeStamp
{
    SFSubtitleFrame* foundFrame = nil;
    for (SFSubtitleFrame* subframe in _subtitleFrames) {
        if ((subframe.startTime <= timeStamp) && (timeStamp <= subframe.endTime)) {
            foundFrame = subframe;
            break;
        }
    }
    
    NSLog(@"Found frame: %.3f-->%.3f for time: %.2f", foundFrame.startTime, foundFrame.endTime, timeStamp);
    return foundFrame;
}


@end


