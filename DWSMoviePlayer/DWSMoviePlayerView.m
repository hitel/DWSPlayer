//
//  DWSMoviePlayerView.m
//  DWSPlayer
//
//  Created by 戴旺胜 on 2016/12/13.
//  Copyright © 2016年 DaiWangsheng. All rights reserved.
//

#import "DWSMoviePlayerView.h"

#define ScreenHeight ([[UIScreen mainScreen] bounds].size.height)
#define ScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define WIDTH (self.frame.size.width)
#define HEIGHT (self.frame.size.height)

@interface DWSMoviePlayerView()

@property(nonatomic,strong)NSArray <NSURL *>* fileArray; //一组文件路径
@property(nonatomic,strong)NSURL *fileUrl; //文件路径
@property(nonatomic,strong)AVPlayerLayer *playerLayer;//显示层
@property(nonatomic,strong)AVPlayer *player; // 播放属性
@property(nonatomic,strong)AVPlayerItem *playerItem; // 播放属性
@property(nonatomic,strong)UISlider *slider; // 进度条
@property(nonatomic,strong)UILabel *currentTimeLabel; // 当前播放时间
@property(nonatomic,strong)UILabel *systemTimeLabel; // 系统时间
@property(nonatomic,strong)UIView *backView; // 上面一层Viewd
@property(nonatomic,assign)CGPoint startPoint;//上一次触摸点
@property(nonatomic,assign)CGFloat systemVolume;
@property(nonatomic,strong)UISlider *volumeViewSlider;
@property(nonatomic,strong)UIActivityIndicatorView *activity; // 系统菊花
@property(nonatomic,strong)UIProgressView *progress; // 缓冲条
@property(nonatomic,strong)UIView *topView; //顶部view
@property(nonatomic,strong)UIView *footView; //底部view
@property(nonatomic,strong)UILabel *titleLabel; //标题

@end

@implementation DWSMoviePlayerView
{
    NSInteger currentIndex;
    NSInteger totalNum;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}

- (instancetype)initWithFrame:(CGRect)frame andURLArray:(NSArray<NSURL *> *)array {
    self = [super initWithFrame:frame];
    if (self) {
        self.fileArray = array;
        if (array && array.count>0) {
            self.fileUrl = array[0];
            totalNum = self.fileArray.count;
            currentIndex = 0;
        }
        self.backgroundColor = [UIColor blackColor];
        
        self.playerItem = [AVPlayerItem playerItemWithURL:self.fileUrl];
        self.player = [AVPlayer playerWithPlayerItem:_playerItem];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        
        self.playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.layer addSublayer:self.playerLayer];
        [_player play];
        
        //AVPlayer播放完成通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
        [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性
        
        //计时器
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer *tim){
            if (_playerItem.duration.timescale != 0) {
                
                _slider.maximumValue = 1;//音乐总共时长
                _slider.value = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);//当前进度
                
                //当前时长进度progress
                NSInteger proMin = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前分钟
                NSInteger proSec = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前秒
                //    NSLog(@"%d",_playerItem.duration.timescale);
                //    NSLog(@"%lld",_playerItem.duration.value/1000 / 60);
                
                //duration 总时长
                NSInteger durMin = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总分钟
                NSInteger durSec = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总秒
                self.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld / %02ld:%02ld", proMin, proSec, durMin, durSec];
            }
            if (_player.status == AVPlayerStatusReadyToPlay) {
                [_activity stopAnimating];
            } else {
                [_activity startAnimating];
            }
        }];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

- (void)layoutSubviews {
    self.playerLayer.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
    
    //背景（在播放层之上，透明）
    self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [self addSubview:_backView];
    _backView.backgroundColor = [UIColor clearColor];
    //顶部（放在背景上）
    self.topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT * 0.15)];
    _topView.backgroundColor = [UIColor blackColor];
    _topView.alpha = 0.5;
    [_backView addSubview:_topView];
    //底部（放在背景上）
    self.footView = [[UIView alloc]initWithFrame:CGRectMake(0, HEIGHT*0.8, WIDTH, WIDTH*0.2)];
    _footView.backgroundColor = [UIColor blackColor];
    _footView.alpha = 0.5;
    [_backView addSubview:_footView];
    
    [self createProgress];
    [self createSlider];
    [self createCurrentTimeLabel];
    [self createButton];
    [self backButton];
    [self createTitle];
    [self createGesture];
    
    [self customVideoSlider];
    
    //系统小菊花（可自行替换成其他加载界面）
    self.activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activity.center = _backView.center;
    [self addSubview:_activity];
    [_activity startAnimating];
    
    //    //延迟线程
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            _backView.alpha = 0;
        }];
    });
}

