/**
 * Copyright (c) 2009 Alex Fajkowski, Apparent Logic LLC
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */
#import "AFOpenFlowViewController.h"
#import "UIImageExtras.h"
#import "AFGetImageOperation.h"
#import "DetailViewController.h"
#import "NSString+Extra.h"

@implementation AFOpenFlowViewController

//#error Change theses values to your Flickr API key & secret

- (void)dealloc {
	[loadImagesOperationQueue release];
	[interestingPhotosDictionary release];
	[flowView release];

    [super dealloc];
}

- (void)viewDidLoad {
	[super viewDidLoad];	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"DataSource" ofType:@"plist"];	
	dataSource = [[NSMutableArray alloc] initWithContentsOfFile:path];
	
	UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
	background.image = [UIImage imageNamed:@""];
	background.backgroundColor = [UIColor whiteColor];
	[self.view addSubview:background];
	[background release];
	
	flowView = [[AFOpenFlowView alloc] initWithFrame:self.view.bounds];
	[flowView setBackgroundColor:[UIColor clearColor]];
	[self.view addSubview:flowView];
	[flowView setDataSource:self];
	[flowView setViewDelegate:self];
	
	for (int i = 0; i < [dataSource count]; i++) {
		NSDictionary *dict = [dataSource objectAtIndex:i];
		NSString *imageName = [dict objectForKey:@"coverImage"];
		[flowView setImage:[UIImage imageNamed:imageName] forIndex:i];
	}
	[flowView setNumberOfImages:[dataSource count]];
	
/**	
	int sumPhoto=[dataSource count];
	
	NSString *imageName;
	for (int i=0; i < sumPhoto; i++) {
		imageName = [[NSString alloc] initWithFormat:@"cover_%d.jpg", 1000+i];
		[flowView setImage:[UIImage imageNamed:imageName] forIndex:i];
		[imageName release];
	}
	[flowView setNumberOfImages:sumPhoto]; 
 */
}

- (void)imageDidLoad:(NSArray *)arguments {
	UIImage *loadedImage = (UIImage *)[arguments objectAtIndex:0];
	NSNumber *imageIndex = (NSNumber *)[arguments objectAtIndex:1];
	
	// Only resize our images if they are coming from Flickr (samples are already scaled).
	// Resize the image on the main thread (UIKit is not thread safe).
	
	[flowView setImage:loadedImage forIndex:[imageIndex intValue]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}

- (UIImage *)defaultImage {
	return [UIImage imageNamed:@"Default.png"];
}

- (void)openFlowView:(AFOpenFlowView *)openFlowView requestImageForIndex:(int)index {
	
	AFGetImageOperation *getImageOperation = [[AFGetImageOperation alloc] initWithIndex:index viewController:self];

	[loadImagesOperationQueue addOperation:getImageOperation];
	[getImageOperation release];
}

//AFOpenFlowViewDelegate的实现
- (void)openFlowView:(AFOpenFlowView *)openFlowView selectionDidChange:(int)index {
	NSLog(@"Cover Flow selection did change to %d", index);
}

#pragma mark fixedByKen
- (void)openFlowItemView:(AFItemView *)view didSelectAtIndex:(int)index {
	NSDictionary *dict = [dataSource objectAtIndex:index];
	DetailViewController *controller = [[DetailViewController alloc] init];
	controller.para = dict;
	[self.navigationController pushViewController:controller animated:YES];
	[controller release];
}

@end