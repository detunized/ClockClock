//
//  ClockClockAppDelegate.h
//  ClockClock
//
//  Created by Dmitry Yakimenko on 3/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClockClockWindow.h"
#import "ClockClockViewController.h"

@interface ClockClockAppDelegate: NSObject<UIApplicationDelegate>
{
	ClockClockWindow *window;
    ClockClockViewController *viewController;
}

@property (nonatomic, retain) IBOutlet ClockClockWindow *window;
@property (nonatomic, retain) IBOutlet ClockClockViewController *viewController;

@end
