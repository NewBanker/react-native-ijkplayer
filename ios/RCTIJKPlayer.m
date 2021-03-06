#import <React/RCTBridgeModule.h>
#import "RCTIJKPlayer.h"
#import "RCTIJKPlayerManager.h"
#import <React/RCTEventDispatcher.h>
#import <React/RCTLog.h>
#import "UIView+React.h"
#import <IJKMediaFramework/IJKFFMoviePlayerController.h>
// #import "IJKMediaControl.h"

@interface RCTIJKPlayer ()

@property (nonatomic, weak) RCTIJKPlayerManager *manager;
@property (nonatomic, weak) RCTBridge *bridge;
//@property(nonatomic,strong)IJKFFMoviePlayerController * player;

@end

@implementation RCTIJKPlayer
{
    
     NSTimer * _timer;
     BOOL _stop;
     BOOL _resume;
     BOOL _pause;
     BOOL _unMount;
     BOOL _shutdown;
     NSTimeInterval _seekTo;
     NSDictionary * _start;
}

RCT_EXPORT_VIEW_PROPERTY(getInfo, BOOL);


- (void)setPause:(BOOL)pause {
    [self pause];
}

- (void)setResume:(BOOL)resume {
    [self resume];
}

- (void)setStop:(BOOL)stop {
     [self stop];
}

- (void)setUnMount:(BOOL)unMount {
    [[UIApplication sharedApplication].delegate window].tag = 0;
}

- (void)setShutdown:(BOOL)shutdown {
    [self shutdown];
}

- (void)setSeekTo:(NSTimeInterval)seek {
    [self seekTo:seek * 1000];
}

- (void)setBegin:(NSDictionary * )info {
    [self setStart:info];
}
- (void)setStart:(NSDictionary * )info {
    [self startWithOptions:info];
    if(_timer){
        [_timer fire];
        [_timer invalidate];
        _timer = nil;
    }
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        _timer = [NSTimer timerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            [self updatePlayerInfo];
        }];
    } else {
        _timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(updatePlayerInfo) userInfo:nil repeats:YES];
    }
    
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];

}

- (void)updatePlayerInfo {
    if(self.onPlaybackInfo) {
        NSDictionary *info = @{
                               @"currentPlaybackTime": [NSNumber numberWithDouble:self.player.currentPlaybackTime],
                               @"duration": [NSNumber numberWithDouble:self.player.duration],
                               @"playableDuration": [NSNumber numberWithDouble:self.player.playableDuration],
                               @"bufferingProgress": [NSNumber numberWithLong:self.player.bufferingProgress],
                               @"playbackState": [NSNumber numberWithInt:self.player.playbackState],
                               @"loadState": [NSNumber numberWithInt:self.player.loadState],
                               @"isPreparedToPlay": [NSNumber numberWithBool:self.player.isPreparedToPlay],
                               };
        
        self.onPlaybackInfo(info);
    }
}

- (id)initWithManager:(RCTIJKPlayerManager*)manager bridge:(RCTBridge *)bridge
{
  if ((self = [super init])) {
    self.manager = manager;
    self.bridge = bridge;
  }

#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif

    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
     [[UIApplication sharedApplication].delegate window].tag = 999 ;
  return self;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  return;
}

- (void)insertReactSubview:(UIView *)view atIndex:(NSInteger)atIndex
{
  [self insertSubview:view atIndex:atIndex + 1];
  return;
}

- (void)removeReactSubview:(UIView *)subview
{
  [subview removeFromSuperview];
  return;
}

- (void)removeFromSuperview
{
  [super removeFromSuperview];
}

//- (void)loadStateDidChange:(NSNotification*)notification
//{
//    //    MPMovieLoadStateUnknown        = 0,
//    //    MPMovieLoadStatePlayable       = 1 << 0,
//    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
//    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
//
//    IJKMPMovieLoadState loadState = _player.loadState;
//
//    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
//        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
//    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
//        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
//    } else {
//        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
//    }
//}

//- (void)moviePlayBackDidFinish:(NSNotification*)notification
//{
//    //    MPMovieFinishReasonPlaybackEnded,
//    //    MPMovieFinishReasonPlaybackError,
//    //    MPMovieFinishReasonUserExited
//    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
//
//    switch (reason)
//    {
//        case IJKMPMovieFinishReasonPlaybackEnded:
//            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
//            break;
//
//        case IJKMPMovieFinishReasonUserExited:
//            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
//            break;
//
//        case IJKMPMovieFinishReasonPlaybackError:
//            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
//            break;
//
//        default:
//            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
//            break;
//    }
//}

//- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
//{
//    NSLog(@"mediaIsPreparedToPlayDidChange\n");
//}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    NSDictionary *event = @{
        @"state": [[NSNumber numberWithInt:(int)_player.playbackState] stringValue],
        };
//   [self.bridge.eventDispatcher sendAppEventWithName:@"PlayBackState" body:event];
    
    if(self.onPlaybackStatu){
        self.onPlaybackStatu(event);
    }

//    switch (_player.playbackState)
//    {
//        case IJKMPMoviePlaybackStateStopped: {
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
//            break;
//        }
//        case IJKMPMoviePlaybackStatePlaying: {
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
//            break;
//        }
//        case IJKMPMoviePlaybackStatePaused: {
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
//            break;
//        }
//        case IJKMPMoviePlaybackStateInterrupted: {
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
//            break;
//        }
//        case IJKMPMoviePlaybackStateSeekingForward:
//        case IJKMPMoviePlaybackStateSeekingBackward: {
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
//            break;
//        }
//        default: {
//            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
//            break;
//        }
//    }
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(loadStateDidChange:)
//                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
//                                               object:_player];

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(moviePlayBackDidFinish:)
//                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
//                                               object:_player];

//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
//                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
//                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
   // [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
 //   [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

- (void)resume
{
    if (self.player) {
        [self.player play];
    }
}

- (void)pause
{
    if (self.player) {
        [self.player pause];
    }
}

- (void)shutdown
{
    if (self.player) {
        [self.player shutdown];
    }
    
    if(_timer){
        [_timer fire];
        [_timer invalidate];
        _timer = nil;
    }
    self.player = nil;
}

- (void)stop
{
    if (self.player) {
        [self.player stop];
    }
}

- (void)seekTo:(NSTimeInterval)currentPlaybackTime
{
    if (self.player) {
      NSLog(@"(void)seekTo:(NSTimeInterval)currentPlaybackTime %f\n", currentPlaybackTime);
      self.player.currentPlaybackTime = currentPlaybackTime;
    }
}

- (void)startWithOptions:(NSDictionary *)options
{
    
 [[UIApplication sharedApplication].delegate window].tag = 999 ;
  if (self.player) {
    self.player = nil;
  }
    
  NSString *URL = (NSString *)(options[@"url"]);
  NSLog(@"URL: %@", URL);

    self.url = [NSURL URLWithString:URL];
    NSInteger start =  ((NSNumber *)options[@"seek"]).integerValue;
    IJKFFOptions *ijkOptions = [IJKFFOptions optionsByDefault];
    [ijkOptions setPlayerOptionIntValue:start forKey:@"seek-at-start"];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withOptions:ijkOptions];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    [self.player setPauseInBackground:NO];
    self.autoresizesSubviews = YES;
    [self addSubview:self.player.view];
    [self installMovieNotificationObservers];
    [self.player prepareToPlay];
    [self layoutIfNeeded];
    [self layoutSubviews];
}

- (void)dealloc
{
    [[UIApplication sharedApplication].delegate window].tag = 0;
    [self shutdown];
    [_timer fire];
    [_timer invalidate];
}

@end
