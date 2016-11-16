//
//  RCDictionaryViewController.h
//  SAT
//
//  Created by xu zepei on 5/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface RCDictionaryViewController : UIViewController<UIWebViewDelegate,AVAudioPlayerDelegate>
{
    NSDictionary* _word;
    UIWebView* _webView;
    BOOL _isPlaying;
    BOOL _willPlay;
    
    AVAudioPlayer* _player;
    
    UIActivityIndicatorView* _indicatorView;
    UILabel* _noResultsLabel;
    
    int _tryTimes;
}

@property(nonatomic,retain)NSDictionary* _word;
@property(nonatomic,retain)UIWebView* _webView;
@property(nonatomic,retain)AVAudioPlayer* _player;
@property(nonatomic,retain)UIActivityIndicatorView* _indicatorView;
@property(nonatomic,retain)UILabel* _noResultsLabel;

- (void)explanationOfWord;
- (void)voiceOfWord;
- (void)updateContent:(NSDictionary*)word;
- (void)initWebView;
- (void)speak:(id)argument;
- (void)initIndicatorView;
- (void)initNoResultsLabel;

@end
