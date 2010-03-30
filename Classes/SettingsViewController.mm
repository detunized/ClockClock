//
//  SettingsViewController.mm
//  ClockClock
//
//  Created by Dmitry Yakimenko on 3/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

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
	case Section_Alarms:
		{
			int row = [indexPath row];
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
			cell.accessoryView = [[[UISwitch alloc] init] autorelease];

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
	
	_editAlarmIndex = [indexPath row];
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

@end
