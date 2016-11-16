//
//  VOAWifiOnlyCell.h
//  VOA
//
//  Created by xuzepei on 6/1/11.
//  Copyright 2011 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VOAWifiOnlyCell : UITableViewCell {

	UISwitch* _switch;
}

@property(nonatomic,retain)UISwitch* _switch;

- (void)updateContent;

@end
