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
}
@end

@implementation SFSubtitleTrack
@synthesize languageCode=_languageCode;
@synthesize subtitleFrames=_subtitleFrames;
@synthesize startOffset=_startOffset;

//------------------------------------------------------------------------------
- (id) initWithFrames: (NSArray*) subtitleFrames
             language: (NSString*) language
            startTime: (NSTimeInterval) offset
{
    self = [super init];
    if (self) {
        _subtitleFrames = [NSMutableArray arrayWithArray:subtitleFrames];
        _languageCode = language;
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
@end
