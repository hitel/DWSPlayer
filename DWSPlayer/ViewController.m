//
//  ViewController.m
//  DWSPlayer
//
//  Created by DaiWangsheng on 16/11/7.
//  Copyright © 2016年 DaiWangsheng. All rights reserved.
//

#import "ViewController.h"
#import "DWSMoviePlayerViewController.h"

#define LHURL [NSURL URLWithString:@"http://gritty-img.hopenrising.com/C731E493-78C0-0001-4A53-1DD0D2361870.mp4?e=1476239213&token=VVAgS4a3GJWpbNC_86KMQ8gh2QPUlqo5p_cLW7JQ:wwGDKihk2pzllCBgk1ALTmfvAUs="]
#define newURL [NSURL URLWithString:@"http://baobab.wdjcdn.com/1456117847747a_x264.mp4"]

#define mp4 [NSURL URLWithString:@"http://huashun-output.oss-cn-shanghai.aliyuncs.com/Act-ss-mp4-ld/test/w8fZYd5Gfe.mp4"]

@interface ViewController ()

@property UIView *playerView;

@end

@implementation ViewController
@synthesize playerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(fun) forControlEvents:UIControlEventTouchUpInside];
    
    playerView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight/2, ScreenWidth, ScreenHeight/2)];
    playerView.backgroundColor = [UIColor redColor];
    [self.view addSubview:playerView];
}

- (void)fun {
    DWSMoviePlayerViewController *vc = [[DWSMoviePlayerViewController alloc] initWithFileArray:@[mp4,LHURL,newURL]];
    vc.title = @"123";

    
//    [self presentViewController:vc animated:YES completion:nil];
//    return;
    UIView *view = vc.view;
    view.frame = playerView.frame;
    view.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI/2);
    view.transform = CGAffineTransformMakeScale(ScreenWidth/Width,ScreenWidth/Width);
    [self.view addSubview:view];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
