//
//  SFSubtitleFrame.h
//  SubPlayerTest
//
//  Created by Jack on 12/24/12.
//  Copyright (c) 2012 Clunet. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SFFrameData;
@interface SFSubtitleFrame : NSObject

@property (nonatomic) NSInteger seqId;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;
@property (nonatomic, strong) SFFrameData* data;

- (id) initWithSeqId: (NSInteger) seqId
           StartTime: (NSTimeInterval) start
             endTime: (NSTimeInterval) endTime
                data: (SFFrameData*) data;

@end
