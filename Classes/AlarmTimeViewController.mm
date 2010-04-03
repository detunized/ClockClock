#import "AlarmTimeViewController.h"

@implementation AlarmTimeViewController

@synthesize _upperTable;
@synthesize _timePicker;
@synthesize alarm;

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = NSLocalizedString(@"Time", @"");
	
	NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	[components setHour:self.alarm->getHour()];
	[components setMinute:self.alarm->getMinute()];
	_timePicker.date = [[NSCalendar currentCalendar] dateFromComponents:components];
}

- (IBAction)onTimeChanged:(id)sender
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:_timePicker.date];
	self.alarm->setHour([components hour]);
	self.alarm->setMinute([components minute]);
	
	[_upperTable reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
//	NSDate *now = [NSDate now];
	NSDate *next = self.alarm->getNextTimeGoOff();
	NSTimeInterval dt = [next timeIntervalSinceNow];
	
	int minutes = (int)dt / 60 % 60;
	int hours = (int)dt / 60 / 60 % 24;
	int days = (int)dt / 60 / 60 / 24;
	
	bool needAnd = false;
	NSString *message = @"Alarm will go off in";
	if (days == 0 && hours == 0 && minutes == 0)
	{
		return [message stringByAppendingString:@" less than a minute"];
	}
	
	if (days > 0)
	{
		message = [NSString stringWithFormat:@"%@ %d day%@", 
				   message,
				   days, 
				   days == 1 ? @"" : @"s"];
		needAnd = true;
	}
	
	if (hours > 0)
	{
		message = [NSString stringWithFormat:@"%@%@ %d hour%@", 
				   message,
				   needAnd ? @" and" : @"",
				   hours, 
				   hours == 1 ? @"" : @"s"];
		needAnd = true;
	}
	
	if (minutes > 0)
	{
		message = [NSString stringWithFormat:@"%@%@ %d minute%@", 
				   message,
				   needAnd ? @" and" : @"",
				   minutes, 
				   minutes == 1 ? @"" : @"s"];
	}
	
	return message;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = NSLocalizedString(@"Time", @"");
	cell.detailTextLabel.text = self.alarm->getTimeString();
	
    return cell;
}

@end
