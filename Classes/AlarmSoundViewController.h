#import "Settings.h"

@interface AlarmSoundViewController: UITableViewController
{
	Alarm *alarm;
	AVAudioPlayer *soundPlayer;
}

@property (nonatomic, assign) Alarm *alarm;
@property (nonatomic, retain) AVAudioPlayer *soundPlayer;

@end
