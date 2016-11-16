//
//  WRSysTabBarController.h
//  WRadio
//
//  Created by xuzepei on 6/2/10.
//  Copyright 2010 Rumtel Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WRSysTabBarController : UITabBarController 
{
	BOOL _shouldAutorotateToInterfaceOrientation;
}

@property(assign)BOOL _shouldAutorotateToInterfaceOrientation;

@end
