//
//  NSAttributedString+CLNUtilities.h
//  SubPlayerTest
//
//  Created by Jack on 2/7/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (CLNUtilities)
- (CGFloat)boundingWidthForHeight:(CGFloat)inHeight;
- (CGFloat)boundingHeightForWidth:(CGFloat)inWidth;
@end
