#import <vector>
#import "ClockView.h"
#import "SecondsView.h"
#import "SettingsViewController.h"

@interface ClockClockViewController: UIViewController
{
	IBOutlet UILabel *_date;
	IBOutlet SecondsView *_seconds;
	IBOutlet UIButton *_info;
	
	std::vector<ClockView *> _clocks;
	NSDateFormatter *_dateFormatter;
	NSDateFormatter *_secondsFormatter;

	bool _infoVisible;
	bool _wasMoved;
	bool _goingCrazy;
	bool _timeNeedUpdating;

	int _currentDigits[4];
	int _currentSeconds;
	
	struct GoingOffAlarmInfo
	{
		int alarmIndex;
		NSTimeInterval soundPlayedAt;
	};

	std::vector<GoingOffAlarmInfo> _goingOffAlarms;
}

@property (nonatomic, retain) IBOutlet UILabel *_date;
@property (nonatomic, retain) IBOutlet SecondsView *_seconds;
@property (nonatomic, retain) IBOutlet UIButton *_info;

- (IBAction)onInfoClicked:(id)sender;

@end
