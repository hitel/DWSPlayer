//
//  DWSMoviePlayerViewController.h
//  MPMoviePlayer
//
//  Created by DaiWangsheng on 16/11/7.
//  Copyright © 2016年 DaiWangsheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWSMoviePlayerViewController : UIViewController

- (instancetype)initWithUrl:(NSURL *)url;//播放一个视频文件
- (instancetype)initWithFileArray:(NSArray <NSURL *>*)array;//播放一组视频文件
- (void)playAtIndex:(NSInteger)index;//播放指定位置
- (NSInteger)currentIndex;//获取当前数组下标
- (void)title:(NSString *)title;//改变标题

@end
