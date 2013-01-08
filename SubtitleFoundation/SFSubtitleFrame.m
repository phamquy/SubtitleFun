//
//  SFSubtitleFrame.m
//  SubPlayerTest
//
//  Created by Jack on 12/24/12.
//  Copyright (c) 2012 Clunet. All rights reserved.
//

#import "SFSubtitleFrame.h"


//==============================================================================
@implementation SFSubtitleFrameMaker

+ (id) makeSubtitleFrameFromeString:(NSString *)string
                           withType:(SFSubtitleFrameType)type
{
    id<SFSubtitleFrame> subFrame = nil;
    switch (type) {
        case SFSubtitleFrameTypeSubRip:
            subFrame = [SFSubtitleSRTFrame subtitleFrameFromString:string];
            break;
        case SFSubtitleFrameTypeSami:
            // TODO: make a Sami frame
            break;
        default:
            break;
    }
    
    return subFrame;
}

@end

//==============================================================================
@implementation SFSubtitleSRTFrame
@synthesize startTime=_startTime;
@synthesize endTime=_endTime;
@synthesize text=_text;
@synthesize seqId=_seqId;


//------------------------------------------------------------------------------
+ (id<SFSubtitleFrame>) subtitleFrameFromString:(NSString *)subString
{
    return [[SFSubtitleSRTFrame alloc] initWithSubString:subString];
}
//------------------------------------------------------------------------------
- (id) initWithSubString: (NSString*) subString
{
    self = [super init];
    if (self) {
        
        // seqId
        NSArray* lines = [subString componentsSeparatedByString:@"\n"];
        NSInteger seqNo = [[lines objectAtIndex:0] intValue];
        if ( seqNo != INT_MAX && seqNo!=INT_MIN ){
            _seqId = seqNo;
        }else{
            _seqId = 0;
        }
        
        // Parse time
        NSArray* times = [[lines objectAtIndex:1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        
        // For srt format, it strict to be 3 component in time cue line: "<starttime> --> <endtime>"
        // so if the count != 3 mean this string have bad time marker.
        if ([times count] != 3){
            return nil;
        }
        
        _startTime = [self parseTime: [times objectAtIndex:0]];
        if(_startTime < 0)
            return nil;
        _endTime = [self parseTime:[times objectAtIndex:2]];
        if (_endTime < 0) {
            return nil;
        }

        NSMutableString* text = [[NSMutableString alloc] init];
        for(int i = 2; i < [lines count]; i++){
            NSString* line = [lines objectAtIndex:i];
            if([text length] > 0 && [line length] >0){
                [text appendString:@"\n"];
            }
            
            [text appendString:line];
        }
        _text = [NSString stringWithString:text];
    }
    return self;
}
//------------------------------------------------------------------------------
- (NSTimeInterval) parseTime: (NSString*) timeString
{
    NSArray* timeElements = [timeString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    NSTimeInterval seconds = 0.0;
    if ([timeElements count] == 3) {
        seconds +=  [[timeElements objectAtIndex:2] doubleValue] +
                    [[timeElements objectAtIndex:1] doubleValue] * 60.0f +
                    [[timeElements objectAtIndex:1] doubleValue] * 3600.0f;
        return seconds;
    }else{
        return -1.0f;
    }
}

@end
//==============================================================================
@implementation SFSubtitleSMIFrame
@synthesize startTime=_startTime;
@synthesize endTime=_endTime;
@synthesize text=_text;
@synthesize seqId=_seqId;
@synthesize settings=_settings;

//------------------------------------------------------------------------------
+ (id<SFSubtitleFrame>) subtitleFrameFromString:(NSString *)subString
{
    return [[SFSubtitleSMIFrame alloc] initWithCueString:subString];
}
- (id) initWithCueString: (NSString*) cueString
{
    self = [super init];
    if (self) {
        // TODO: breaking down the cueString and fill the iVar
    }
    return self;
}

@end
