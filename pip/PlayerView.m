//
//  PlayerView.m
//  pip
//
//  Created by Gavin on 2020/11/4.
//

#import "PlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation PlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

@end