#pragma mark - 横屏代码
- (BOOL)shouldAutorotate {
    return NO;
} //NS_AVAILABLE_IOS(6_0);当前viewcontroller是否支持转屏

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
} //当前viewcontroller支持哪些转屏方向

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

- (BOOL)prefersStatusBarHidden {
    return NO; // 返回NO表示要显示，返回YES将hiden
}

#pragma mark - 监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        //        NSLog(@"Time Interval:%f",timeInterval);
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.progress setProgress:timeInterval / totalDuration animated:NO];
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

- (void)customVideoSlider {
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //    [self.slider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

#pragma mark - 创建UIProgressView
- (void)createProgress {
    CGFloat h = _footView.frame.size.height/2-1;
    self.progress = [[UIProgressView alloc]initWithFrame:CGRectMake(WIDTH*0.15, h, WIDTH * 0.69, 15)];
    [_footView addSubview:_progress];
}

#pragma mark - 创建UISlider
- (void)createSlider {
    CGFloat h = _footView.frame.size.height/2-7.5;
    self.slider = [[UISlider alloc]initWithFrame:CGRectMake(WIDTH*0.15-2, h, WIDTH * 0.7, 15)];
    [self.footView addSubview:_slider];
    [_slider setThumbImage:[UIImage imageNamed:@"iconfont-yuan.png"] forState:UIControlStateNormal];
    [_slider addTarget:self action:@selector(progressSlider:) forControlEvents:UIControlEventValueChanged];
    _slider.minimumTrackTintColor = [UIColor colorWithRed:30/255.0 green:80/255.0 blue:100/255.0 alpha:1];
}

#pragma mark - slider滑动事件
- (void)progressSlider:(UISlider *)slider {
    //拖动改变视频播放进度
    if (_player.status == AVPlayerStatusReadyToPlay) {
        //    //计算出拖动的当前秒数
        CGFloat total = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        //    NSLog(@"%f", total);
        NSInteger dragedSeconds = floorf(total * slider.value);
        //    NSLog(@"dragedSeconds:%ld",dragedSeconds);
        //转换成CMTime才能给player来控制播放进度
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        [_player pause];
        [_player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
            [_player play];
        }];
    }
}

