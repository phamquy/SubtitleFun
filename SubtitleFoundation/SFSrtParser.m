//
//  SFSrtParser.m
//  SubPlayerTest
//
//  Created by Jack on 2/13/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "SFSrtParser.h"
#import "SFSubtitleFrame.h"
#import "SFSubtitleTrack.h"
#import "SFSubtitleParseService.h"
#import "SFFrameData.h"

@implementation SFSrtParser

//------------------------------------------------------------------------------
+ (NSTimeInterval) parseTime: (NSString*) timeString
{
    NSArray* timeElements = [timeString
                             componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
    NSTimeInterval seconds = 0.0;
    
    NSString* secondStr =[[timeElements objectAtIndex:2]
                          stringByReplacingOccurrencesOfString:@","
                          withString:@"."];
    
    if ([timeElements count] == 3) {
        seconds +=  [secondStr doubleValue] +
        [[timeElements objectAtIndex:1] doubleValue] * 60.0f +
        [[timeElements objectAtIndex:0] doubleValue] * 3600.0f;
        return seconds;
    }else{
        return -1.0f;
    }
}
//------------------------------------------------------------------------------

- (NSArray*) tracksFromContentString:(NSString *)content
                      preferLanguage:(NSString *)lang
{
    NSString* nixContent = [content stringByReplacingOccurrencesOfString:@"\r"
                                                              withString:@""];
    
    NSArray* subStrings = [nixContent componentsSeparatedByString:@"\n\n"];
    
    //NSLog(@"%d", [subStrings count]);
    
    NSMutableArray* subFrames = [[NSMutableArray alloc] init];
    
    for(NSString *subString in subStrings){
        //NSLog(@"%@", subString);
        SFSubtitleFrame* subFrame =
        [self makeSubtitleFrameFromSRTString:subString];
        if (subFrame) {
            [subFrames addObject:subFrame];
        }
    }
    
    if ([subFrames count] > 0) {
        return [NSArray
                arrayWithObject:[[SFSubtitleTrack alloc]
                                 initWithFrames:subFrames
                                 language:lang]];
    }
    return nil;
    
}

//------------------------------------------------------------------------------
- (NSArray*) tracksFromContentURL:(NSURL *)url
{
#warning need implementation
    return nil;
}

//------------------------------------------------------------------------------
#pragma mark SFSrtPaser (Private Utilities)
- (SFSubtitleFrame*) makeSubtitleFrameFromSRTString:(NSString*) subtitleString
{
    SFSubtitleFrame* subFrame = [[SFSubtitleFrame alloc] init];
    // seqId
    NSArray* lines = [subtitleString componentsSeparatedByString:@"\n"];
    
    NSInteger seqNo = [[lines objectAtIndex:0] intValue];
    if ( seqNo != INT_MAX && seqNo!=INT_MIN ){
        [subFrame setSeqId: seqNo];
    }else{
        [subFrame setSeqId: 0];
    }
    
    // Parse time
    NSArray* times =
    [[lines objectAtIndex:1]
     componentsSeparatedByCharactersInSet:
     [NSCharacterSet characterSetWithCharactersInString:@" "]];
    
    // For srt format, it strict to be 3 component in time cue line:
    // "<starttime> --> <endtime>" so if the count != 3 mean this string
    // have bad time marker.
    if ([times count] != 3){
        return nil;
    }
    
    NSTimeInterval startTime =
        [SFSrtParser parseTime: [times objectAtIndex:0]];
    
    if(startTime < 0)
        return nil;
    else
        [subFrame setStartTime:startTime];
    
    NSTimeInterval endTime = [self parseTime:[times objectAtIndex:2]];
    if (endTime < 0)
        return nil;
    else
        [subFrame setEndTime:endTime];
    
    NSMutableString* text = [[NSMutableString alloc] init];
    for(int i = 2; i < [lines count]; i++){
        NSString* line = [lines objectAtIndex:i];
        if([text length] > 0 && [line length] >0){
            [text appendString:@"\n"];
        }
        
        [text appendString:line];
    }
    
    SFFrameData* data = [self frameDataWithString: text];
    if (data) {
        subFrame.data = data;
    }else{
        return nil;
    }
    
    return subFrame;
}
//------------------------------------------------------------------------------
- (NSTimeInterval) parseTime: (NSString*) timeString
{
    NSArray* timeElements =
    [timeString componentsSeparatedByCharactersInSet:
     [NSCharacterSet characterSetWithCharactersInString:@":"]];
    
    NSTimeInterval seconds = 0.0;
    if ([timeElements count] == 3) {
        seconds +=  [[timeElements objectAtIndex:2] doubleValue] +
        [[timeElements objectAtIndex:1] doubleValue] * 60.0f +
        [[timeElements objectAtIndex:0] doubleValue] * 3600.0f;
        return seconds;
    }else{
        return -1.0f;
    }
}

//------------------------------------------------------------------------------
- (SFFrameData*) frameDataWithString: (NSString*) srtText
{
    SFFrameData* fdata = [[SFFrameData alloc] init];
    
    NSMutableAttributedString *attString=
    [[NSMutableAttributedString alloc] initWithString:srtText];
    NSInteger stringLength=[srtText length];
    
    UIColor *green = [UIColor greenColor];
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold"
                                   size:18.0f];
    
    NSShadow *shadowDic=[[NSShadow alloc] init];
    [shadowDic setShadowBlurRadius:5.0];
    [shadowDic setShadowColor:[UIColor grayColor]];
    [shadowDic setShadowOffset:CGSizeMake(0, 3)];
    
    [attString addAttribute:NSFontAttributeName
                      value:font
                      range:NSMakeRange(0, stringLength)];
    
    [attString addAttribute:NSForegroundColorAttributeName
                      value:green
                      range:NSMakeRange(0, stringLength)];
    
    [attString addAttribute:NSShadowAttributeName
                      value:shadowDic
                      range:NSMakeRange(0, stringLength)];
    
    fdata.attText = attString;
    return fdata;
}
@end
