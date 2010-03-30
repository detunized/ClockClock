#import <UIKit/UIKit.h>
#import "Settings.h"

@interface AlarmRepeatViewController: UITableViewController
{
	Alarm *alarm;
}

@property (nonatomic, assign) Alarm *alarm;

@end
