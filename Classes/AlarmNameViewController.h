#import "Settings.h"

@interface AlarmNameViewController: UIViewController
{
	UITextField *_name;
	Alarm *alarm;
}

@property (nonatomic, retain) IBOutlet UITextField *_name;
@property (nonatomic, assign) Alarm *alarm;

@end
