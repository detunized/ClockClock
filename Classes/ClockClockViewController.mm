#import "ClockClockViewController.h"
#import "ClockView.h"
#import "Settings.h"

//#define TRANSITION_TEST
//#define SHOW_NICE_TIME

@implementation ClockClockViewController

@synthesize _date;
@synthesize _seconds;
@synthesize _info;

static float const _initialAppearAnimationDuration = 0.5f;
static float const _infoFadeAnimationDuration = 0.5f;
static float const _timeChangeAnimationDuration = 0.5f;
static float const _goCrazyAnimationDuration = 0.5f;
static float const _goCrazySpinAngle = M_PI * 2;
static float const _spinAnimationDuration = 0.5f;
static float const _spinAngle = M_PI * 2;

#define L (M_PI)
#define R (0)
#define U (M_PI_2)
#define D (M_PI_2 * 3)
#define N (M_PI + M_PI_4)

static float const _digits[10][6][2] = 
{
	{{R, D}, {L, D}, {U, D}, {U, D}, {U, R}, {L, U}}, // 0
	{{N, N}, {D, D}, {N, N}, {U, D}, {N, N}, {U, U}}, // 1
	{{R, R}, {L, D}, {D, R}, {L, U}, {U, R}, {L, L}}, // 2
	{{R, R}, {L, D}, {R, R}, {U, D}, {R, R}, {L, U}}, // 3
	{{D, D}, {D, D}, {U, R}, {U, D}, {N, N}, {U, U}}, // 4
	{{R, D}, {L, L}, {U, R}, {L, D}, {R, R}, {L, U}}, // 5
	{{R, D}, {L, L}, {U, D}, {L, D}, {U, R}, {L, U}}, // 6
	{{R, R}, {L, D}, {N, N}, {U, D}, {N, N}, {U, U}}, // 7
	{{R, D}, {L, D}, {U, R}, {L, D}, {U, R}, {L, U}}, // 8
	{{R, D}, {L, D}, {U, R}, {U, D}, {R, R}, {L, U}}, // 9
};

#undef L
#undef R
#undef U
#undef D
#undef N

- (NSDate *)getTime
{
#ifdef SHOW_NICE_TIME
	static NSTimeInterval _start = 0;
	static NSTimeInterval _offset =  + (22 * 60 + 35) * 60 + 40;
	if (!_start)
	{
		_start = [[NSDate date] timeIntervalSinceReferenceDate];
	}
	
	return [[[NSDate alloc] initWithTimeIntervalSinceReferenceDate:([[NSDate date] timeIntervalSinceReferenceDate] - _start + _offset)] autorelease];
#else
	return [NSDate date];
#endif
}

- (void)setClock:(int)clock digit:(int)digit digitIndex:(int)digitIndex animationTime:(float)animationTime
{
	if (_currentDigits[digitIndex] != digit)
	{
		for (int i = 0; i <	3; ++i)
		{
			for (int j = 0; j < 2; ++j)
			{
				ClockView *view = _clocks[i * 8 + clock * 2 + j];
				float hourAngle = _digits[digit][i * 2 + j][0];
				float minuteAngle = _digits[digit][i * 2 + j][1];
				if (animationTime > 0)
				{
					[view animateTo:hourAngle minuteAngle:minuteAngle duration:animationTime];
				}
				else
				{
					[view setAngles:hourAngle minuteAngle:minuteAngle];
				}
			}
		}
		
		_currentDigits[digitIndex] = digit;
	}
}

- (void)setTime:(NSDate *)time animationTime:(float)animationTime
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:time];
	int hour = [components hour];
	int minute = [components minute];
	
#ifdef TRANSITION_TEST
	int second = [components second];
	hour = second;
	minute = second;
#endif
	
	[self setClock:0 digit:(hour / 10) % 10 digitIndex:0 animationTime:animationTime];
	[self setClock:1 digit:(hour % 10) digitIndex:1 animationTime:animationTime];
	[self setClock:2 digit:(minute / 10) % 10 digitIndex:2 animationTime:animationTime];
	[self setClock:3 digit:(minute % 10) digitIndex:3 animationTime:animationTime];
}

- (void)setSeconds:(NSDate *)time
{
	NSCalendar *calendar = [NSCalendar currentCalendar];
	NSDateComponents *components = [calendar components:(NSSecondCalendarUnit) fromDate:time];
	int second = [components second];
	
	if (second != _currentSeconds)
	{
		[_seconds setSeconds:second];
		_currentSeconds = second;
		
		if (_infoVisible && Settings::Get().getPlayTickSound())
		{
			[_tick play];
		}
	}
}

- (bool)isAnimating
{
	for (int i = 0, count = _clocks.size(); i < count; ++i)
	{
		if ([_clocks[i] isAnimating])
		{
			return true;
		}
	}
	
	return false;
}

- (void)goCrazy:(float)angle duration:(float)duration
{
	for (int i = 0, count = _clocks.size(); i < count; ++i)
	{
		[_clocks[i] spinRandomly:angle duration:duration];
		_goingCrazy = true;
	}
}

