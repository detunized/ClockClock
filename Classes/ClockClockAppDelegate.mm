//
//  ClockClockAppDelegate.m
//  ClockClock
//
//  Created by Dmitry Yakimenko on 3/21/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "ClockClockAppDelegate.h"

@implementation ClockClockAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	[UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)dealloc
{
    [viewController release];
    [window release];
    [super dealloc];
}

@end
