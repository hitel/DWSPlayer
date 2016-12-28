//
//  DWSMoviePlayerView.h
//  DWSPlayer
//
//  Created by 戴旺胜 on 2016/12/13.
//  Copyright © 2016年 DaiWangsheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface DWSMoviePlayerView : UIView

- (instancetype)initWithFrame:(CGRect)frame andURLArray:(NSArray <NSURL *>*)array;

@end
