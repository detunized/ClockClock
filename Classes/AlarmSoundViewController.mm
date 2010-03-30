#import "AlarmSoundViewController.h"
#import <AVFoundation/AVFoundation.h>

@implementation AlarmSoundViewController

@synthesize alarm;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
	{
		return 1;
	}
	else
	{
		return Alarm::GetSoundCount();
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
    
	if ([indexPath section] == 0)
	{
		assert([indexPath row] == 0);
		cell.textLabel.text = NSLocalizedString(@"None", @"");
		cell.accessoryType = self.alarm->getSound() == "" ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
	else
	{
		int row = [indexPath row];
		std::string const &sound = Alarm::GetSound(row);
		cell.textLabel.text = [NSString stringWithUTF8String:sound.c_str()];
		cell.accessoryType = self.alarm->getSound() == sound ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if ([indexPath section] == 0)
	{
		assert([indexPath row] == 0);
		self.alarm->setSound("");
	}
	else
	{
		int row = [indexPath row];
		std::string const &sound = Alarm::GetSound(row);
		self.alarm->setSound(sound);
		
		AVAudioPlayer *player = [AVAudioPlayer alloc];
		NSURL *url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:Alarm::GetSoundFilename(row).c_str()]];
		NSError *error;
		[player initWithContentsOfURL:url error:&error];
		[player play];
	}

	[self.tableView reloadData]; // TODO: inefficient
}

@end
