//
//  ViewController.m
//  pip
//
//  Created by Gavin on 2020/10/23.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerView.h"

@interface ViewController () <AVPictureInPictureControllerDelegate>

@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPictureInPictureController *pipController;
@property (strong, nonatomic) AVPlayerItem *playerItem;

@property (weak, nonatomic) IBOutlet PlayerView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIButton *pipButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // init player
    NSURL *url = [NSURL URLWithString:@"https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8"];
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    [self.playerItem addObserver:self
                 forKeyPath:@"status"
                    options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                    context:nil];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem ];
    
    // init player layer
    AVPlayerLayer * playerLayer = (AVPlayerLayer *)self.playerView.layer;
    playerLayer.player = self.player;
    
    // init pip controller
    self.pipController = [[AVPictureInPictureController alloc] initWithPlayerLayer:playerLayer];
    self.pipController.delegate = self;
    [self.pipController addObserver:self
                         forKeyPath:@"pictureInPicturePossible"
                            options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                            context:nil];

    if ([AVPictureInPictureController isPictureInPictureSupported] == NO) {
        self.pipButton.enabled = NO;
        NSLog(@"pip not supported");
    }

}

- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.pipController removeObserver:self forKeyPath:@"pictureInPicturePossible"];
}

- (IBAction)play:(id)sender {
    [self.player play];
}

- (IBAction)pause:(id)sender {
    [self.player pause];
}

- (IBAction)pip:(id)sender {
    if ([AVPictureInPictureController isPictureInPictureSupported] == NO) {
        return;
    }
    
    if (self.pipController.isPictureInPictureActive) {
        [self.pipController stopPictureInPicture];
    } else {
        [self.pipController startPictureInPicture];
    }
}

- (IBAction)longPress:(id)sender {
    if ([AVPictureInPictureController isPictureInPictureSupported] == NO) {
        return;
    }
    
    if (self.pipController.isPictureInPictureActive) {
        [self.pipController stopPictureInPicture];
    }
}


#pragma mark - AVPictureInPictureControllerDelegate
- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error {
    NSLog(@"Failed to start pip:%@", error);
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([object isKindOfClass:[AVPictureInPictureController class]]) {
        if (self.pipController.isPictureInPicturePossible == NO) {
            self.pipButton.enabled = NO;
        } else {
            self.pipButton.enabled = YES;
        }
    }
    
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        if ([keyPath isEqualToString:@"status"]) {
            AVPlayerItemStatus status = AVPlayerItemStatusUnknown;
            NSNumber *statusNumber = change[NSKeyValueChangeNewKey];
            if ([statusNumber isKindOfClass:[NSNumber class]]) {
                status = statusNumber.integerValue;
            }
            switch (status) {
                case AVPlayerItemStatusReadyToPlay:
                    NSLog(@"Ready to play");
                    self.playButton.enabled = YES;
                    self.pauseButton.enabled = YES;
                    break;
                case AVPlayerItemStatusFailed:
                    NSLog(@"Failed to play:%@", ((AVPlayerItem *)object).error);
                    self.playButton.enabled = NO;
                    self.pauseButton.enabled = NO;
                    break;
                case AVPlayerItemStatusUnknown:
                    NSLog(@"Not ready");
                    break;
            }
        }
    }
}

@end
