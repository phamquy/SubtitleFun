//
//  SFSubtitleParseService.m
//  SubPlayerTest
//
//  Created by Jack on 1/2/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "SFSubtitleParseService.h"
#import "UniversalDetector.h"
#import "SFSubtitleFrame.h"
#import "SFFrameData.h"

#define SFSubtitleExtensionSrt @"srt"
#define SFSubtitleExtensionSmi @"smi"


//------------------------------------------------------------------------------
@implementation SFSubtitleParserService

static SFSubtitleParserService* _shareInstance = nil;

+ (SFSubtitleParserService*) shareInstance
{
    @synchronized([SFSubtitleParserService class])
    {
        if (!_shareInstance) {
            _shareInstance = [[SFSubtitleParserService alloc] init];
        }
        
        return _shareInstance;
    }
    return nil;
}

//------------------------------------------------------------------------------
+ (NSString*) subtitleContentFromURL: (NSURL*) url
                        languageHint: (NSString*) langCode
{
    NSString* dataString = nil;
    NSData* subData  = [NSData dataWithContentsOfURL:url];
    
    // Some special case that autodetector can not handle: Arabic and Czech
    if ([langCode isEqualToString:@"ar"]) {
        dataString = [[NSString alloc] initWithData:subData
                                           encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatinArabic)];
    }else if([langCode isEqualToString:@"cs"]){
        dataString = [[NSString alloc] initWithData:subData
                                           encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingISOLatin2)];
    }
    
    if (dataString == nil) {
        UniversalDetector* detector = [UniversalDetector detector];
        [detector analyzeData:subData];
        NSString* encodingType = [detector MIMECharset];
        NSLog(@"Will encode subtitle with: %@", encodingType);
        
        dataString = [[NSString alloc] initWithData:subData
                                           encoding:[detector encoding]];
        
        if (dataString == nil) {
            if ([@"Big5" isEqualToString:encodingType]) {
                subData = [self cleanBig5:subData];
            }
            dataString = [[NSString alloc] initWithData:subData
                                               encoding:[detector encoding]];
        }
    }
    
    if (dataString == nil) {
        NSLog(@"Failed to encode subtitle");
    }
    return dataString;
}

//------------------------------------------------------------------------------
+ (NSArray*) subtitleTracksFromContentURL:(NSURL *)url
                             languageHint:(NSString*) langCode;
{
    // Read subtitle file to string
    NSString* subString = [SFSubtitleParserService
                           subtitleContentFromURL:url
                           languageHint:langCode];
    
    id<SFSubtitleParser> parser = [SFSubtitleParserService
                                   createParserForURL:url];
    // trim off empty character
    subString = [subString stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
   
    if (subString == nil)
        return  nil;
    
    return [parser tracksFromContentString:subString
                            preferLanguage:langCode];
    
//    // Parsing SRT subtitle
//    if ([subExt compare:SFSubtitleExtensionSrt
//                options:NSCaseInsensitiveSearch] == NSOrderedSame) {
//        return [SFSubtitleParserService parseSRTSubtitle: subString
//                                                language: langCode];
//    }
//    
//    // Parsing SMI subtitle
//    else if ([subExt compare:SFSubtitleExtensionSmi
//                     options:NSCaseInsensitiveSearch] == NSOrderedSame)
//    {
//        return [SFSubtitleParserService parseSMISubtitle:subString];
//    }
//
//    return nil;
}

//-----------------------------------------------------------------------------
+ (NSData *) cleanBig5: (NSData *)inData {
	const uint8_t   *inBytes;
	NSUInteger		inLength;
	NSUInteger      inIndex;
	NSMutableData   *outData;
	uint8_t         *outBytes;
	NSUInteger      outIndex;
	NSUInteger      current;
	
	if(inData==nil) return inData;
	
	inBytes  = [inData bytes];
	inLength = [inData length];
	
	outData = [NSMutableData dataWithLength:inLength];
	if(outData==nil) return inData;
	
	outBytes = [outData mutableBytes];
	outIndex = 0;
	
	BOOL firstByte = YES;
	for (inIndex = 0; inIndex < inLength; inIndex++) {
		current = inBytes[inIndex];
		if (firstByte) {
			if(current >= 0x81 && current <= 0xfE) {
				firstByte = NO;
				
				// Good First byte
				outBytes[outIndex] = current;
			} else if(current <= 0X7F){
				
				//ASCII First byte.
				outBytes[outIndex++] = current;
				
			} else {
				//Bad First Byte
			}
		} else {
			if(((current >= 0x40 && current <= 0x7E) ||
                (current >= 0xA1 && current <= 0xFE)) ) {
				
				//Good Second Byte
				outIndex++;
				outBytes[outIndex++] = current;
			} else {
				
				//Bad Second Byte.
			}
			firstByte = YES;
		}
	}
	
	[outData setLength:outIndex];
	return outData;
}

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
+ (id<SFSubtitleParser>) createParserForURL:(NSURL*) url
{
    NSString* extension = [[url absoluteString] pathExtension];
    if ([extension
         compare:@"SRT"
         options:(NSCaseInsensitiveSearch)] == NSOrderedSame)
    {
        return [[SFSrtParser alloc] init];
    }
    
    if ([extension
         compare:@"SMI"
         options:(NSCaseInsensitiveSearch)] == NSOrderedSame) {
        return [[SFSmiParser alloc] init];
    }
    
    return nil;
}
@end


#pragma mark -
//==============================================================================
@implementation SFSrtParser

- (NSArray*) tracksFromContentString:(NSString *)content
                      preferLanguage:(NSString *)lang
{
    NSString* nixContent = [content stringByReplacingOccurrencesOfString:@"\r"
                                                              withString:@""];
    
    NSArray* subStrings = [nixContent componentsSeparatedByString:@"\n\n"];
    
    NSLog(@"%d", [subStrings count]);
    
    NSMutableArray* subFrames = [[NSMutableArray alloc] init];
    
    for(NSString *subString in subStrings){
        NSLog(@"%@", subString);
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
    
    NSTimeInterval startTime = [SFSubtitleParserService
                                parseTime: [times objectAtIndex:0]];
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

#pragma mark -
//==============================================================================
@implementation SFSmiParser

- (NSArray*) tracksFromContentString:(NSString *)string
                      preferLanguage:(NSString *)lang
{
    return nil;
}

- (NSArray*) tracksFromContentURL:(NSURL *)url
{
    return nil;
}

@end