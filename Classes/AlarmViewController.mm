#import "AlarmViewController.h"
#import "AlarmTimeViewController.h"
#import "AlarmRepeatViewController.h"
#import "AlarmSoundViewController.h"
#import "AlarmNameViewController.h"

@implementation AlarmViewController

@synthesize isNewAlarm;
@synthesize delegate;

enum Section
{
	Section_Enable,
	Section_Time,
	Section_Delete,

	Section_Count
};

enum SectionTime
{
	SectionTime_Time,
	SectionTime_Repeat,
	SectionTime_Sound,
	SectionTime_Name,
	
	SectionTime_Count
};

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (self.isNewAlarm)
	{
		UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"")
																		  style:UIBarButtonItemStyleBordered
																		 target:self
																		 action:@selector(cancel:)] autorelease];
		self.navigationItem.leftBarButtonItem = cancelButton;
		
		UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"")
																		style:UIBarButtonItemStyleBordered
																	   target:self
																	   action:@selector(save:)] autorelease];
		self.navigationItem.rightBarButtonItem = saveButton;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return Section_Count - (self.isNewAlarm ? 1 : 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
	{
		case Section_Enable:
			return 1;
		case Section_Time:
			return SectionTime_Count;
		case Section_Delete:
			return 1;
		default:
			assert(false);
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	switch ([indexPath section])
    {
		case Section_Enable:
		{
			cell.textLabel.text = NSLocalizedString(@"Enalbled", @"");
			cell.selectionStyle = UITableViewCellSelectionStyleNone;

			UISwitch *button = [[[UISwitch alloc] init] autorelease];
			button.on = _alarm.getEnabled();
			[button addTarget:self action:@selector(onAlarmEnabled:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = button;

			break;
		}
		case Section_Time:
		{
			switch ([indexPath row])
			{
				case SectionTime_Time:
				{
					cell.textLabel.text = NSLocalizedString(@"Time", @"");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					
					break;
				}
				case SectionTime_Repeat:
				{
					cell.textLabel.text = NSLocalizedString(@"Repeat", @"");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				}
				case SectionTime_Sound:
				{
					cell.textLabel.text = NSLocalizedString(@"Sound", @"");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				}
				case SectionTime_Name:
				{
					cell.textLabel.text = NSLocalizedString(@"Name", @"");
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
					break;
				}
				default:
				{
					assert(false);
				}
			}
			break;
		}
		case Section_Delete:
		{
			cell.textLabel.text = NSLocalizedString(@"Delete Alarm", @"");
			cell.textLabel.textAlignment = UITextAlignmentCenter;

			break;
		}
		default:
		{
			assert(false);
		}
	}
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	switch ([indexPath section])
	{	
		case Section_Enable:
		{
			
			break;
		}
		case Section_Time:
		{
			switch ([indexPath row])
			{
				case SectionTime_Time:
				{
					AlarmTimeViewController *alarmTime = [[[AlarmTimeViewController alloc] initWithNibName:@"AlarmTimeViewController" bundle:nil] autorelease];
					alarmTime.alarm = &_alarm;
					[self.navigationController pushViewController:alarmTime animated:YES];
					
					break;
				}
				case SectionTime_Repeat:
				{
					AlarmRepeatViewController *alarmRepeat = [[[AlarmRepeatViewController alloc] initWithNibName:@"AlarmRepeatViewController" bundle:nil] autorelease];
					alarmRepeat.alarm = &_alarm;
					[self.navigationController pushViewController:alarmRepeat animated:YES];
					
					break;
				}
				case SectionTime_Sound:
				{
					AlarmSoundViewController *alarmSound = [[[AlarmSoundViewController alloc] initWithNibName:@"AlarmSoundViewController" bundle:nil] autorelease];
					alarmSound.alarm = &_alarm;
					[self.navigationController pushViewController:alarmSound animated:YES];

					break;
				}
				case SectionTime_Name:
				{
					AlarmNameViewController *alarmName = [[[AlarmNameViewController alloc] initWithNibName:@"AlarmNameViewController" bundle:nil] autorelease];
					alarmName.alarm = &_alarm;
					[self.navigationController pushViewController:alarmName animated:YES];
			
					break;
				}
				default:
				{
					assert(false);
				}
			}
			
			break;
		}
		case Section_Delete:
		{
			break;
		}
		default:
		{
			assert(false);
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	if (!self.isNewAlarm)
	{
		[self.delegate onAlarmViewControllerSave:self];
	}
}

- (void)cancel:(id)sender
{
	[self.delegate onAlarmViewControllerCancel:self];
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)save:(id)sender
{
	[self.delegate onAlarmViewControllerSave:self];
	[self.navigationController popViewControllerAnimated:YES];
}

- (Alarm const &)getAlarm
{
	return _alarm;
}

- (void)setAlarm:(Alarm const &)alarm
{
	_alarm = alarm;
}

- (void)onAlarmEnabled:(id)sender
{
	_alarm.setEnabled(((UISwitch *)sender).on);
}

@end
