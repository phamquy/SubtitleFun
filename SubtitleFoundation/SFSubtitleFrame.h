//
//  SFSubtitleFrame.h
//  SubPlayerTest
//
//  Created by Jack on 12/24/12.
//  Copyright (c) 2012 Clunet. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
  SFSubtitleFrameTypeSubRip,
  SFSubtitleFrameTypeSami,
    
};

typedef NSInteger SFSubtitleFrameType;

//------------------------------------------------------------------------------
@protocol SFSubtitleFrame <NSObject>

@property (nonatomic) NSInteger seqId;
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;
@property (nonatomic, strong) NSString* text;

+ (id<SFSubtitleFrame>) subtitleFrameFromString: (NSString*) subString;

@optional
@property (nonatomic, strong) NSDictionary* settings;
- (id) initWithSeqId: (NSInteger) seqId
           StartTime: (NSTimeInterval) start
             endTime: (NSTimeInterval) endTime
            settings: (NSDictionary*) settings
                text: (NSString*) text;

@end
//------------------------------------------------------------------------------
@interface SFSubtitleFrameMaker : NSObject
+ (id) makeSubtitleFrameFromeString: (NSString*) string
                           withType: (SFSubtitleFrameType) type;

@end

//------------------------------------------------------------------------------
@interface SFSubtitleSRTFrame : NSObject <SFSubtitleFrame>
- (id) initWithSubString: (NSString*) subString;
@end

@interface SFSubtitleSMIFrame : NSObject <SFSubtitleFrame>
@end