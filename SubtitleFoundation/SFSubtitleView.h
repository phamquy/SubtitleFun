//
//  SFSubtitleView.h
//  SubPlayerTest
//
//  Created by Jack on 1/11/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import <UIKit/UIKit.h>

//------------------------------------------------------------------------------
@interface SFSubtitleLabel : UILabel

@end

//------------------------------------------------------------------------------
@class SFFrameData;
@protocol SFSubtitleDisplayer <NSObject>

@required
- (void) renderSubtitle:(SFFrameData*) renderData;

@end

//------------------------------------------------------------------------------
@interface SFSubtitleView : UIView <SFSubtitleDisplayer>

@end
