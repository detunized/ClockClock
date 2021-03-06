#import "SettingsViewController.h"

enum Section
{
	Section_Alarms,
	Section_TickSound,
	
	Section_Count
};

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = @"Settings";

	UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"")
																	style:UIBarButtonItemStyleDone
																   target:self
																   action:@selector(onDonePressed:)] autorelease];
	self.navigationItem.rightBarButtonItem = saveButton;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
//	[self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return Section_Count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section)
    {
		case Section_Alarms:
		{
			return Settings::Get().getAlarmCount() + 1;
			break;
		}
		case Section_TickSound:
		{
			return 1;
		}
	default:
		{
			assert(false);
			return 0;
		}
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	switch (section)
	{
		case Section_Alarms:
		{
			return NSLocalizedString(@"Alarms", @"");
		}
		case Section_TickSound:
		{
			return NSLocalizedString(@"Settings", @"");
		}
	}
	
	return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	switch (indexPath.section)
    {
	case Section_Alarms:
		{
			int row = indexPath.row;
			if (row == [self tableView:tableView numberOfRowsInSection:Section_Alarms] - 1)
			{
				cell.textLabel.text = @"Add Alarm...";
			}
			else
			{
				Alarm const &alarm = Settings::Get().getAlarm(row);
				cell.textLabel.text = [NSString stringWithFormat:@"%02d:%02d", alarm.getHour(), alarm.getMinute()];
			}

			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

			break;
		}
		case Section_TickSound:
		{
			cell.textLabel.text = NSLocalizedString(@"Tick Sound", @"");
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			
			UISwitch *button = [[[UISwitch alloc] init] autorelease];
			button.on = Settings::Get().getPlayTickSound();
			[button addTarget:self action:@selector(onTickSoundEnabled:) forControlEvents:UIControlEventValueChanged];
			cell.accessoryView = button;

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
	AlarmViewController *alarm = [[AlarmViewController alloc] initWithNibName:@"AlarmViewController" bundle:nil];
	alarm.delegate = self;
	
	_editAlarmIndex = indexPath.row;
	if (_editAlarmIndex >= Settings::Get().getAlarmCount())
	{
		alarm.isNewAlarm = true;
		[alarm  setAlarm:Alarm()];
	}
	else
	{
		alarm.isNewAlarm = false;
		[alarm setAlarm:Settings::Get().getAlarm(_editAlarmIndex)];
	}

	[self.navigationController pushViewController:alarm animated:YES];
	[alarm release];
}

- (void)onAlarmViewControllerCancel:(AlarmViewController *)sender
{
	// do nothing
}

- (void)onAlarmViewControllerSave:(AlarmViewController *)sender
{
	if (sender.isNewAlarm)
	{
		Settings::Get().addAlarm([sender getAlarm]);
	}
	else
	{
		Settings::Get().setAlarm(_editAlarmIndex, [sender getAlarm]);
	}
	
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:Section_Alarms] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)onAlarmViewControllerDelete:(AlarmViewController *)sender
{
	Settings::Get().removeAlarm(_editAlarmIndex);
	[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:Section_Alarms] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)onTickSoundEnabled:(id)sender
{
	Settings::Get().setPlayTickSound(((UISwitch *)sender).on);
}

- (void)onDonePressed:(id)sender
{
	[[UIApplication sharedApplication] setStatusBarHidden:YES animated:YES];
	[self dismissModalViewControllerAnimated:YES];
}

@end
