//
//  RCImageDisplayViewController.h
//  VOA
//
//  Created by xuzepei on 7/28/15.
//
//

#import <UIKit/UIKit.h>

@interface RCImageDisplayViewController : UIViewController

@property(nonatomic,strong)NSString* imageUrl;
@property(nonatomic,strong)UIImage* image;

- (void)updateContent:(NSString*)imageUrl;
- (IBAction)clickedCancelButton:(id)sender;
- (IBAction)clickedSaveButton:(id)sender;

@end
