#import "Settings.h"

@interface AlarmTimeViewController: UIViewController<UITableViewDataSource>
{
	IBOutlet UITableView *_upperTable;
	IBOutlet UIDatePicker *_timePicker;
	Alarm *alarm;
}

@property (nonatomic, retain) IBOutlet UITableView *_upperTable;
@property (nonatomic, retain) IBOutlet UIDatePicker *_timePicker;
@property (nonatomic, assign) Alarm *alarm;

- (IBAction)onTimeChanged:(id)sender;

@end
