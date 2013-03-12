//
//  MPViewController.m
//  SubPlayerTest
//
//  Created by Jack on 12/21/12.
//  Copyright (c) 2012 Clunet. All rights reserved.
//


//TEST
#import <objc/runtime.h>


#import "MPViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "SFSubtitleParseService.h"
#import "MPSubMoviePlayerController.h"
#import "SFPlayerViewController.h"

@interface MPViewController ()
{
    MPSubMoviePlayerController* subPlayer;
    SFPlayerViewController* playerViewController;
}

@end
//------------------------------------------------------------------------------
@implementation MPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//------------------------------------------------------------------------------
- (IBAction)playHLS:(id)sender {

    NSURL *url = [[NSURL alloc]
                  initWithString:@"http://192.168.0.69/~jack/Streaming/dexter/dexter.m3u8"];
    
//    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc]
//                                             initWithContentURL: url];
//   
//    [self presentMoviePlayerViewControllerAnimated:theMovie];
//    
//    [[NSNotificationCenter defaultCenter]
//     addObserver:self
//     selector:@selector(myMovieFinishedCallback:)
//     name:MPMoviePlayerPlaybackDidFinishNotification
//     object:theMovie];
//    
    
    playerViewController = [[SFPlayerViewController alloc] initWithContentURL:url];
    
    [self presentViewController:playerViewController animated: YES completion: nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(moviePlaybackDidFinish:)
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:playerViewController.player];
//    [playerViewController.player loadSubtitleFromFile: subPath forLanguage:@"en"];
//    [playerViewController.player setShowSubtitle:YES];
    [playerViewController.player play];
}

//------------------------------------------------------------------------------
- (IBAction)parseSRT:(id)sender {
    NSArray* subTracks =
    [SFSubtitleParserService
     subtitleTracksFromContentURL:[NSURL fileURLWithPath:@"/Users/jack/clunet/vicloud/0.tmp/dexter.smi"]
     languageHint:@"en"];
    
    NSLog(@"%@", [subTracks objectAtIndex:0]);
}

//------------------------------------------------------------------------------
- (IBAction)playMovie:(id)sender {
//    NSString* moviePath = @"/Users/jack/clunet/vicloud/0.tmp/dexter.mp4";
//    NSString* subPath = @"/Users/jack/clunet/vicloud/0.tmp/dexter.smi";

    NSString* moviePath = [[NSBundle mainBundle] pathForResource:@"dexter" ofType:@"mp4"];
    NSString* subPath = [[NSBundle mainBundle] pathForResource:@"dexter" ofType:@"smi"];
    NSURL* movieURL = [NSURL fileURLWithPath:moviePath];
//    
//    subPlayer = [[MPSubMoviePlayerController alloc] initWithContentURL:movieURL];
//    
//    subPlayer.shouldAutoplay = NO;
//    [subPlayer.view setFrame:[[self view] bounds]];
//    
//    [subPlayer.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
//                                         UIViewAutoresizingFlexibleHeight)];
//    
//    [self.view addSubview:subPlayer.view];
//        [subPlayer play];
//
//    [subPlayer loadSubtitleFromFile: subPath forLanguage:@"en"];
//    [subPlayer setShowSubtitle:YES];
//    
//    [self performSelector:@selector(inspectPlayerView) withObject:nil afterDelay:10];

    playerViewController = [[SFPlayerViewController alloc] initWithContentURL:movieURL];
    
    [self presentViewController:playerViewController animated: YES completion: nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(moviePlaybackDidFinish:)
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:playerViewController.player];
    [playerViewController.player loadSubtitleFromFile: subPath forLanguage:@"en"];
    [playerViewController.player setShowSubtitle:YES];
    [playerViewController.player play];
}


//------------------------------------------------------------------------------
// TEST
-(void)inspectPlayerView
{
    [subPlayer setFullscreen:YES];
//
//    [subPlayer loadSubtitleFromFile: @"/Users/jack/clunet/vicloud/0.tmp/howimet.srt" forLanguage:@"en"];
//    [subPlayer setShowSubtitle:YES];
    //[self recursiveViewTraversal:subPlayer.view counter:0];
}

//------------------------------------------------------------------------------
-(void)recursiveViewTraversal:(UIView*)view counter:(int)counter {
    const char* className = class_getName([view class]);
    NSLog(@"Depth %d - %s", counter, className); //For debug
    for(UIView *child in [view subviews]) {
        [self recursiveViewTraversal:child counter:counter+1];
    }    
}

//------------------------------------------------------------------------------
- (void) moviePlaybackDidFinish:(NSNotification*)notification {
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:MPMoviePlayerPlaybackDidFinishNotification
//                                                  object:subPlayer];
//    [subPlayer.view removeFromSuperview];
//    subPlayer = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    MPMoviePlayerController* player = [notification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player];
    playerViewController = nil;
}
//------------------------------------------------------------------------------
- (void) moviePlaybackStateDidChange: (NSNotification*) notification {
    NSLog(@"moviePlaybackStateDidChange to: %d", [subPlayer playbackState] );
    NSLog(@"Movie current playback tim: %.3f", [subPlayer currentPlaybackTime]);
}
//------------------------------------------------------------------------------
- (void )changeFullScreenMode: (NSNotification*) notification
{

}
//------------------------------------------------------------------------------
- (IBAction)test:(id)sender {
        
    NSString* urlString = @"http://192.168.10.167/_hls_file?file=20130110093632796.m3u8";
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSLog(@"%@", [url parameterString]);
}
//------------------------------------------------------------------------------
- (IBAction)htmlparse:(id)sender {

    
    //[parser release];
}

//------------------------------------------------------------------------------
// When the movie is done, release the controller.
-(void)myMovieFinishedCallback:(NSNotification*)aNotification {
    [self dismissMoviePlayerViewControllerAnimated];
    MPMoviePlayerController* theMovie = [aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:theMovie];
}
@end
