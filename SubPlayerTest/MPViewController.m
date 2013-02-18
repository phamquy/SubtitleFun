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
@interface MPViewController ()
{
    MPSubMoviePlayerController* subPlayer;
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
                  initWithString:[NSString
                                  stringWithUTF8String:"https://devimages.apple.\
                                  com.edgekey.net/resources/http-streaming/examples\
                                  /bipbop_16x9/bipbop_16x9_variant.m3u8"]];
    
    MPMoviePlayerViewController *theMovie = [[MPMoviePlayerViewController alloc]
                                             initWithContentURL: url];
   
    [self presentMoviePlayerViewControllerAnimated:theMovie];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(myMovieFinishedCallback:)
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:theMovie];
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
    NSString* moviePath = @"/Users/jack/clunet/vicloud/0.tmp/howimet.mp4";
    NSString* subPath = @"/Users/jack/clunet/vicloud/0.tmp/howimet.srt";
    
    NSURL* movieURL = [NSURL fileURLWithPath:moviePath];
    
    subPlayer = [[MPSubMoviePlayerController alloc] initWithContentURL:movieURL];
    [subPlayer loadSubtitleFromFile: subPath forLanguage:@"en"];
    [subPlayer setShowSubtitle:YES];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(moviePlaybackDidFinish:)
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:subPlayer];

    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(moviePlaybackStateDidChange:)
     name:MPMoviePlayerPlaybackStateDidChangeNotification
     object:subPlayer];

    subPlayer.shouldAutoplay = NO;
    [subPlayer.view setFrame:[[self view] bounds]];
    
    [subPlayer.view setAutoresizingMask:(UIViewAutoresizingFlexibleWidth |
                                         UIViewAutoresizingFlexibleHeight)];
    
    [self.view addSubview:subPlayer.view];
    [subPlayer play];
    
    [self performSelector:@selector(inspectPlayerView) withObject:nil afterDelay:0.1];

}


//------------------------------------------------------------------------------
// TEST
-(void)inspectPlayerView
{
    [self recursiveViewTraversal:subPlayer.view counter:0];
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:subPlayer];
    [subPlayer.view removeFromSuperview];
    subPlayer = nil;
}

- (void) moviePlaybackStateDidChange: (NSNotification*) notification {
    NSLog(@"moviePlaybackStateDidChange to: %d", [subPlayer playbackState] );
    NSLog(@"Movie current playback tim: %.3f", [subPlayer currentPlaybackTime]);
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
