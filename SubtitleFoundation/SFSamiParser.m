//
//  SFSmiParser.m
//  SubPlayerTest
//
//  Created by Jack on 2/13/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "SFSamiParser.h"
#import "SFSubtitleTrack.h"
#import <libxml/tree.h>
#import <libxml/parser.h>
#import <libxml/HTMLtree.h>
#import <libxml/HTMLparser.h>
#import <libxml/xmlstring.h>
#import <libxml/xpath.h>

#define kSFSamiHeaderKeyClasses @"classes"
#define kSFSamiSYNCStartTag @"<sync start="
#define kSFSamiBODYEndTag   @"</body>"
#define kSFSamiSAMIEndTag   @"</sami>"
#define kSFSamiHEADTag      @"<head>"
#define kSFSamiHEADEndTag   @"</head>"


#define kSFSamiRegExClass       @"\\.[a-zA-Z0-9]+\\s*\\{.*?\\}"
#define kSFSamiRegExClassProp   @"([a-zA-Z]+):([a-zA-Z-]+);"
#define kSFSamiRegExClassId     @"\\.([a-zA-Z0-9]+)"


#pragma mark xml Utilities
xmlDocPtr
getHtmlDoc (xmlChar* data) {
	xmlDocPtr doc;
    CFStringEncoding cfenc = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef cfencstr = CFStringConvertEncodingToIANACharSetName(cfenc);
    
    const char *enc = CFStringGetCStringPtr(cfencstr, 0);
    
    int optionsHtml = HTML_PARSE_NOERROR | HTML_PARSE_NOWARNING |
    HTML_PARSE_RECOVER | HTML_PARSE_NODEFDTD;
    
    doc = htmlReadDoc(data, NULL, enc, optionsHtml);
    return doc;
}

xmlXPathObjectPtr
getNodeSet (xmlDocPtr doc, xmlChar *xpath){
	
	xmlXPathContextPtr context;
	xmlXPathObjectPtr result;
    
	context = xmlXPathNewContext(doc);
	if (context == NULL) {
		printf("Error in xmlXPathNewContext\n");
		return NULL;
	}
	result = xmlXPathEvalExpression(xpath, context);
	xmlXPathFreeContext(context);
	if (result == NULL) {
		printf("Error in xmlXPathEvalExpression\n");
		return NULL;
	}
	if(xmlXPathNodeSetIsEmpty(result->nodesetval)){
		xmlXPathFreeObject(result);
        printf("No result\n");
		return NULL;
	}
	return result;
}

//==============================================================================
#pragma mark -
@interface SFSamiClass : NSObject
+ (id) samiClassFromCssString: (NSString*) cssString;
- (id) initWithCssString:(NSString*) cssString;
@property (nonatomic, strong) NSString* classId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* lang;
@property (nonatomic, strong) NSString* type;
@end

@implementation SFSamiClass
@synthesize
classId=_classId,
name=_name,
lang=_lang,
type=_type;


//------------------------------------------------------------------------------
+(id) samiClassFromCssString: (NSString*) cssString
{
    if (!cssString) {
        return nil;
    }
    return [[SFSamiClass alloc] initWithCssString:cssString];
}

//------------------------------------------------------------------------------
- (id) initWithCssString:(NSString*) cssString
{
    self = [super init];
    if (self) {
        if (![self populateContentFromCssString: cssString]) {
            return nil;
        }
    }
    return self;
}

