//
//  NSString+SFSubtitle.m
//  MT2P
//
//  Created by Jack on 3/7/13.
//  Copyright (c) 2013 Jack. All rights reserved.
//

#import "NSString+SFSubtitle.h"

@implementation NSString (SFSubtitle)

+ (NSString*) stringForPlaytime: (NSTimeInterval) time
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    if (time >= 3600) {
        [formatter setDateFormat:@"HH:mm:ss"];
    } else {
        [formatter setDateFormat:@"mm:ss"];
    } 
    return [formatter stringFromDate:date];
}

@end
