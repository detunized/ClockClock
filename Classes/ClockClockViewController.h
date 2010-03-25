#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <vector>
#import "ClockView.h"
#import "SecondsView.h"

@interface ClockClockViewController: UIViewController
{
	UILabel *_date;
	SecondsView *_seconds;
	
	std::vector<ClockView *> _clocks;
	NSDateFormatter *_dateFormatter;
	NSDateFormatter *_secondsFormatter;

	bool _infoVisible;
	bool _wasMoved;
	bool _goingCrazy;
	bool _timeNeedUpdating;

	int _currentDigits[4];
	int _currentSeconds;
	
	AVAudioPlayer *_tick;
}

@property (nonatomic, retain) IBOutlet UILabel *_date;
@property (nonatomic, retain) IBOutlet SecondsView *_seconds;

@end