#pragma mark - 创建播放时间
- (void)createCurrentTimeLabel {
    self.currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH *0.86, 0, WIDTH*0.14, _footView.frame.size.height)];
    [self.footView addSubview:_currentTimeLabel];
    _currentTimeLabel.textColor = [UIColor whiteColor];
    //    _currentTimeLabel.backgroundColor = [UIColor blueColor];
    _currentTimeLabel.font = [UIFont systemFontOfSize:12];
    _currentTimeLabel.text = @"00:00/00:00";
    _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
}
#pragma mark - 播放和下一首按钮
- (void)createButton {
    CGFloat h = _footView.frame.size.height/2-15;
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(15, h, 30, 30);
    [self.footView addSubview:startButton];
    if (_player.rate == 1.0) {
        [startButton setBackgroundImage:[UIImage imageNamed:@"pauseBtn@2x.png"] forState:UIControlStateNormal];
    } else {
        [startButton setBackgroundImage:[UIImage imageNamed:@"playBtn@2x.png"] forState:UIControlStateNormal];
    }
    [startButton addTarget:self action:@selector(startAction:) forControlEvents:UIControlEventTouchUpInside];
    
    h = _footView.frame.size.height/2-12.5;
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(70, h, 25, 25);
    [self.footView addSubview:nextButton];
    [nextButton setBackgroundImage:[UIImage imageNamed:@"nextPlayer@3x.png"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 播放下一个按钮方法
- (void)next {
    if (![self canNext]) {
        NSLog(@"cannot next");
        return;
    }
    self.fileUrl = _fileArray[++currentIndex];
    [_player pause];
    for (UIView *vc in self.subviews) {
        [vc removeFromSuperview];
    }
    [self layoutSubviews];
}

- (BOOL)canNext {
    return currentIndex<(totalNum-1);
}

#pragma mark - 播放暂停按钮方法
- (void)startAction:(UIButton *)button {
    if (button.selected) {
        [_player play];
        [button setBackgroundImage:[UIImage imageNamed:@"pauseBtn@2x.png"] forState:UIControlStateNormal];
    } else {
        [_player pause];
        [button setBackgroundImage:[UIImage imageNamed:@"playBtn@2x.png"] forState:UIControlStateNormal];
    }
    button.selected =!button.selected;
}
#pragma mark - 返回按钮方法
- (void)backButton {
    CGFloat h = _topView.frame.size.height/2-15;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(15, h, 30, 30);
    [button setBackgroundImage:[UIImage imageNamed:@"iconfont-back.png"] forState:UIControlStateNormal];
    [_topView addSubview:button];
    [button addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backButtonAction {
    [_player pause];
    NSNumber *num = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:num forKey:@"orientation"];
}
#pragma mark 播放完成退出播放界面
- (void)moviePlayDidEnd:(id)sender {
    if ([self canNext]) {
        [self next];
        return;
    }
    NSNumber *num = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:num forKey:@"orientation"];
}
#pragma mark - 创建标题
- (void)createTitle {
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(WIDTH*0.15, 0, WIDTH*0.6, _topView.frame.size.height)];
    [_topView addSubview:self.titleLabel];
    //  self.titleLabel.backgroundColor = [UIColor redColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}
#pragma mark - 创建手势
- (void)createGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:tap];
    
    //获取系统音量
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    _volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            _volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    _systemVolume = _volumeViewSlider.value;
}
#pragma mark - 轻拍方法
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (_backView.alpha == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            _backView.alpha = 0;
        }];
    } else if (_backView.alpha == 0){
        [UIView animateWithDuration:0.5 animations:^{
            _backView.alpha = 1;
        }];
    }
    if (_backView.alpha == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                _backView.alpha = 0;
            }];
        });
    }
}
#pragma mark - 滑动调整音量大小
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if(event.allTouches.count == 1){
        //保存当前触摸的位置
        CGPoint point = [[touches anyObject] locationInView:self];
        _startPoint = point;
    }
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(event.allTouches.count == 1){
        //计算位移
        CGPoint point = [[touches anyObject] locationInView:self];
        //        float dx = point.x - startPoint.x;
        float dy = point.y - _startPoint.y;
        int index = (int)dy;
        if(index>0){
            if(index%5==0){//每10个像素声音减一格
                NSLog(@"%.2f",_systemVolume);
                if(_systemVolume>0.1){
                    _systemVolume = _systemVolume-0.05;
                    [_volumeViewSlider setValue:_systemVolume animated:YES];
                    [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
            }
        }else{
            if(index%5==0){//每10个像素声音增加一格
                NSLog(@"+x ==%d",index);
                NSLog(@"%.2f",_systemVolume);
                if(_systemVolume>=0 && _systemVolume<1){
                    _systemVolume = _systemVolume+0.05;
                    [_volumeViewSlider setValue:_systemVolume animated:YES];
                    [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
        //亮度调节
        //        [UIScreen mainScreen].brightness = (float) dx/self.view.bounds.size.width;
    }
}
#pragma mark
- (void)playAtIndex:(NSInteger)index {
    if (index >= totalNum) {
        NSLog(@"cannot play");
        return;
    }
    self.fileUrl = _fileArray[index];
    [_player pause];
    for (UIView *vc in self.subviews) {
        [vc removeFromSuperview];
    }
    currentIndex = index;
    [self layoutSubviews];
}

- (NSInteger)currentIndex {
    return currentIndex;
}

- (void)title:(NSString *)title {
    [self.titleLabel setText:title];
}


@end
