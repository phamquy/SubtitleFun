//
//  SFSubtitleController.h
//  SubPlayerTest
//
//  Created by Jack on 1/14/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFMovieSubtitle.h"
@protocol SFMoviePlayerClock <NSObject>
@required
/**
 return current play time
 */
- (NSTimeInterval) currentPlayTime;
@end

@interface SFSubtitleController : NSObject
@property(nonatomic, weak) id<SFMoviePlayerClock> clock;
@property(nonatomic, strong) SFMovieSubtitle* subtitle;
@property(nonatomic, weak) UIView* viewer;
@property (nonatomic) BOOL showSubtitle;

- (id) initWithViewer: (UIView*) viewer;
- (id) initWithContentURL: (NSURL*) url
               asLanguage: (NSString*) languageCode;

- (void) loadSubtitleFromContentURL: (NSURL*) url
                         asLanguage: (NSString*) languageCode;
@end
