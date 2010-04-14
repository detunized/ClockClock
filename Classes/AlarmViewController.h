#import "Settings.h"

@protocol AlarmViewControllerDelegate;

@interface AlarmViewController: UITableViewController
{
	bool isNewAlarm;
	id<AlarmViewControllerDelegate> delegate;
	
	Alarm _alarm;
	bool _deleted;
}

@property (nonatomic, assign) bool isNewAlarm;
@property (nonatomic, assign) id<AlarmViewControllerDelegate> delegate;

- (Alarm const &)getAlarm;
- (void)setAlarm:(Alarm const &)alarm;

@end

@protocol AlarmViewControllerDelegate

@required

- (void)onAlarmViewControllerCancel:(AlarmViewController *)sender;
- (void)onAlarmViewControllerSave:(AlarmViewController *)sender;
- (void)onAlarmViewControllerDelete:(AlarmViewController *)sender;

@end
