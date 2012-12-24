//
//  SFSubtitleFrame.h
//  SubPlayerTest
//
//  Created by Jack on 12/24/12.
//  Copyright (c) 2012 Clunet. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SFSubtitleFrame : NSObject
@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval duration;
@property (nonatomic, strong) NSString* text;

- (id) initWithStartTime: (NSTimeInterval) start
                duration: (NSTimeInterval) duration
                    text: (NSString*) text;
@end
