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
    NSString* subExt = [[url lastPathComponent] pathExtension];
    //NSData* subData = [NSData dataWithContentsOfURL:url];
    
    // Read subtitle file to string
    NSString* subString = [SFSubtitleParserService subtitleContentFromURL:url
                                                             languageHint:langCode];
    // trim off empty character
    subString = [subString stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
   
    if (subString == nil)
        return  nil;
    
    // Parsing SRT subtitle
    if ([subExt compare:SFSubtitleExtensionSrt
                options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        return [SFSubtitleParserService parseSRTSubtitle: subString language:langCode];
    }
    
    // Parsing SMI subtitle
    else if ([subExt compare:SFSubtitleExtensionSmi
                     options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        return [SFSubtitleParserService parseSMISubtitle:subString];
    }
    
    return nil;
}

//-----------------------------------------------------------------------------
/*
 For SRT subtitle format, there is always one subtitle track, so the return array
 contains only one tracks.
 */
+ (NSArray*) parseSRTSubtitle: (NSString*) content
                     language: (NSString*) languageCode
{
    NSString* nixContent = [content stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSArray* subStrings = [nixContent componentsSeparatedByString:@"\n\n"];
    NSLog(@"%d", [subStrings count]);
    
    NSMutableArray* subFrames = [[NSMutableArray alloc] init];
    
    for(NSString *subString in subStrings){
        //NSArray* line = [subCue componentsSeparatedByString:@"\n"];
        id<SFSubtitleFrame> subFrame = [SFSubtitleFrameMaker
                                        makeSubtitleFrameFromeString:subString
                                        withType:SFSubtitleFrameTypeSubRip];
        if (subFrame) {
            [subFrames addObject:subFrame];
        }
    }
    
    if ([subFrames count] > 0) {
        return [NSArray arrayWithObject:[[SFSubtitleTrack alloc] initWithFrames:subFrames
                                                                       language:languageCode]];
    }
    return nil;
}

//-----------------------------------------------------------------------------
+ (NSArray*) parseSMISubtitle: (NSString*) content
{
    
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
			if(((current >= 0x40 && current <= 0x7E) || (current >= 0xA1 && current <= 0xFE)) ) {
				
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
@end
//------------------------------------------------------------------------------

