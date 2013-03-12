//
//  SFSmiParser.m
//  SubPlayerTest
//
//  Created by Jack on 2/13/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//


#import <stdio.h>

#import "SFSamiParser.h"
#import "SFSubtitleTrack.h"
#import "SFSubtitleFrame.h"
#import "SFFrameData.h"
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

//------------------------------------------------------------------------------
#pragma mark - Xml Utilities
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
//------------------------------------------------------------------------------
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
//------------------------------------------------------------------------------
/*
 Example of a node:
 <P Class=KR>
    <font color="#ec14bd">Honey bunny cookie</font><br>
    <font color="#ec14bd">Sandy, Rickie, cupcake</font>
 */

xmlChar*
getTextOfNode(xmlNodePtr pnode)
{
    // TODO: xmlNodeGetContent return low case --> need fix
    xmlChar* textForNode =  xmlNodeGetContent(pnode);
    return textForNode;
}

//==============================================================================
#pragma mark - SFSamiFrameData
@interface SFSamiFrameData : NSObject
@property (nonatomic, strong) NSString* text;
@property (nonatomic) NSInteger timePos;
@end


@implementation SFSamiFrameData

@synthesize text, timePos;
- (NSString*) description
{
    return [NSString stringWithFormat:@"{%d, %@}", timePos, text];
}
@end
//==============================================================================
#pragma mark - SFSamiClass
@interface SFSamiClass : NSObject
+ (id) samiClassFromCssString: (NSString*) cssString;
- (id) initWithCssString:(NSString*) cssString;
@property (nonatomic, strong) NSString* classId;
@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* lang;
@property (nonatomic, strong) NSString* type;
@property (nonatomic, strong) NSMutableArray* cues;
//- (void) addFrameData: (SFSamiFrameData*) data;
- (void)  addText:(NSString*) text
           atTime:(NSInteger) timePos /*in miliseconds*/;
@end

@implementation SFSamiClass
@synthesize
classId=_classId,
name=_name,
lang=_lang,
type=_type,
cues=_cues;


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
        _cues = [NSMutableArray array];
        if (![self populateContentFromCssString: cssString]) {
            return nil;
        }
    }
    return self;
}

