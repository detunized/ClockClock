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
