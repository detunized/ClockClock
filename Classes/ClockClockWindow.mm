#import "ClockClockWindow.h"

@implementation ClockClockWindow

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event                                                                                           
{                                                                                                                                                               
}                                                                                                                                                               

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event                                                                                           
{   
	if (motion == UIEventSubtypeMotionShake)                                                                                                               
	{                                                                                                                                                       
		[[NSNotificationCenter defaultCenter] postNotificationName:@"shake" object:self];                                                               
	}                                                                                                                                                       
}                                                                                                                                                               

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event                                                                                       
{                                                                                                                                                               
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

@end
