#import "AlarmRepeatViewController.h"

@implementation AlarmRepeatViewController

@synthesize alarm;

static NSString *_days[] =
{
	@"Monday",
	@"Tuesday",
	@"Wednesday",
	@"Thursday",
	@"Friday",
	@"Saturday",
	@"Sunday"
};

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return Alarm::Day_Count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	int row = [indexPath row];
	Alarm::Day day = (Alarm::Day)row;
	cell.textLabel.text = _days[row];
	cell.accessoryType = self.alarm->getRepeat(day) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	Alarm::Day day = (Alarm::Day)row;
	self.alarm->setRepeat(day, !self.alarm->getRepeat(day));
	[tableView cellForRowAtIndexPath:indexPath].accessoryType = self.alarm->getRepeat(day) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

@end
