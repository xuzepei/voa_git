//
//  RCHintView.h
//  VOA
//
//  Created by xuzepei on 9/30/12.
//
//

#import <UIKit/UIKit.h>

@interface RCHintView : UIView

@property(nonatomic,retain)NSString* _title;
@property(nonatomic,retain)NSString* _text;

- (void)updateContent:(NSString*)title text:(NSString*)text;

@end
