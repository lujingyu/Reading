//
//  PlayerController.h
//  Audio
//
//  Created by 陆敬宇 jingyu on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class PlayerController;
@protocol PlayerControllerDataSource <NSObject>
@required
- (NSUInteger)numberOfMusicsToPlay:(PlayerController *)player;
- (NSURL *)playerControllerWithURL:(PlayerController *)player atIndex:(NSUInteger)index;
@optional
- (UIView *)playerContentView:(PlayerController *)player atIndex:(NSUInteger)index;
@end

@interface PlayerController : UIViewController {
	
	AVAudioPlayer  *audioPlayer;
	NSTimer        *timer;
	NSUInteger     _numberOfMusics;
	NSInteger      _index;

	UILabel    *titleLabel;
	UILabel    *currentTimeLabel;
	UILabel    *durationLabel;
	UISlider   *progressSlider;
	UISlider   *volumeSlider;
	UIButton   *rewindButton;
	UIButton   *forwardButton;
	UIButton   *playButton;
	UIButton   *stopButton;
	UIButton   *volumeButton;
	UIView     *contentView;
	
	id<PlayerControllerDataSource>  dataSource;
}
@property (nonatomic, retain) AVAudioPlayer     *audioPlayer;
@property (nonatomic, retain) IBOutlet UILabel  *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel  *currentTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel  *durationLabel;
@property (nonatomic, retain) IBOutlet UISlider *progressSlider;
@property (nonatomic, retain) IBOutlet UISlider *volumeSlider;
@property (nonatomic, retain) IBOutlet UIButton *rewindButton;
@property (nonatomic, retain) IBOutlet UIButton *forwardButton;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *stopButton;
@property (nonatomic, retain) IBOutlet UIButton *volumeButton;
@property (nonatomic, retain) IBOutlet UIView   *contentView;
@property (nonatomic, assign) id<PlayerControllerDataSource> dataSource;

+ (PlayerController *)sharedPlayerController;
- (void)prepareToPlayAtIndex:(NSInteger)aIndex;

- (IBAction)actionPlayOrPause:(id)sender;
- (IBAction)actionStop:(id)sender;
- (IBAction)actionRewind:(id)sender;
- (IBAction)actionForword:(id)sender;
- (IBAction)actionSlideVolume:(id)sender;
- (IBAction)actionSlidePlayingProgress:(id)sender;
- (IBAction)actionVolume:(id)sender;

@end
