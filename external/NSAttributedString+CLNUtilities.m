//
//  NSAttributedString+CLNUtilities.m
//  SubPlayerTest
//
//  Created by Jack on 2/7/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "NSAttributedString+CLNUtilities.h"
#import <CoreText/CoreText.h>

//------------------------------------------------------------------------------
@implementation NSAttributedString (CLNUtilities)
- (CGFloat)boundingWidthForHeight:(CGFloat)inHeight
{
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString( (__bridge CFMutableAttributedStringRef) self);
    
    CGSize suggestedSize =
    CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                 CFRangeMake(0, 0),
                                                 NULL,
                                                 CGSizeMake(CGFLOAT_MAX, inHeight), 
                                                 NULL);
    CFRelease(framesetter);
    return suggestedSize.width;
}

//------------------------------------------------------------------------------
- (CGFloat)boundingHeightForWidth:(CGFloat)inWidth
{
    CTFramesetterRef framesetter =
    CTFramesetterCreateWithAttributedString( (__bridge CFMutableAttributedStringRef) self);
    
    CGSize suggestedSize =
    CTFramesetterSuggestFrameSizeWithConstraints(framesetter,
                                                 CFRangeMake(0, 0),
                                                 NULL,
                                                 CGSizeMake(inWidth, CGFLOAT_MAX),
                                                 NULL);
    CFRelease(framesetter);
    return suggestedSize.height;
}
@end
