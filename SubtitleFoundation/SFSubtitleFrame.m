//
//  SFSubtitleFrame.m
//  SubPlayerTest
//
//  Created by Jack on 12/24/12.
//  Copyright (c) 2012 Clunet. All rights reserved.
//

#import "SFSubtitleFrame.h"

@implementation SFSubtitleFrame
@synthesize startTime=_startTime;
@synthesize duration=_duration;
@synthesize text=_text;

- (id) initWithStartTime: (NSTimeInterval) start
                duration: (NSTimeInterval) duration
                    text: (NSString*) text
{
    self = [super init];
    if (self) {
        _startTime = start;
        _duration = duration;
        _text = text;
    }
    return  self;
}
@end
