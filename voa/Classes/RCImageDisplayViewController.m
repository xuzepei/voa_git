//
//  RCImageDisplayViewController.m
//  VOA
//
//  Created by xuzepei on 7/28/15.
//
//

#import "RCImageDisplayViewController.h"
#import "VIPhotoView.h"
#import "RCImageLoader.h"
#import "RCTool.h"

@interface RCImageDisplayViewController ()

@end

@implementation RCImageDisplayViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateContent:(NSString*)imageUrl
{
    self.imageUrl = imageUrl;
    self.image = [RCTool getImage:self.imageUrl];
    
    if(nil == self.image)
        return;
    
    VIPhotoView *photoView = [[VIPhotoView alloc] initWithFrame:[RCTool getScreenRect] andImage:self.image];
    [self.view addSubview:photoView];
}

- (IBAction)clickedCancelButton:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)clickedSaveButton:(id)sender
{
    NSLog(@"clickedSaveButton");
    
    if(nil == self.image)
    {
        return;
    }
    
    UIImageWriteToSavedPhotosAlbum(self.image,
                                   self,
                                   @selector(image:didFinishSavingWithError:contextInfo:),
                                   nil);
}

- (void) image: (UIImage *) image
didFinishSavingWithError: (NSError *) error
   contextInfo: (void *) contextInfo
{
    if(0 == [error code])
    {
        [RCTool showAlert:NSLocalizedString(@"Hint",@"") message:NSLocalizedString(@"Succeed in saving this image to Photos Library.", @"")];
    }
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
