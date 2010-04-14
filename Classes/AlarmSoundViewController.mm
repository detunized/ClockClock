#import "AlarmSoundViewController.h"
#import "Utils.h"

@implementation AlarmSoundViewController

@synthesize alarm;
@synthesize soundPlayer;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Sound", @"");
}

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
    
	if (indexPath.section == 0)
	{
		assert(indexPath.row == 0);
		cell.textLabel.text = NSLocalizedString(@"None", @"");
		cell.accessoryType = [self.alarm->getSound() isEqualToString:@""] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}
	else
	{
		NSString *sound = Alarm::GetSound(indexPath.row);
		cell.textLabel.text = sound;
		cell.accessoryType = [self.alarm->getSound() isEqualToString:sound] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	}

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = indexPath.row;
	if (indexPath.section == 0)
	{
		assert(row == 0);
		self.alarm->setSound(@"");
	}
	else
	{
		self.alarm->setSound(Alarm::GetSound(row));
		
		[self.soundPlayer stop];
		self.soundPlayer = LoadSound(Alarm::GetSoundFilename(row));
		self.soundPlayer.currentTime = 0;
		[self.soundPlayer play];
	}

	[self.tableView reloadData]; // TODO: inefficient
}

@end
