//
//  MPSubMoviePlayerController.m
//  SubPlayerTest
//
//  Created by Jack on 1/8/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

// Post when seeking position change: by user moving player head, or by command
NSString *const MPMoviePlayerSeekingPositionDidChange = @"MPMoviePlayerSeekingPositionDidChange";

#import "MPSubMoviePlayerController.h"
#import <QuartzCore/QuartzCore.h>

//==============================================================================
@interface MPSubMoviePlayerController () 
{
    
}
@end

//==============================================================================
@implementation MPSubMoviePlayerController
- (id) initWithContentURL:(NSURL *)url
{
    self = [super initWithContentURL:url];
    if (self) {
        [self setControlStyle:(MPMovieControlStyleFullscreen)];
    }
    return self;
}

//------------------------------------------------------------------------------
- (void) dealloc
{
    NSLog(@"Dealloc MPSubMoviePlayerController");
}
@end