- (void)playSound
{
	[_tick play];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// hide info
	_date.alpha = 0;
	_seconds.alpha = 0;
	_info.alpha = 0;
	_infoVisible = false;
	_goingCrazy = false;
	_timeNeedUpdating = false;
	
	// create formatters
	_dateFormatter = [[NSDateFormatter alloc] init];
	[_dateFormatter setDateFormat:@"EEEE, LLLL d"];
	
	_secondsFormatter = [[NSDateFormatter alloc] init];
	[_secondsFormatter setDateFormat:@"ss"];
	
	// create clocks
	int const x0 = 0;
	int const y0 = 70;
	int const dx = 60;
	int const dy = 60;
	
	for (int i = 0; i < 3; ++i)
	{
		int y = y0 + dy * i;
		for (int j = 0; j < 8; ++j)
		{
			int x = x0 + dx * j;
			
			ClockView *view = [[ClockView alloc] initWithFrame:CGRectMake(x, y, dx, dy)];
			_clocks.push_back(view);
			
			view.alpha = 0;
			[self.view addSubview:view];
		}
	}
	
	// set time
	_currentDigits[0] = -1;
	_currentDigits[1] = -1;
	_currentDigits[2] = -1;
	_currentDigits[3] = -1;
	_currentSeconds = -1;
	[self setTime:[self getTime] animationTime:0];
	[self goCrazy:(M_PI * 4) duration:1];
	
	// make them slowly appear
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:_initialAppearAnimationDuration];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];

	for (int i = 0, count = _clocks.size(); i < count; ++i)
	{
		_clocks[i].alpha = 1;
	}
	
	[UIView commitAnimations];
	
	// load ticking sound
	_tick = [AVAudioPlayer alloc];
	NSString *path = [[NSBundle mainBundle] pathForResource:@"tick" ofType:@"wav"];
	NSURL *url = [NSURL fileURLWithPath:path];
	NSError *error;
	[_tick initWithContentsOfURL:url error:&error];
	[_tick prepareToPlay];
	
	// setup timers
	[NSTimer scheduledTimerWithTimeInterval:1.0f
									 target:self
								   selector:@selector(timeUpdateCallback:)
								   userInfo:nil
									repeats:YES];

	[NSTimer scheduledTimerWithTimeInterval:1.0f / 30
									 target:self
								   selector:@selector(animationCallback:)
								   userInfo:nil
									repeats:YES];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shakeCallback) name:@"shake" object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload
{
	[_tick stop];

	while (!_clocks.empty())
	{
		delete _clocks.back();
		_clocks.pop_back();
	}
}

- (void)dealloc
{
    [_dateFormatter release];
	[_secondsFormatter release];
	[_tick release];
	
	[super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	_wasMoved = false;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint p = [touch locationInView:self.view];
	UIView *view = [self.view hitTest:p withEvent:event];
	if ([view isKindOfClass:[ClockView class]])
	{
		ClockView *clock = (ClockView *)view;
		if (![clock isAnimating])
		{
			[clock spinRandomly:_spinAngle duration:_spinAnimationDuration];
			_wasMoved = true;
		}
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!_wasMoved)
	{
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:_infoFadeAnimationDuration];
		[UIView setAnimationBeginsFromCurrentState:YES];
		
		if (_infoVisible)
		{
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			_date.alpha = 0;
			_seconds.alpha = 0;
			_info.alpha = 0;
		}
		else
		{
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			_date.alpha = 1;
			_seconds.alpha = 1;
			_info.alpha = 1;
		}
		
		_infoVisible = !_infoVisible;
		
		[UIView commitAnimations];
	}
}

- (void)timeUpdateCallback:(NSTimer *)timer
{
	NSDate *now = [self getTime];
	
	// date
	_date.text = [_dateFormatter stringFromDate:now];
	
	// seconds
	[self setSeconds:now];

	// only update time if it's not animating
	if (![self isAnimating])
	{
		[self setTime:now animationTime:_timeChangeAnimationDuration];
	}
	else
	{
		// otherwise postpone it
		_timeNeedUpdating = true;
	}
}

- (void)animationCallback:(NSTimer *)timer
{
	// update animation
	float dt = [timer timeInterval];
	for (int i = 0, count = _clocks.size(); i < count; ++i)
	{
		[_clocks[i] update:dt];
	}
	
	if (![self isAnimating])
	{
		if (_goingCrazy)
		{
			_goingCrazy = false;
		}
		
		// postponed update
		if (_timeNeedUpdating)
		{
			[self setTime:[self getTime] animationTime:_timeChangeAnimationDuration];
			_timeNeedUpdating = false;
		}
	}
}

- (void)shakeCallback
{
	if (!_goingCrazy)
	{
		[self goCrazy:_goCrazySpinAngle duration:_goCrazyAnimationDuration];
	}
}

- (IBAction)onInfoClicked:(id)sender
{
	[[UIApplication sharedApplication] setStatusBarHidden:NO animated:YES];

	SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	UINavigationController *theNavController = [[UINavigationController alloc] initWithRootViewController:settings];
	[settings release];
	
	theNavController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
	[self presentModalViewController:theNavController animated:YES];
	
	theNavController.title = @"Yo!";
	
	[theNavController release];
}

@end