//------------------------------------------------------------------------------
- (BOOL) populateContentFromCssString: (NSString*) cssString
{
    NSLog(@"Class CSS string: %@", cssString);
    
    NSError* error=nil;
    NSRegularExpression *clsIdReg = [NSRegularExpression
                                     regularExpressionWithPattern:kSFSamiRegExClassId
                                     options:NSRegularExpressionCaseInsensitive
                                     error:&error];

    if (error) {
        return NO;
    }

    NSArray* idMatches = [clsIdReg
                          matchesInString:cssString
                          options:0
                          range:NSMakeRange(0, [cssString length])];

    if (!idMatches || ([idMatches count]==0)) {
        return NO;
    }

    NSTextCheckingResult* idMatch = [idMatches objectAtIndex:0];
    _classId = [cssString substringWithRange:[idMatch rangeAtIndex:1]];
    
    NSRegularExpression *clsPropReg = [NSRegularExpression
                                       regularExpressionWithPattern:kSFSamiRegExClassProp
                                       options:NSRegularExpressionCaseInsensitive
                                       error:&error];
    if (error) {
        return NO;
    }

    NSArray* propMatches = [clsPropReg
                            matchesInString:cssString
                            options:0
                            range:NSMakeRange(0, [cssString length])];
    
    if (!propMatches || ([propMatches count]==0)) {
        return NO;
    }
    
    for (NSTextCheckingResult* propMatch in propMatches) {
        NSString* key = [cssString substringWithRange:[propMatch rangeAtIndex:1]];
        NSString* value = [cssString substringWithRange:[propMatch rangeAtIndex:2]];
        
        if ([key compare:@"NAME" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            _name = value;
        }
        else if ([key compare:@"LANG" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            _lang = [[value componentsSeparatedByString:@"-"] objectAtIndex:0];
        }
        else if ([key compare:@"SAMIType" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        {
            _type = value;
        }
    }
    
    return YES;
}


- (NSString*) description
{
    return [NSString stringWithFormat:@"SFSamiClass: {classId: %@, name: %@, lang: %@, type: %@}", _classId, _name, _lang, _type];
}
@end


#pragma mark -
//==============================================================================
@interface SFSamiParser ()
{
    NSDictionary* samiHeader;
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


- (NSDictionary*) samiHeaderFromContent: (NSString*) content
{
    
    NSMutableDictionary* smiHeader = [NSMutableDictionary dictionary];
    
    // Extract header part from content
    NSRange headStart = [content rangeOfString:kSFSamiHEADTag
                                       options:NSCaseInsensitiveSearch];
    
    NSRange headEnd = [content rangeOfString:kSFSamiHEADEndTag
                                     options:NSCaseInsensitiveSearch];
    NSString* strHEAD=nil;
    if ((headStart.location == NSNotFound) ||
        (headEnd.location == NSNotFound))
    {
        strHEAD = nil;
    }else{
        strHEAD= [content substringWithRange:
                  NSMakeRange(headStart.location,
                              headEnd.location-headStart.location+headEnd.length)];
    }
    
    
    // Search for css string describe language classes
    NSError* error=nil;
    NSRegularExpression *classReg = [NSRegularExpression
                                     regularExpressionWithPattern:kSFSamiRegExClass
                                     options:NSRegularExpressionCaseInsensitive
                                     error:&error];
    if (error) {
        smiHeader = nil;
        return smiHeader;
    }
    
    NSArray* clsMatches = [classReg
                           matchesInString:strHEAD
                           options:0
                           range:NSMakeRange(0, [strHEAD length])];
    
    if (!clsMatches || ([clsMatches count]==0)) {
        smiHeader = nil;
        return smiHeader;
    }
    
    
    // Create array of classes
    NSMutableArray* langClasses = [NSMutableArray
                                   arrayWithCapacity:[clsMatches count]];

    for (NSTextCheckingResult* clsMatch in clsMatches)
    {
        SFSamiClass* smiClass =
        [SFSamiClass samiClassFromCssString:[strHEAD
                                             substringWithRange:clsMatch.range]];

        if (smiClass) {
            [langClasses addObject:smiClass];
        }
    }
    
    // Add array of language class as a key/value in header dict
    if ([langClasses count]) {
        // TODO: create array of empty subtitle track
        [smiHeader setObject:langClasses
                      forKey:kSFSamiHeaderKeyClasses];
        return smiHeader;
    }
    
    return nil;
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
    NSString* lowcaseString = [cueString lowercaseString];
    xmlDocPtr cueXmlDoc = getHtmlDoc((xmlChar*)[lowcaseString UTF8String]);
    xmlChar* xPath = (xmlChar*) "/html/body/sync/p";
    xmlNodeSetPtr nodeSet;
    xmlXPathObjectPtr xPathResult;
    
    NSMutableDictionary* classText =
    [NSMutableDictionary
     dictionaryWithCapacity:[[samiHeader
                              objectForKey:kSFSamiHeaderKeyClasses] count]];
    
    // Query all the <p> node from cue text
    xPathResult = getNodeSet(cueXmlDoc, xPath);
    if (xPathResult) {
        nodeSet = xPathResult->nodesetval;
        for (int i = 0; i< nodeSet->nodeNr; i++) {
            xmlNodePtr pNode = nodeSet->nodeTab[i];
            xmlChar* classId;
            classId = xmlGetProp(pNode, (const xmlChar *) "class");
            xmlFree(classId);
        }
    }
    xmlFreeDoc(cueXmlDoc);
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
    
    xmlInitParser();
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
    xmlCleanupParser();
}


@end