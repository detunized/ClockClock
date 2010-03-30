#import <UIKit/UIKit.h>

#import <UIKit/UIKit.h>
#import "Settings.h"

@protocol AlarmViewControllerDelegate;

@interface AlarmViewController: UITableViewController
{
	bool isNewAlarm;
	id<AlarmViewControllerDelegate> delegate;
	
	Alarm _alarm;
}

@property (nonatomic, assign) bool isNewAlarm;
@property (nonatomic, assign) id<AlarmViewControllerDelegate> delegate;

- (Alarm const &)getAlarm;
- (void)setAlarm:(Alarm const &)alarm;

@end

@protocol AlarmViewControllerDelegate

- (void)onAlarmViewControllerCancel:(AlarmViewController *)sender;
- (void)onAlarmViewControllerSave:(AlarmViewController *)sender;

@end
