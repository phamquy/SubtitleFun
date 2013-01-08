//
//  MPViewController.m
//  SubPlayerTest
//
//  Created by Jack on 12/21/12.
//  Copyright (c) 2012 Clunet. All rights reserved.
//

#import "MPViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SFSubtitleParseService.h"

@interface MPViewController ()


@end

@implementation MPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)playHLS:(id)sender {
//    NSString* str = @"https:​/​/​devimages.apple.com.edgekey.net/​resources/​http-streaming/​examples/​bipbop_16x9/​bipbop_16x9_variant.m3u8";
    NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithUTF8String:"https:​/​/​devimages.apple.com.edgekey.net/​resources/​http-streaming/​examples/​bipbop_16x9/​bipbop_16x9_variant.m3u8"]];
//   NSURL *url = [NSURL URLWithString:@"https://devimages.apple.com.edgekey.net/resources/http-streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"];
    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc]
                                             initWithContentURL: url];
   
    [self presentMoviePlayerViewControllerAnimated:theMovie];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myMovieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification object:theMovie];
}

- (IBAction)parseSRT:(id)sender {
    NSArray* subTracks = [SFSubtitleParserService
                          subtitleTracksFromContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"subtest" ofType:@"srt"]] languageHint:@"en"];
    
    NSLog(@"%@", [subTracks objectAtIndex:0]);
}


// When the movie is done, release the controller.
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    [self dismissMoviePlayerViewControllerAnimated];
    MPMoviePlayerController* theMovie = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMovie];
}
@end
