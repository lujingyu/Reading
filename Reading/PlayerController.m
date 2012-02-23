//
//  PlayerController.m
//  Audio
//
//  Created by 陆敬宇 jingyu on 2/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlayerController.h"
#import "SynthesizeSingleton.h"

#define UserDefault_volume   @"volume"

@interface NSString (Extra)  

+ (NSString *)stringFromTimeInterval:(int)totalSeconds;

@end

@implementation NSString (Extra)

+ (NSString *)stringFromTimeInterval:(int)totalSeconds {
    int seconds = totalSeconds % 60; 
    int minutes = (totalSeconds / 60) % 60; 
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds]; 
}

@end

@implementation PlayerController

SYNTHESIZE_SINGLETON_FOR_CLASS(PlayerController)

@synthesize audioPlayer;
@synthesize titleLabel;
@synthesize currentTimeLabel;
@synthesize durationLabel;
@synthesize progressSlider;
@synthesize volumeSlider;
@synthesize rewindButton;
@synthesize forwardButton;
@synthesize playButton;
@synthesize stopButton;
@synthesize volumeButton;
@synthesize contentView;
@synthesize dataSource;

- (void)dealloc {
	[audioPlayer release];
	
	[titleLabel release];
	[currentTimeLabel release];
	[durationLabel release];
	[progressSlider release];
	[volumeSlider release];
	[rewindButton release];
	[forwardButton release];
	[playButton release];
	[stopButton release];
	[volumeButton release];
	[contentView release];
	self.dataSource = nil;
	[super dealloc];
}

- (id)init {
	if (self = [super init]) {
		/**
		 锁屏、后台播放解决方案：
		 1. 在info文件中添加 Key: Required background modes        Type: Array
		 为其添加一个item Type: String      Value: App playes audio
		 2. 添加如下代码
		 [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
		 */
		AVAudioSession *session = [AVAudioSession sharedInstance];  
		[session setActive:YES error:nil];  
		[session setCategory:AVAudioSessionCategoryPlayback error:nil]; 
		_index = 0;
	}
	return self;
}

- (void)updatePlayingProgress {
	currentTimeLabel.text = [NSString stringFromTimeInterval:audioPlayer.currentTime];
	durationLabel.text = [NSString stringFromTimeInterval:audioPlayer.duration];
	progressSlider.value = audioPlayer.currentTime/audioPlayer.duration;
}

- (void)updateButtons {
	rewindButton.enabled = _index == 0 ? NO : YES;
	forwardButton.enabled = _index == _numberOfMusics - 1 ? NO : YES;
	titleLabel.text = [NSString stringWithFormat:@"%d of %d", _index + 1, _numberOfMusics];
	if ([self.dataSource respondsToSelector:@selector(playerContentView:atIndex:)]) {
		UIView *view = [self.view viewWithTag:5000];
		if (view) {
			[view removeFromSuperview];
		}
		view = [self.dataSource playerContentView:self atIndex:_index];
		view.tag = 5000;
		[self.contentView addSubview:[self.dataSource playerContentView:self atIndex:_index]];
	}
}

// 播放/暂停
- (IBAction)actionPlayOrPause:(UIButton *)sender {
	if ([audioPlayer isPlaying] == YES) {
		sender.selected = NO;
		[audioPlayer pause];
	}
	else {
		sender.selected = YES;
		[audioPlayer play];
		if (timer == nil) {
			timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updatePlayingProgress) userInfo:nil repeats:YES];
			[timer fire];
		}
	}
	[self updateButtons];
}

// 停止
- (IBAction)actionStop:(id)sender {
	if (audioPlayer) {
		[audioPlayer stop];
		[audioPlayer setCurrentTime:0];
		[playButton setSelected:NO];
	}
}

// 上一首
- (IBAction)actionRewind:(id)sender {
	@autoreleasepool {
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfMusicsToPlay:)]) {
			_numberOfMusics = [self.dataSource numberOfMusicsToPlay:self];
		}
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(playerControllerWithURL:atIndex:)]) {
			[audioPlayer release];
			audioPlayer = nil;
			NSURL *url = [self.dataSource playerControllerWithURL:self atIndex:--_index];
			NSError *error = nil;
			audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
			if (error) {
				NSLog(@"%@", [error description]);
				return;
			}
			audioPlayer.numberOfLoops = -1;
			[audioPlayer prepareToPlay];
			[self updatePlayingProgress];
			if (playButton.isSelected == YES) {
				[audioPlayer play];
			}
		}
		[self updateButtons];
	}
}

