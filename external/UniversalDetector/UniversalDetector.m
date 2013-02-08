#import "UniversalDetector.h"
#import "WrappedUniversalDetector.h"

@implementation UniversalDetector

+(UniversalDetector *)detector
{
	//return [[[UniversalDetector alloc] init] autorelease];
    return [[UniversalDetector alloc] init]; // For ARC
}

-(id)init
{
	if(self=[super init])
	{
		detector=AllocUniversalDetector();
		charset=nil;
	}
	return self;
}

-(void)dealloc
{
	FreeUniversalDetector(detector);
}

-(void) analyzeContentsOfFile:(NSString*) path
{
	NSData *data = [[NSData alloc] initWithContentsOfMappedFile:path];

	if (data) {
		[self analyzeBytes:[data bytes] length:[data length]];
	}
	//[data release]; // For ARC
}

-(void)analyzeData:(NSData *)data
{
	[self analyzeBytes:(const char *)[data bytes] length:[data length]];
}

-(void)analyzeBytes:(const char *)data length:(int)len
{
	UniversalDetectorHandleData(detector,data,len);
	//[charset release]; // For ARC
	charset=nil;
}

-(void)reset { UniversalDetectorReset(detector); }

-(BOOL)done { return UniversalDetectorDone(detector); }

-(NSString *)MIMECharset
{
	if(!charset)
	{
		const char *cstr=UniversalDetectorCharset(detector,&confidence);
		if(!cstr) return nil;
		charset=[[NSString alloc] initWithUTF8String:cstr];
	}
	return charset;
}

-(float)confidence
{
	if(!charset) [self MIMECharset];
	return confidence;
}

-(NSStringEncoding)encoding
{
	NSString *mimecharset=[self MIMECharset];
	if(!mimecharset) return 0;

	CFStringEncoding cfenc=CFStringConvertIANACharSetNameToEncoding((CFStringRef)mimecharset);
	if(cfenc==kCFStringEncodingInvalidId) return 0;

	// UniversalDetector detects CP949 but returns "EUC-KR" because CP949 lacks an IANA name.
	// Kludge to make strings decode properly anyway.
	if(cfenc==kCFStringEncodingEUC_KR) cfenc=kCFStringEncodingDOSKorean;

	return CFStringConvertEncodingToNSStringEncoding(cfenc);
}

@end
