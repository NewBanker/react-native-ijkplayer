#import "RCTIJKPlayerManager.h"
#import "RCTIJKPlayer.h"
#import <React/RCTBridge.h>
#import <React/RCTEventDispatcher.h>
#import "UIView+React.h"
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import <ImageIO/ImageIO.h>

@interface RCTIJKPlayerManager ()

@end

@implementation RCTIJKPlayerManager

RCT_EXPORT_MODULE();

- (UIView *)viewWithProps:(__unused NSDictionary *)props
{
    return [self view];
}

- (UIView *)view
{
  
  self.rctijkplayer = [[RCTIJKPlayer alloc] initWithManager:self bridge:self.bridge];
  return self.rctijkplayer;
}

- (NSDictionary *)constantsToExport
{
    return @{};
}

- (dispatch_queue_t)methodQueue
{
  return dispatch_get_main_queue();
}

+ (BOOL)requiresMainQueueSetup { return YES; }

- (NSArray *)customDirectEventTypes
{
    return @[
      @"PlayBackState",
    ];
}

- (id)init {
  if ((self = [super init])) {
  }
  return self;
}


RCT_EXPORT_METHOD(start:(NSDictionary *)options
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject) {

[[UIApplication sharedApplication].delegate window].tag = 999 ;
  dispatch_async(dispatch_get_main_queue(), ^{
      [self.rctijkplayer startWithOptions:options];
    });
}

RCT_EXPORT_VIEW_PROPERTY(start, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(begin, NSDictionary);
RCT_EXPORT_VIEW_PROPERTY(stop, BOOL);
RCT_EXPORT_VIEW_PROPERTY(resume, BOOL);
RCT_EXPORT_VIEW_PROPERTY(pause, BOOL);
RCT_EXPORT_VIEW_PROPERTY(unMount, BOOL);
RCT_EXPORT_VIEW_PROPERTY(shutdown, BOOL);
RCT_EXPORT_VIEW_PROPERTY(seekTo, NSTimeInterval);
RCT_EXPORT_VIEW_PROPERTY(onPlaybackInfo, RCTDirectEventBlock);
RCT_EXPORT_VIEW_PROPERTY(onPlaybackStatu, RCTDirectEventBlock);


//RCT_EXPORT_METHOD(stop) {
//  [self.rctijkplayer stop];
//}
//
//RCT_EXPORT_METHOD(resume) {
//  [self.rctijkplayer resume];
//}
//
//RCT_EXPORT_METHOD(pause) {
//  [self.rctijkplayer pause];
//}
//
//RCT_EXPORT_METHOD(unMount) {
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.rctijkplayer shutdown];
//        [[UIApplication sharedApplication].delegate window].tag = 0;
//    });
//}
//
//RCT_EXPORT_METHOD(shutdown) {
//  dispatch_async(dispatch_get_main_queue(), ^{
//      [self.rctijkplayer shutdown];
//    });
//}
//
//
//RCT_EXPORT_METHOD(seekTo:(double)currentPlaybackTime) {
//  [self.rctijkplayer seekTo:currentPlaybackTime];
//}
//
//RCT_EXPORT_METHOD(playbackInfo:(RCTPromiseResolveBlock)resolve
//                  reject:(RCTPromiseRejectBlock)reject) {
//
//  NSDictionary *info = @{
//    @"currentPlaybackTime": [NSNumber numberWithDouble:self.rctijkplayer.player.currentPlaybackTime],
//    @"duration": [NSNumber numberWithDouble:self.rctijkplayer.player.duration],
//    @"playableDuration": [NSNumber numberWithDouble:self.rctijkplayer.player.playableDuration],
//    @"bufferingProgress": [NSNumber numberWithLong:self.rctijkplayer.player.bufferingProgress],
//    @"playbackState": [NSNumber numberWithInt:self.rctijkplayer.player.playbackState],
//    @"loadState": [NSNumber numberWithInt:self.rctijkplayer.player.loadState],
//    @"isPreparedToPlay": [NSNumber numberWithBool:self.rctijkplayer.player.isPreparedToPlay],
//  };
//
//  resolve(info);
//}
//



@end