//------------------------------------------------------------------------------
- (BOOL) populateContentFromCssString: (NSString*) cssString
{
//    NSLog(@"Class CSS string: %@", cssString);
    
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

//------------------------------------------------------------------------------
- (SFSubtitleTrack*) subtitleTrack
{
// ???: sort array??
//    [_cues sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        //
//    }];
    NSMutableArray* subFrames = [NSMutableArray arrayWithCapacity:[_cues count]];
    int seqId = 0;
    SFSubtitleFrame* lastFrame = nil;
    for (SFSamiFrameData* cueData in _cues) {
        if ([[cueData text]length] > 0) {
            seqId++;
            SFSubtitleFrame* subFrame = [[SFSubtitleFrame alloc] init];
            subFrame.seqId = seqId;
            subFrame.startTime = (NSTimeInterval) cueData.timePos / 1000.0f;
            subFrame.endTime = (NSTimeInterval) cueData.timePos / 1000.0f + 5.0f; // make it last 5s by default
            subFrame.data = [self frameDataWithString:[cueData text]];
            lastFrame = subFrame;
            [subFrames addObject:subFrame];
        }else{
            // Update endtime
            if (lastFrame) {
                lastFrame.endTime = (NSTimeInterval) cueData.timePos / 1000.0f;
            }
        }
    }
    
    return [[SFSubtitleTrack alloc]  initWithFrames:subFrames
                                           language:[self lang]];
}

//------------------------------------------------------------------------------
- (SFFrameData*) frameDataWithString: (NSString*) srtText
{
    SFFrameData* fdata = [[SFFrameData alloc] init];
    
    NSMutableAttributedString *attString=
    [[NSMutableAttributedString alloc] initWithString:srtText];
    
    fdata.attText = attString;
    return fdata;
}
//------------------------------------------------------------------------------
- (NSString*) description
{
    return [NSString stringWithFormat:@"SFSamiClass: {classId: %@, name: %@,"
                        "lang: %@, type: %@}", _classId, _name, _lang, _type];
}

//------------------------------------------------------------------------------
// TODO: improve way to add samiframe data to reduce memory footprint
- (void)  addText:(NSString*) text
           atTime:(NSInteger) timePos /*in miliseconds*/
{
    SFSamiFrameData* smiFrameData = [[SFSamiFrameData alloc] init];
    smiFrameData.timePos = timePos;
    smiFrameData.text = text;
    [_cues addObject:smiFrameData];
}

@end


#pragma mark - SFSamiParser
//==============================================================================
@interface SFSamiParser ()
{
    NSDictionary* samiHeader;

}
@end

//==============================================================================
@implementation SFSamiParser
- (id)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
//------------------------------------------------------------------------------
- (NSArray*) tracksFromContentString:(NSString *) subContent
                      preferLanguage:(NSString *)lang
{
    samiHeader = [self samiHeaderFromContent: subContent];
    //NSLog(@"HEADER: %@", samiHeader);
    
    // Parse subtitle content and save it to SFSamiClass
    [self parseContent: subContent defaultLanguage: lang];

    
    
    // Return only non-empty track
    NSMutableArray* returnTracks = [NSMutableArray
                                    arrayWithCapacity:[[samiHeader allKeys] count]];

    for (id key  in [samiHeader allKeys]) {
        SFSamiClass* smClass = (SFSamiClass*) [samiHeader objectForKey:key];
        if ([[smClass cues] count] > 0) {
            SFSubtitleTrack* subTrack = [smClass subtitleTrack];
            if (subTrack) {
                [returnTracks addObject:subTrack];
            }
            
//            for (SFSubtitleFrame* frame in [subTrack subtitleFrames]) {
//                NSLog(@"%@", frame);
//            }
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
/*
 This function convert:
 <br> --> \n
 &nbsp --> <space>
 */
- (NSString*) deHtmlize: (NSString*) samiCue
{
    NSMutableString* escapseFromHtml = [NSMutableString
                                        stringWithString:samiCue];
    [escapseFromHtml
     replaceOccurrencesOfString:@"\n"
     withString:@""
     options:NSCaseInsensitiveSearch
     range:NSMakeRange(0, [escapseFromHtml length])];

    [escapseFromHtml
     replaceOccurrencesOfString:@"\r"
     withString:@""
     options:NSCaseInsensitiveSearch
     range:NSMakeRange(0, [escapseFromHtml length])];

    
    [escapseFromHtml
     replaceOccurrencesOfString:@"&nbsp;"
     withString:@" "
     options:NSCaseInsensitiveSearch
     range:NSMakeRange(0, [escapseFromHtml length])];
    
    [escapseFromHtml
     replaceOccurrencesOfString:@"<br>"
     withString:@"\n"
     options:NSCaseInsensitiveSearch
     range:NSMakeRange(0, [escapseFromHtml length])];
        
    NSString* retStr = [escapseFromHtml
                  stringByTrimmingCharactersInSet:[NSCharacterSet
                                                   whitespaceAndNewlineCharacterSet]];
    //NSLog(@"%@", retStr);
    return retStr;
}

//------------------------------------------------------------------------------
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
    
    if (!strHEAD) {
        return nil;
    }
    
    // Search for css string describe language classes
    NSError* error=nil;
    NSRegularExpression *classReg = [NSRegularExpression
                                     regularExpressionWithPattern:kSFSamiRegExClass
                                     options:NSRegularExpressionCaseInsensitive
                                     error:&error];
    if (error) {
        return nil;
    }
    
    NSArray* clsMatches = [classReg
                           matchesInString:strHEAD
                           options:0
                           range:NSMakeRange(0, [strHEAD length])];
    
    if (!clsMatches || ([clsMatches count]==0)) {
        return nil;
    }
    
    for (NSTextCheckingResult* clsMatch in clsMatches)
    {
        SFSamiClass* smiClass =
        [SFSamiClass samiClassFromCssString:[strHEAD
                                             substringWithRange:clsMatch.range]];

        if (smiClass) {
            [smiHeader setObject:smiClass
                          forKey:[smiClass.classId lowercaseString]];
        }
    }
    
    return smiHeader;
}

//------------------------------------------------------------------------------
/**
 Parse a single subtitle cue and create a subtitle frame and push it in one of
 subtitle track in tempSubtitleTrack.
 @param cueString string that contain data of a <sync ...> section. For example:
 
 <SYNC Start=3195906>
    <P Class=KR>
        <font color="#ec14bd">Honey bunny cookie</font><br>
        <font color="#ec14bd">Sandy, Rickie, cupcake</font>
    <P Class=EN>
        <font color="#ec14bd">Honey bunny cookie</font><br>
        <font color="#ec14bd">Sandy, Rickie, cupcake</font>
 
 */
- (void) addFrameFromString: (NSString*) cueString
{
    BOOL err = NO;
    NSString* lowcaseString = [cueString lowercaseString];
    xmlDocPtr cueXmlDoc = getHtmlDoc((xmlChar*)[lowcaseString UTF8String]);
    xmlChar* xPath = (xmlChar*) "/html/body/sync/p";
    xmlChar* xPathSync = (xmlChar*) "/html/body/sync";
    xmlNodeSetPtr nodeSet;
    xmlXPathObjectPtr xPathResult, xPathResultSync;
    int timePos = 0;
    
    // Workout time information
    xPathResultSync = getNodeSet(cueXmlDoc, xPathSync);
    if (xPathResultSync) {
        err = NO;
        nodeSet= xPathResultSync->nodesetval;
        xmlNodePtr syncNode = nodeSet->nodeTab[0];
        xmlChar* start = xmlGetProp(syncNode, (const xmlChar *) "start");
        if (!start) {
            err = YES;
        }
        
        if (!err) {
            timePos = atoi((const char*)start);
            if (timePos < 0) {
                err = YES;
            }
        }
        
        if (start) {
            xmlFree(start);
        }
        xmlXPathFreeObject(xPathResultSync);
    }
    
    if (!err) {
        
        // Query all the <p> node from input
        xPathResult = getNodeSet(cueXmlDoc, xPath);
        if (xPathResult) {
            nodeSet = xPathResult->nodesetval;
            for (int i = 0; i< nodeSet->nodeNr; i++) {
                
                xmlNodePtr pNode = nodeSet->nodeTab[i];
                xmlChar* classId = NULL;
                xmlChar* nodeText = NULL;
                
                classId = xmlGetProp(pNode, (const xmlChar *) "class");
                //fprintf(stdout, "ClassID: %s", classId);
                if (classId)
                {
                    NSString* classIdKey =
                        [NSString stringWithUTF8String:(const char*)classId];
                    
                    // Get text from <p> node
                    nodeText = getTextOfNode(pNode); //TODO: check return pointer
                    //fprintf(stdout, "\nText for node: %s", nodeText);
                    
                    // Add obtained text to
                    if (nodeText) {
                        // Get current text of the same class
                        SFSamiClass* samiClass =
                        [samiHeader objectForKey:[classIdKey lowercaseString]];
                        
                        [samiClass addText:[NSString
                                            stringWithUTF8String:(const char*)nodeText]
                                    atTime:timePos];
                    }
                }
                
                if(nodeText) xmlFree(nodeText);
                if(classId) xmlFree(classId);                
            }
            xmlXPathFreeObject(xPathResult);
        }else{
            err = YES;
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
            [self addFrameFromString: [self deHtmlize:currentSubCue] ];
        }
        
        curSyncTag = nextSyncTag;
    }
    xmlCleanupParser();
    
//    for (id key in [samiHeader allKeys]) {
//        SFSamiClass* smClass = (SFSamiClass*) [samiHeader objectForKey:key];
//        NSLog(@"Parse subtitle:\n%@",smClass);
//        for (SFSamiFrameData* data in [smClass cues]) {
//            NSLog(@"%@", data);
//        }
//    }
}


@end