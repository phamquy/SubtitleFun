//
//  SFSmiParser.m
//  SubPlayerTest
//
//  Created by Jack on 2/13/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "SFSamiParser.h"
#import "SFSubtitleTrack.h"


#define kSFSamiHeaderKeyClasses @"languageClasses"
#define kSFSamiSYNCStartTag @"<sync start="
#define kSFSamiBODYEndTag   @"</body>"
#define kSFSamiSAMIEndTag   @"</sami>"
#define kSFSamiHEADTag      @"<head>"
#define kSFSamiHEADEndTag   @"</head>"

//==============================================================================
#pragma mark -
@interface SFSamiClass : NSObject
@property (nonatomic, strong) NSString* classId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* lang;
@property (nonatomic, strong) NSString* type;
@end

@implementation SFSamiClass
@synthesize classId, name, lang, type;
@end


#pragma mark -
//==============================================================================
@interface SFSamiParser ()
{
    NSString* samiHeader;
    NSMutableArray* subtitleClasses;
    NSMutableArray* tempSubtitleTrack;
}
@end

//==============================================================================
@implementation SFSamiParser
- (id)init
{
    self = [super init];
    if (self) {
        subtitleClasses = [NSMutableArray array];
        tempSubtitleTrack = [NSMutableArray array];
    }
    return self;
}
//------------------------------------------------------------------------------
- (NSArray*) tracksFromContentString:(NSString *) subContent
                      preferLanguage:(NSString *)lang
{
    samiHeader = [self samiHeaderFromContent: subContent];
    NSLog(@"HEADER: %@", samiHeader);
    // TODO: check nil header
    // Work out an array of language classes
//    subtitleClasses = [headers objectForKey:kSFSamiHeaderKeyClasses];
//    tempSubtitleTrack = [NSMutableArray
//                         arrayWithCapacity:[subtitleClasses count]];
//    
//    // ???: consider the case there is no class
//    // Create empty tracks
//    for (SFSamiClass*  class in subtitleClasses) {
//        SFSubtitleTrack* track = [[SFSubtitleTrack alloc] init];
//        [track setLanguageCode: [class lang]];
//        [tempSubtitleTrack addObject:track];
//    }
    
    [self parseContent: subContent defaultLanguage: lang];
    
    // Return only non-empty track
    NSMutableArray* returnTracks = [NSMutableArray
                                    arrayWithCapacity:[tempSubtitleTrack count]];
    for (SFSubtitleTrack* track in tempSubtitleTrack) {
        if ([[track subtitleFrames] count] > 0) {
            [returnTracks addObject:track];
        }
    }

    // Return nil if there is no track found
    if ([returnTracks count] > 0) {
        return returnTracks;
    }else{
        return nil;
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
#pragma mark Private SAMI parsing utilities
- (NSString*) samiHeaderFromContent: (NSString*) content
{
    NSRange headStart = [content rangeOfString:kSFSamiHEADTag
                                       options:NSCaseInsensitiveSearch];
    
    NSRange headEnd = [content rangeOfString:kSFSamiHEADEndTag
                                     options:NSCaseInsensitiveSearch];
    
    if ((headStart.location == NSNotFound) ||
        (headEnd.location == NSNotFound))
    {
        return nil;
    }else{
        return [content substringWithRange:
                NSMakeRange(headStart.location,
                            headEnd.location-headStart.location+headEnd.length)];
    }
}

//------------------------------------------------------------------------------
- (void) parseContent: (NSString*) subContent
      defaultLanguage: (NSString*) lang
{
    // START PARSING
    NSRange curSyncTag = [subContent
                          rangeOfString:kSFSamiSYNCStartTag
                          options:NSCaseInsensitiveSearch
                          range:NSMakeRange(0, [subContent length])];
    
    NSRange nextSyncTag;
    while (curSyncTag.location != NSNotFound) {
        // Extract next subtitle cue from subcontent
        NSRange searchRange =
        NSMakeRange(curSyncTag.location + curSyncTag.length,
                    subContent.length - curSyncTag.location - curSyncTag.length);
        
        nextSyncTag = [subContent
                       rangeOfString:kSFSamiSYNCStartTag
                       options:NSCaseInsensitiveSearch
                       range: searchRange];
        
        NSString* currentSubCue = nil;
        
        // If no next tag found --> cur sync tag is last cue
        if (nextSyncTag.location == NSNotFound)
        {
            // Look for </body> tag and extract last subtitle cue
            NSRange endTag = [subContent
                              rangeOfString:kSFSamiBODYEndTag
                              options:NSCaseInsensitiveSearch
                              range: searchRange];
            
            // No </body> found --> search for </sami>
            if (endTag.location == NSNotFound)
            {
                endTag = [subContent
                          rangeOfString:kSFSamiSAMIEndTag
                          options:NSCaseInsensitiveSearch
                          range: searchRange];
            }
            
            // Found endtag (</body> or </sami>)
            if (endTag.location != NSNotFound)
            {
                // extract current subtitle cue
                currentSubCue =
                [subContent
                 substringWithRange:
                        NSMakeRange(curSyncTag.location,
                                    endTag.location-curSyncTag.location)];
                
            }
        }
        else
        {
            // extract current subtitle cue
            currentSubCue =
            [subContent
             substringWithRange:
                        NSMakeRange(curSyncTag.location,
                                    nextSyncTag.location-curSyncTag.location)];
        }
        
        
        // Extracted a subtitle cue
        if (currentSubCue) {
            [self addFrameFromString: currentSubCue];
        }
        
        curSyncTag = nextSyncTag;
    }    
}

//------------------------------------------------------------------------------
/**
 Parse a single subtitle cue and create a subtitle frame and push it in one of 
 subtitle track in tempSubtitleTrack.
 @param cueString string that contain data of a <sync ...> section. For example:
 
 <SYNC Start=3195906><P Class=KR>
 <font color="#ec14bd">Honey bunny cookie</font><br>
 <font color="#ec14bd">Sandy, Rickie, cupcake</font>
 */
- (void) addFrameFromString: (NSString*) cueString
{
    NSLog(@"Extracted string: %@",cueString);
}
@end