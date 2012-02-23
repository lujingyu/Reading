//
//  DetailViewController.h
//  Reading
//
//  Created by 陆敬宇 jingyu on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController {
	
	IBOutlet UITextView  *textView;
	NSDictionary         *para;
}
@property (nonatomic, assign)  NSDictionary  *para;

- (IBAction)actionBack:(id)sender;

@end
