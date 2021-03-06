//
//  JLPlayerVC.m
//  JLPushFlow
//
//  Created by xp on 2018/11/14.
//  Copyright © 2018 Long. All rights reserved.
//

#import "JLPlayerVC.h"
#import <IJKMediaFramework/IJKFFOptions.h>
#import <IJKMediaFramework/IJKMediaPlayer.h>
#import <IJKMediaFramework/IJKFFMoviePlayerController.h>
#import <IJKMediaFramework/IJKMediaFramework.h>

//static NSString *RTMP_URL = @"rtmp://192.168.1.8:1935/rtmplive/room";
static NSString *RTMP_URL = @"rtmp://172.0.0.181:1935/rtmplive/room";

@interface JLPlayerVC ()

@property (nonatomic,strong) IJKFFOptions *options;
@property (nonatomic,strong) IJKFFMoviePlayerController *player;

@property (nonatomic, weak)  UIView *madieView;

@end

@implementation JLPlayerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupMadieView];
    
    [self.player prepareToPlay];
    [self.player play];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStateDidChange:) name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [self.player stop];
    [self.player shutdown];
    
    [super viewWillDisappear:animated];
}

#pragma mark - 按钮响应函数

#pragma mark - 协议函数

#pragma mark - 网络请求

#pragma mark - 自定义方法
//通过代理对象返回一个播放视频的view
- (void)setupMadieView {
    
    //通过代理对象view返回一个MadieView
    UIView *MadieView = [self.player view];
    self.madieView = MadieView;
    
    //横竖屏适配
    MadieView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    MadieView.frame = self.view.frame;
    
    [self.view addSubview:MadieView];
}

//网络状态改变通知响应
- (void)loadStateDidChange:(NSNotification *)notification{
    IJKMPMovieLoadState loadState = self.player.loadState;
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"LoadStateDidChange: 可以开始播放的状态: %d\n",(int)loadState);
    }else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}
//播放状态改变通知响应
- (void)playStateDidChange:(NSNotification *)notification{
    switch (_player.playbackState) {
            
        case IJKMPMoviePlaybackStateStopped:
            NSLog(@"--- %d: 停止", (int)_player.playbackState);
            break;
        case IJKMPMoviePlaybackStatePlaying:
            NSLog(@"--- %d: 播放中", (int)_player.playbackState);
            break;
        case IJKMPMoviePlaybackStatePaused:
            NSLog(@"--- %d: 暂停", (int)_player.playbackState);
            break;
        case IJKMPMoviePlaybackStateInterrupted:
            NSLog(@"--- %d: 被打断", (int)_player.playbackState);
            break;
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"--- %d: 搜索中", (int)_player.playbackState);
            break;
        }
            
        default: {
            NSLog(@"--- %d: 未知错误", (int)_player.playbackState);
            break;
        }
    }
}

-(IJKFFOptions *)options {
    if (!_options) {
        _options = [IJKFFOptions optionsByDefault];
        [_options setPlayerOptionValue:@"1" forKey:@"an"];  //静音设置
        [_options setPlayerOptionValue:@"1" forKey:@"videotoolbox"];  //开启硬解码
        [_options setPlayerOptionIntValue:10 forKey:@"max-buffer-size"];  //最大缓存
        [_options setFormatOptionIntValue:10 forKey:@"rtbufsize"];   //缓存
        [_options setFormatOptionIntValue:2000000 forKey:@"analyzeduration"];
        [_options setFormatOptionValue:@"nobuffer" forKey:@"fflags"];
        [_options setFormatOptionIntValue:4096 forKey:@"probsize"];
    }
    return _options;
}

-(IJKFFMoviePlayerController *)player {
    if (!_player) {
        _player = [[IJKFFMoviePlayerController alloc] initWithContentURLString:RTMP_URL withOptions:self.options];
        _player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _player.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        _player.view.backgroundColor = [UIColor blackColor];
        _player.scalingMode = IJKMPMovieScalingModeAspectFill; //缩放模式
        _player.shouldAutoplay = YES; //开启自动播放（player准后后，自动播放）
    }
    return _player;
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
