SubtitleFun
===========

An easy to use ios subtitle framework.

Update:
- Implement player that can display subtitle (SRT, SMI)
- Support sami file with multi subtitle tracks
- Auto detect subtitle language + character set

Quick guide

    NSString* moviePath = <your movie path>;
    NSString* subPath = <your subtitle path>;
    NSURL* movieURL = [NSURL fileURLWithPath:moviePath];
    
    playerViewController = [[SFPlayerViewController alloc] initWithContentURL:movieURL];

    [self presentViewController:playerViewController animated: YES completion: nil];
    
    [playerViewController.player loadSubtitleFromFile: subPath forLanguage:@"en"];
    [playerViewController.player setShowSubtitle:YES];
    [playerViewController.player play];
    
    
