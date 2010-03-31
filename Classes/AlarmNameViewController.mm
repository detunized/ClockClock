#import "AlarmNameViewController.h"

@implementation AlarmNameViewController

@synthesize _name;
@synthesize alarm;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.title = NSLocalizedString(@"Name", @"");
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	_name.text = self.alarm->getName();
	[_name becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	self.alarm->setName(_name.text);
}

@end
