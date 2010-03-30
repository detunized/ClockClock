#import "AlarmTimeViewController.h"

@implementation AlarmTimeViewController

@synthesize _upperTable;
@synthesize _timePicker;
@synthesize alarm;

- (void)viewDidLoad
{
	[super viewDidLoad];

	self.title = NSLocalizedString(@"Time", @"");
	
	NSDateComponents *components = [[NSDateComponents alloc] init];
	[components setHour:self.alarm->getHour()];
	[components setMinute:self.alarm->getMinute()];
	_timePicker.date = [[NSCalendar currentCalendar] dateFromComponents:components];
	[components release];
}

- (IBAction)onTimeChanged:(id)sender
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:_timePicker.date];
	self.alarm->setHour([components hour]);
	self.alarm->setMinute([components minute]);
	
	// update time display
	[_upperTable reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
		NSLog(@"alloc!");
    }
    
	cell.textLabel.text = NSLocalizedString(@"Time", @"");
	cell.detailTextLabel.text = [NSString stringWithFormat:@"%02d:%02d", self.alarm->getHour(), self.alarm->getMinute()];
	
    return cell;
}

@end
