//
//  SFSubtitleView.m
//  SubPlayerTest
//
//  Created by Jack on 1/11/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "SFSubtitleView.h"
#import "SFFrameData.h"
@interface SFSubtitleView ()
{
    UILabel* _subLabel;
}
@end

@implementation SFSubtitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect labelFrame = CGRectMake(0, 0, 1, 1);
        _subLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [_subLabel setBackgroundColor:[UIColor clearColor]];
        [_subLabel setTextColor:[UIColor whiteColor]];
        [_subLabel setTextAlignment:(NSTextAlignmentCenter)];
        [_subLabel setNumberOfLines:0];
        [_subLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:17.0f]];
        [self addSubview:_subLabel];

    }
    return self;
}

//*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect
//{
//    // Drawing code
//}
//*/


//------------------------------------------------------------------------------
- (void) renderSubtitle:(SFFrameData*) renderData
{
    //NSLog(@"Subtitle Frame: %@", NSStringFromCGRect([self frame]));
    if (!renderData) {
        [_subLabel setText:@""];
        return;
    }
    
    NSString* string = [renderData.attText string];
    //NSLog(@"Found subtitle: %@", string);
    [_subLabel setFrame:[self bounds]];
    [_subLabel setText:string];
    [_subLabel sizeToFit];
    
    CGRect lblFrame = [_subLabel frame];
    CGRect viewBound= [self bounds];
    
    lblFrame = CGRectMake((viewBound.size.width - lblFrame.size.width)/2,
                          viewBound.size.height - lblFrame.size.height - 5,
                         lblFrame.size.width,
                         lblFrame.size.height);
    
    [_subLabel setFrame:lblFrame];
}

@end
