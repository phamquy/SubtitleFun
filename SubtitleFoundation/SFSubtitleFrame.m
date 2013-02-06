//
//  SFSubtitleFrame.m
//  SubPlayerTest
//
//  Created by Jack on 12/24/12.
//  Copyright (c) 2012 Clunet. All rights reserved.
//

#import "SFSubtitleFrame.h"

@implementation SFSubtitleFrame

@synthesize seqId=_seqId,
startTime=_startTime,
endTime=_endTime,
data=_data;

- (id) initWithSeqId:(NSInteger)seqId
           StartTime:(NSTimeInterval)start
             endTime:(NSTimeInterval)endTime
                data:(SFFrameData *)data
{
    self = [super init];
    if (self) {
        // Init
    }
    return self;
}
@end