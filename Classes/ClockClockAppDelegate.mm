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
