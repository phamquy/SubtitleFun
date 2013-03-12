//
//  SFAFPlayerViewController.m
//  SubPlayerTest
//
//  Created by Jack on 2/26/13.
//  Copyright (c) 2013 Clunet. All rights reserved.
//

#import "SFAVPlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SFAVPlayerView.h"
@interface SFAVPlayerViewController ()
{
    AVPlayer* _avPlayer;
    SFAVPlayerView* _sfPlayerView;
    
}
@end

@implementation SFAVPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