// 下一首
- (IBAction)actionForword:(id)sender {
	@autoreleasepool {
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfMusicsToPlay:)]) {
			_numberOfMusics = [self.dataSource numberOfMusicsToPlay:self];
		}
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(playerControllerWithURL:atIndex:)]) {
			[audioPlayer release];
			audioPlayer = nil;
			NSURL *url = [self.dataSource playerControllerWithURL:self atIndex:++_index];
			NSError *error = nil;
			audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
			if (error) {
				NSLog(@"%@", [error description]);
				return;
			}
			audioPlayer.numberOfLoops = -1;
			[audioPlayer prepareToPlay];
			[self updatePlayingProgress];
			if (playButton.isSelected == YES) {
				[audioPlayer play];
			}
		}
		[self updateButtons];
	}
}

// 设置音量
- (IBAction)actionSlideVolume:(UISlider *)sender {
	audioPlayer.volume = sender.value;
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSNumber *volume = [NSNumber numberWithFloat:audioPlayer.volume];
	[userDefaults setValue:volume forKey:UserDefault_volume];
	[userDefaults synchronize];
	if (sender.value == 0) {
		[volumeButton setSelected:YES];
	}
	else {
		[volumeButton setSelected:NO];
	}
}

// 手动调整播放进度
- (IBAction)actionSlidePlayingProgress:(UISlider *)sender {
	audioPlayer.currentTime = sender.value * audioPlayer.duration;
}

// 音量开关
- (IBAction)actionVolume:(UIButton *)sender {
	sender.selected = !sender.selected;
	if (sender.selected == YES) {
		[volumeSlider setValue:0 animated:YES];
	}
	else {
		float volume = [[[NSUserDefaults standardUserDefaults] valueForKey:UserDefault_volume] floatValue];
		[volumeSlider setValue:volume animated:YES];
	}
	audioPlayer.volume = volumeSlider.value;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	[playButton setShowsTouchWhenHighlighted:YES];
	[stopButton setShowsTouchWhenHighlighted:YES];
	[rewindButton setShowsTouchWhenHighlighted:YES];
	[forwardButton setShowsTouchWhenHighlighted:YES];
	[volumeButton setShowsTouchWhenHighlighted:YES];
	[playButton setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
	[playButton setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateSelected];
	[playButton setSelected:YES];
	[volumeButton setImage:[UIImage imageNamed:@"volume.png"] forState:UIControlStateNormal];
	[volumeButton setImage:[UIImage imageNamed:@"non_volume.png"] forState:UIControlStateSelected];
	[volumeButton setSelected:NO];
	
	[volumeSlider setThumbImage:[UIImage imageNamed:@"indicator_large.png"] forState:UIControlStateNormal];
	[progressSlider setThumbImage:[UIImage imageNamed:@"indicator_small.png"] forState:UIControlStateNormal];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	if ([userDefaults valueForKey:UserDefault_volume] == nil) {
		[userDefaults setValue:[NSNumber numberWithFloat:0.7] forKey:UserDefault_volume];
		[userDefaults synchronize];
	}
	float volume = [[userDefaults valueForKey:UserDefault_volume] floatValue];
	audioPlayer.volume = volume;
	volumeSlider.value = audioPlayer.volume;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	if ([audioPlayer isPlaying] == NO) {
		playButton.selected = YES;
		[audioPlayer play];
		if (timer == nil) {
			timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updatePlayingProgress) userInfo:nil repeats:YES];
			[timer fire];
		}
	}
	[self updateButtons];
}

- (void)prepareToPlayAtIndex:(NSInteger)aIndex {
	@autoreleasepool {
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfMusicsToPlay:)]) {
			_numberOfMusics = [self.dataSource numberOfMusicsToPlay:self];
		}
		if (self.dataSource && [self.dataSource respondsToSelector:@selector(playerControllerWithURL:atIndex:)]) {
			NSURL *url = [self.dataSource playerControllerWithURL:self atIndex:aIndex];
			_index = aIndex;
			if (audioPlayer == nil) {
				NSError *error = nil;
				audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
				if (error) {
					NSLog(@"%@", [error description]);
					return;
				}
				audioPlayer.numberOfLoops = -1;
				[audioPlayer prepareToPlay];
				[self updatePlayingProgress];
				[self updateButtons];
			}
			else {
				if ([audioPlayer.url isEqual:url]) {
					//
				} 
				else {
					[audioPlayer release];
					audioPlayer = nil;
					audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
					audioPlayer.numberOfLoops = -1;
					[audioPlayer prepareToPlay];
					[self updatePlayingProgress];
					[self updateButtons];
				}
			}
		}
	}
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	self.titleLabel = nil;
	self.currentTimeLabel = nil;
	self.durationLabel = nil;
	self.progressSlider = nil;
	self.volumeSlider = nil;
	self.rewindButton = nil;
	self.forwardButton = nil;
	self.playButton = nil;
	self.stopButton = nil;
	self.volumeButton = nil;
	self.contentView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
